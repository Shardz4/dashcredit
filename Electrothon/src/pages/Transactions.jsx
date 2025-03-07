import React from "react";
import TransactionItem from "../components/TransactionItem"; 

export default function Transactions() {
  const transactionData = [
    {
        sender: "0x1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6",
        receiver: "0x2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p",
        amount: 100,
        timestamp: 1677654321,
    },
    {
        sender: "0x1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6",
        receiver: "0x2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p",
        amount: -100,
        timestamp: 1677654321,
    },
  ];

  const formatTime = (timestamp) => {
    return new Date(timestamp * 1000).toLocaleTimeString("en-US", {
      hour: "2-digit",
      minute: "2-digit",
      hour12: true,
    });
  };

  return (
    <div className="flex flex-col items-center min-h-screen ">
      <h1 className="m-3 text-4xl font-bold text-gray-50">Transactions</h1>
      <div className="w-full max-w-md">
        {transactionData.map((tx, index) => (
          <TransactionItem
            key={index}
            recipient={tx.receiver} // Using receiver as the recipient in the UI
            type={tx.amount < 0 ? "Debit" : "Credit"} // Determine type based on amount
            amount={Math.abs(tx.amount)} // Use absolute value for display
            time={formatTime(tx.timestamp)}
          />
        ))}
      </div>
    </div>
  );
}