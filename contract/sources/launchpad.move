module launchpad_addr::launchpad {
    use std::option::{Self, Option};
    use std::signer;
    use std::string::{Self, String};
    use std::vector;

    use aptos_std::table::{Self, Table};

    use aptos_framework::aptos_account;
    use aptos_framework::event;
    use aptos_framework::fungible_asset::{Self, Metadata};
    use aptos_framework::object::{Self, Object, ObjectCore, ExtendRef};
    use aptos_framework::primary_fungible_store;
    use aptos_framework::timestamp;

    /// Existing error codes from launchpad
    const EONLY_ADMIN_CAN_UPDATE_CREATOR: u64 = 1;
    const EONLY_ADMIN_CAN_SET_PENDING_ADMIN: u64 = 2;
    const ENOT_PENDING_ADMIN: u64 = 3;
    const EONLY_ADMIN_CAN_UPDATE_MINT_FEE_COLLECTOR: u64 = 4;
    const EONLY_ADMIN_OR_CREATOR_CAN_CREATE_FA: u64 = 5;
    const ENO_MINT_LIMIT: u64 = 6;
    const EMINT_LIMIT_REACHED: u64 = 7;
    const EONLY_ADMIN_CAN_UPDATE_MINT_ENABLED: u64 = 8;
    const EMINT_IS_DISABLED: u64 = 9;
    const ECANNOT_MINT_ZERO: u64 = 10;

    /// New error codes adapted from credit_system
    const EINSUFFICIENT_BALANCE: u64 = 11;
    const ENOT_INITIALIZED: u64 = 12;
    const EWRONG_ASSET: u64 = 13;

    /// Default constants from launchpad
    const DEFAULT_PRE_MINT_AMOUNT: u64 = 0;
    const DEFAULT_mint_fee_per_smallest_unit_of_fa: u64 = 0;

    /// Existing event structs
    #[event]
    struct CreateFAEvent has store, drop {
        creator_addr: address,
        fa_owner_obj: Object<FAOwnerObjConfig>,
        fa_obj: Object<Metadata>,
        max_supply: Option<u128>,
        name: String,
        symbol: String,
        decimals: u8,
        icon_uri: String,
        project_uri: String,
        mint_fee_per_smallest_unit_of_fa: u64,
        pre_mint_amount: u64,
        mint_limit_per_addr: Option<u64>,
    }

    #[event]
    struct MintFAEvent has store, drop {
        fa_obj: Object<Metadata>,
        amount: u64,
        recipient_addr: address,
        total_mint_fee: u64,
    }

    /// Existing structs
    struct FAOwnerObjConfig has key {
        fa_obj: Object<Metadata>,
        extend_ref: ExtendRef,
    }

    struct FAController has key {
        mint_ref: fungible_asset::MintRef,
        burn_ref: fungible_asset::BurnRef,
        transfer_ref: fungible_asset::TransferRef,
    }

    struct MintLimit has store {
        limit: u64,
        mint_balance_tracker: Table<address, u64>,
    }

    struct FAConfig has key {
        mint_fee_per_smallest_unit_of_fa: u64,
        mint_limit: Option<MintLimit>,
        mint_enabled: bool,
        fa_owner_obj: Object<FAOwnerObjConfig>,
        extend_ref: ExtendRef,
    }

    struct Registry has key {
        fa_objects: vector<Object<Metadata>>,
    }

    struct Config has key {
        creator_addr: address,
        admin_addr: address,
        pending_admin_addr: Option<address>,
        mint_fee_collector_addr: address,
    }

    /// New structs for credit system
    struct TransactionHistory has store, drop {
        sender: address,
        receiver: address,
        amount: u64,
        timestamp: u64
    }

    #[event]
    struct TransferEvent has drop, store {
        sender: address,
        receiver: address,
        amount: u64
    }

    struct CreditAccount has key {
        fa_obj: Object<Metadata>,
        balance: fungible_asset::Holder<Metadata>,
        transactions: vector<TransactionHistory>,
    }

    /// Existing initialization
    fun init_module(sender: &signer) {
        move_to(sender, Registry {
            fa_objects: vector::empty()
        });
        move_to(sender, Config {
            creator_addr: @initial_creator_addr,
            admin_addr: signer::address_of(sender),
            pending_admin_addr: option::none(),
            mint_fee_collector_addr: signer::address_of(sender),
        });
    }

    // ================================= Existing Entry Functions ================================= //

    public entry fun update_creator(sender: &signer, new_creator: address) acquires Config {
        let sender_addr = signer::address_of(sender);
        let config = borrow_global_mut<Config>(@launchpad_addr);
        assert!(is_admin(config, sender_addr), EONLY_ADMIN_CAN_UPDATE_CREATOR);
        config.creator_addr = new_creator;
    }

    public entry fun set_pending_admin(sender: &signer, new_admin: address) acquires Config {
        let sender_addr = signer::address_of(sender);
        let config = borrow_global_mut<Config>(@launchpad_addr);
        assert!(is_admin(config, sender_addr), EONLY_ADMIN_CAN_SET_PENDING_ADMIN);
        config.pending_admin_addr = option::some(new_admin);
    }

    public entry fun accept_admin(sender: &signer) acquires Config {
        let sender_addr = signer::address_of(sender);
        let config = borrow_global_mut<Config>(@launchpad_addr);
        assert!(config.pending_admin_addr == option::some(sender_addr), ENOT_PENDING_ADMIN);
        config.admin_addr = sender_addr;
        config.pending_admin_addr = option::none();
    }

    public entry fun update_mint_fee_collector(sender: &signer, new_mint_fee_collector: address) acquires Config {
        let sender_addr = signer::address_of(sender);
        let config = borrow_global_mut<Config>(@launchpad_addr);
        assert!(is_admin(config, sender_addr), EONLY_ADMIN_CAN_UPDATE_MINT_FEE_COLLECTOR);
        config.mint_fee_collector_addr = new_mint_fee_collector;
    }

    public entry fun update_mint_enabled(sender: &signer, fa_obj: Object<Metadata>, enabled: bool) acquires Config, FAConfig {
        let sender_addr = signer::address_of(sender);
        let config = borrow_global_mut<Config>(@launchpad_addr);
        assert!(is_admin(config, sender_addr), EONLY_ADMIN_CAN_UPDATE_MINT_ENABLED);
        let fa_obj_addr = object::object_address(&fa_obj);
        let fa_config = borrow_global_mut<FAConfig>(fa_obj_addr);
        fa_config.mint_enabled = enabled;
    }

    public entry fun create_fa(
        sender: &signer,
        max_supply: Option<u128>,
        name: String,
        symbol: String,
        decimals: u8,
        icon_uri: String,
        project_uri: String,
        mint_fee_per_smallest_unit_of_fa: Option<u64>,
        pre_mint_amount: Option<u64>,
        mint_limit_per_addr: Option<u64>,
    ) acquires Registry, Config, FAController {
        let sender_addr = signer::address_of(sender);
        let config = borrow_global<Config>(@launchpad_addr);
        assert!(is_admin(config, sender_addr) || is_creator(config, sender_addr), EONLY_ADMIN_OR_CREATOR_CAN_CREATE_FA);

        let fa_owner_obj_constructor_ref = &object::create_object(@launchpad_addr);
        let fa_owner_obj_signer = &object::generate_signer(fa_owner_obj_constructor_ref);

        let fa_obj_constructor_ref = &object::create_named_object(
            fa_owner_obj_signer,
            *string::bytes(&name),
        );
        let fa_obj_signer = &object::generate_signer(fa_obj_constructor_ref);

        primary_fungible_store::create_primary_store_enabled_fungible_asset(
            fa_obj_constructor_ref,
            max_supply,
            name,
            symbol,
            decimals,
            icon_uri,
            project_uri
        );
        let fa_obj = object::object_from_constructor_ref(fa_obj_constructor_ref);
        move_to(fa_owner_obj_signer, FAOwnerObjConfig {
            fa_obj,
            extend_ref: object::generate_extend_ref(fa_owner_obj_constructor_ref),
        });
        let fa_owner_obj = object::object_from_constructor_ref(fa_owner_obj_constructor_ref);
        let mint_ref = fungible_asset::generate_mint_ref(fa_obj_constructor_ref);
        let burn_ref = fungible_asset::generate_burn_ref(fa_obj_constructor_ref);
        let transfer_ref = fungible_asset::generate_transfer_ref(fa_obj_constructor_ref);
        move_to(fa_obj_signer, FAController {
            mint_ref,
            burn_ref,
            transfer_ref,
        });
        move_to(fa_obj_signer, FAConfig {
            mint_fee_per_smallest_unit_of_fa: *option::borrow_with_default(
                &mint_fee_per_smallest_unit_of_fa,
                &DEFAULT_mint_fee_per_smallest_unit_of_fa
            ),
            mint_limit: if (option::is_some(&mint_limit_per_addr)) {
                option::some(MintLimit {
                    limit: *option::borrow(&mint_limit_per_addr),
                    mint_balance_tracker: table::new()
                })
            } else {
                option::none()
            },
            mint_enabled: true,
            extend_ref: object::generate_extend_ref(fa_obj_constructor_ref),
            fa_owner_obj,
        });

        let registry = borrow_global_mut<Registry>(@launchpad_addr);
        vector::push_back(&mut registry.fa_objects, fa_obj);

        event::emit(CreateFAEvent {
            creator_addr: sender_addr,
            fa_owner_obj,
            fa_obj,
            max_supply,
            name,
            symbol,
            decimals,
            icon_uri,
            project_uri,
            mint_fee_per_smallest_unit_of_fa: *option::borrow_with_default(
                &mint_fee_per_smallest_unit_of_fa,
                &DEFAULT_mint_fee_per_smallest_unit_of_fa
            ),
            pre_mint_amount: *option::borrow_with_default(&pre_mint_amount, &DEFAULT_PRE_MINT_AMOUNT),
            mint_limit_per_addr,
        });

        if (*option::borrow_with_default(&pre_mint_amount, &DEFAULT_PRE_MINT_AMOUNT) > 0) {
            let amount = *option::borrow(&pre_mint_amount);
            mint_fa_internal(sender, fa_obj, amount, 0);
        }
    }

    public entry fun mint_fa(
        sender: &signer,
        fa_obj: Object<Metadata>,
        amount: u64
    ) acquires FAController, FAConfig, Config {
        assert!(amount > 0, ECANNOT_MINT_ZERO);
        assert!(is_mint_enabled(fa_obj), EMINT_IS_DISABLED);
        let sender_addr = signer::address_of(sender);
        check_mint_limit_and_update_mint_tracker(sender_addr, fa_obj, amount);
        let total_mint_fee = get_mint_fee(fa_obj, amount);
        pay_for_mint(sender, total_mint_fee);
        mint_fa_internal(sender, fa_obj, amount, total_mint_fee);
    }

    // ================================= New Credit System Entry Functions ================================= //

    /// Initialize credit account for a user with a specific fungible asset
    public entry fun initialize_account(sender: &signer, fa_obj: Object<Metadata>) {
        let credit_account = CreditAccount {
            fa_obj,
            balance: fungible_asset::create_holder(&fa_obj),
            transactions: vector::empty<TransactionHistory>()
        };
        move_to(sender, credit_account);
    }

    /// Deposit fungible assets into the credit account
    public entry fun deposit(sender: &signer, fa_obj: Object<Metadata>, amount: u64) acquires CreditAccount {
        let sender_addr = signer::address_of(sender);
        assert!(exists<CreditAccount>(sender_addr), ENOT_INITIALIZED);

        let credit_account = borrow_global_mut<CreditAccount>(sender_addr);
        assert!(credit_account.fa_obj == fa_obj, EWRONG_ASSET);

        let coins = primary_fungible_store::withdraw(sender, fa_obj, amount);
        fungible_asset::deposit(&mut credit_account.balance, coins);
    }

    /// Transfer fungible assets between credit accounts
    public entry fun transfer(
        sender: &signer,
        receiver_addr: address,
        fa_obj: Object<Metadata>,
        amount: u64
    ) acquires CreditAccount {
        let sender_addr = signer::address_of(sender);
        
        // Check if both accounts exist
        assert!(exists<CreditAccount>(sender_addr), ENOT_INITIALIZED);
        assert!(exists<CreditAccount>(receiver_addr), ENOT_INITIALIZED);

        // Check sender's account and balance
        let sender_account = borrow_global_mut<CreditAccount>(sender_addr);
        assert!(sender_account.fa_obj == fa_obj, EWRONG_ASSET);
        assert!(fungible_asset::balance(&sender_account.balance) >= amount, EINSUFFICIENT_BALANCE);

        // Perform transfer
        let coins = fungible_asset::withdraw(&mut sender_account.balance, amount);
        let receiver_account = borrow_global_mut<CreditAccount>(receiver_addr);
        assert!(receiver_account.fa_obj == fa_obj, EWRONG_ASSET);
        fungible_asset::deposit(&mut receiver_account.balance, coins);

        // Record transaction
        let transaction = TransactionHistory {
            sender: sender_addr,
            receiver: receiver_addr,
            amount,
            timestamp: timestamp::now_seconds()
        };

        vector::push_back(&mut sender_account.transactions, copy transaction);
        vector::push_back(&mut receiver_account.transactions, transaction);

        // Emit event
        event::emit(TransferEvent {
            sender: sender_addr,
            receiver: receiver_addr,
            amount
        });
    }

    // ================================= Existing View Functions ================================== //

    #[view]
    public fun get_creator(): address acquires Config {
        let config = borrow_global<Config>(@launchpad_addr);
        config.creator_addr
    }

    #[view]
    public fun get_admin(): address acquires Config {
        let config = borrow_global<Config>(@launchpad_addr);
        config.admin_addr
    }

    #[view]
    public fun get_pending_admin(): Option<address> acquires Config {
        let config = borrow_global<Config>(@launchpad_addr);
        config.pending_admin_addr
    }

    #[view]
    public fun get_mint_fee_collector(): address acquires Config {
        let config = borrow_global<Config>(@launchpad_addr);
        config.mint_fee_collector_addr
    }

    #[view]
    public fun get_registry(): vector<Object<Metadata>> acquires Registry {
        let registry = borrow_global<Registry>(@launchpad_addr);
        registry.fa_objects
    }

    #[view]
    public fun get_fa_objects_metadatas(
        fa_obj: Object<Metadata>
    ): (String, String, u8) {
        let name = fungible_asset::name(fa_obj);
        let symbol = fungible_asset::symbol(fa_obj);
        let decimals = fungible_asset::decimals(fa_obj);
        (symbol, name, decimals)
    }

    #[view]
    public fun get_mint_limit(
        fa_obj: Object<Metadata>,
    ): Option<u64> acquires FAConfig {
        let fa_config = borrow_global<FAConfig>(object::object_address(&fa_obj));
        if (option::is_some(&fa_config.mint_limit)) {
            option::some(option::borrow(&fa_config.mint_limit).limit)
        } else {
            option::none()
        }
    }

    #[view]
    public fun get_mint_balance(
        fa_obj: Object<Metadata>,
        addr: address
    ): u64 acquires FAConfig {
        let fa_config = borrow_global<FAConfig>(object::object_address(&fa_obj));
        assert!(option::is_some(&fa_config.mint_limit), ENO_MINT_LIMIT);
        let mint_limit = option::borrow(&fa_config.mint_limit);
        let mint_tracker = &mint_limit.mint_balance_tracker;
        *table::borrow_with_default(mint_tracker, addr, &mint_limit.limit)
    }

    #[view]
    public fun get_mint_fee(
        fa_obj: Object<Metadata>,
        amount: u64,
    ): u64 acquires FAConfig {
        let fa_config = borrow_global<FAConfig>(object::object_address(&fa_obj));
        amount * fa_config.mint_fee_per_smallest_unit_of_fa
    }

    #[view]
    public fun is_mint_enabled(fa_obj: Object<Metadata>): bool acquires FAConfig {
        let fa_addr = object::object_address(&fa_obj);
        let fa_config = borrow_global<FAConfig>(fa_addr);
        fa_config.mint_enabled
    }

    // ================================= New Credit System View Functions ================================= //

    #[view]
    public fun get_balance(addr: address, fa_obj: Object<Metadata>): u64 acquires CreditAccount {
        assert!(exists<CreditAccount>(addr), ENOT_INITIALIZED);
        let account = borrow_global<CreditAccount>(addr);
        assert!(account.fa_obj == fa_obj, EWRONG_ASSET);
        fungible_asset::balance(&account.balance)
    }

    #[view]
    public fun get_transaction_count(addr: address, fa_obj: Object<Metadata>): u64 acquires CreditAccount {
        assert!(exists<CreditAccount>(addr), ENOT_INITIALIZED);
        let account = borrow_global<CreditAccount>(addr);
        assert!(account.fa_obj == fa_obj, EWRONG_ASSET);
        vector::length(&account.transactions)
    }

    // ================================= Existing Helper Functions ================================== //

    fun is_admin(config: &Config, sender: address): bool {
        if (sender == config.admin_addr) {
            true
        } else {
            if (object::is_object(@launchpad_addr)) {
                let obj = object::address_to_object<ObjectCore>(@launchpad_addr);
                object::is_owner(obj, sender)
            } else {
                false
            }
        }
    }

    fun is_creator(config: &Config, sender: address): bool {
        sender == config.creator_addr
    }

    fun check_mint_limit_and_update_mint_tracker(
        sender: address,
        fa_obj: Object<Metadata>,
        amount: u64,
    ) acquires FAConfig {
        let mint_limit = get_mint_limit(fa_obj);
        if (option::is_some(&mint_limit)) {
            let mint_balance = get_mint_balance(fa_obj, sender);
            assert!(
                mint_balance >= amount,
                EMINT_LIMIT_REACHED,
            );
            let fa_config = borrow_global_mut<FAConfig>(object::object_address(&fa_obj));
            let mint_limit = option::borrow_mut(&mut fa_config.mint_limit);
            table::upsert(&mut mint_limit.mint_balance_tracker, sender, mint_balance - amount)
        }
    }

    fun mint_fa_internal(
        sender: &signer,
        fa_obj: Object<Metadata>,
        amount: u64,
        total_mint_fee: u64,
    ) acquires FAController {
        let sender_addr = signer::address_of(sender);
        let fa_obj_addr = object::object_address(&fa_obj);

        let fa_controller = borrow_global<FAController>(fa_obj_addr);
        primary_fungible_store::mint(&fa_controller.mint_ref, sender_addr, amount);

        event::emit(MintFAEvent {
            fa_obj,
            amount,
            recipient_addr: sender_addr,
            total_mint_fee,
        });
    }

    fun pay_for_mint(
        sender: &signer,
        total_mint_fee: u64
    ) acquires Config {
        if (total_mint_fee > 0) {
            let config = borrow_global<Config>(@launchpad_addr);
            aptos_account::transfer(sender, config.mint_fee_collector_addr, total_mint_fee)
        }
    }

    // ================================= Unit Tests ================================== //

    #[test_only]
    public fun init_module_for_test(sender: &signer) {
        init_module(sender);
    }

    #[test(sender = @0x1, receiver = @0x2)]
    public entry fun test_credit_system(sender: &signer, receiver: &signer) acquires CreditAccount, Config, Registry, FAController, FAConfig {
        // Initialize module
        init_module_for_test(sender);

        // Create a fungible asset
        create_fa(
            sender,
            option::none(),
            string::utf8(b"TestToken"),
            string::utf8(b"TTK"),
            6,
            string::utf8(b""),
            string::utf8(b""),
            option::none(),
            option::some(1000),
            option::none()
        );

        let fa_obj = vector::borrow(&borrow_global<Registry>(@launchpad_addr).fa_objects, 0);

        // Initialize accounts
        initialize_account(sender, *fa_obj);
        initialize_account(receiver, *fa_obj);

        // Deposit tokens
        deposit(sender, *fa_obj, 1000);

        // Transfer tokens
        transfer(sender, signer::address_of(receiver), *fa_obj, 500);

        // Verify balances and transaction count
        assert!(get_balance(signer::address_of(sender), *fa_obj) == 500, 1);
        assert!(get_balance(signer::address_of(receiver), *fa_obj) == 500, 2);
        assert!(get_transaction_count(signer::address_of(sender), *fa_obj) == 1, 3);
    }
}