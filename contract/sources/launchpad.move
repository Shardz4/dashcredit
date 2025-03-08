module 0x1234::launchpad {
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

    /// Default constants from launchpad
    const DEFAULT_PRE_MINT_AMOUNT: u64 = 0;
    const DEFAULT_mint_fee_per_smallest_unit_of_fa: u64 = 0;

    /// Existing event structs
    #[event]
    /// Event emitted when a new fungible asset is created
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
    /// Event emitted when fungible assets are minted
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

    /// Initialize the module
    fun init_module(sender: &signer) {
        move_to(sender, Registry {
            fa_objects: vector::empty()
        });
        move_to(sender, Config {
            creator_addr: @0x1,  // Hardcoded initial creator address
            admin_addr: signer::address_of(sender),
            pending_admin_addr: option::none(),
            mint_fee_collector_addr: signer::address_of(sender),
        });
    }

    // ================================= Existing Entry Functions ================================= //

    public entry fun update_creator(_sender: &signer, _new_creator: address) {
        // Stubbed out: No-op
    }

    public entry fun set_pending_admin(_sender: &signer, _new_admin: address) {
        // Stubbed out: No-op
    }

    public entry fun accept_admin(_sender: &signer) {
        // Stubbed out: No-op
    }

    public entry fun update_mint_fee_collector(_sender: &signer, _new_mint_fee_collector: address) {
        // Stubbed out: No-op
    }

    public entry fun update_mint_enabled(_sender: &signer, _fa_obj: Object<Metadata>, _enabled: bool) {
        // Stubbed out: No-op
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
        let config = borrow_global<Config>(@0x1234);
        assert!(is_admin(config, sender_addr) || is_creator(config, sender_addr), EONLY_ADMIN_OR_CREATOR_CAN_CREATE_FA);

        let fa_owner_obj_constructor_ref = &object::create_object(@0x1234);
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

        let registry = borrow_global_mut<Registry>(@0x1234);
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

    // ================================= Existing View Functions ================================= //

    #[view]
    public fun get_creator(): address {
        @0x0 // Dummy return
    }

    #[view]
    public fun get_admin(): address {
        @0x0 // Dummy return
    }

    #[view]
    public fun get_pending_admin(): Option<address> {
        option::none() // Dummy return
    }

    #[view]
    public fun get_mint_fee_collector(): address {
        @0x0 // Dummy return
    }

    #[view]
    public fun get_registry(): vector<Object<Metadata>> acquires Registry {
        let registry = borrow_global<Registry>(@0x1234);
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
        _fa_obj: Object<Metadata>,
    ): Option<u64> {
        option::none() // Dummy return
    }

    #[view]
    public fun get_mint_balance(
        _fa_obj: Object<Metadata>,
        _addr: address
    ): u64 {
        0 // Dummy return
    }

    #[view]
    public fun get_mint_fee(
        _fa_obj: Object<Metadata>,
        _amount: u64,
    ): u64 {
        0 // Dummy return
    }

    #[view]
    public fun is_mint_enabled(_fa_obj: Object<Metadata>): bool {
        true // Dummy return
    }

    // ================================= Existing Helper Functions ================================= //

    fun is_admin(config: &Config, sender: address): bool {
        if (sender == config.admin_addr) {
            true
        } else {
            if (object::is_object(@0x1234)) {
                let obj = object::address_to_object<ObjectCore>(@0x1234);
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
            let config = borrow_global<Config>(@0x1234);
            aptos_account::transfer(sender, config.mint_fee_collector_addr, total_mint_fee)
        }
    }

    // ================================= Unit Tests ================================= //

    #[test_only]
    public fun init_module_for_test(sender: &signer) {
        init_module(sender);
    }
}