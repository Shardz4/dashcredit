import React, { useState } from "react";

const SendCreditsForm = ({ onClose }) => {
  const [walletAddress, setWalletAddress] = useState("");
  const [amount, setAmount] = useState("");

  const handleSubmit = (e) => {
    e.preventDefault();
    console.log("Sending to:", walletAddress);
    console.log("Amount:", amount);

    if (!walletAddress || !amount) {
      alert("Please fill in all fields!");
      return;
    }

    // Backend call can be added here

    onClose(); // Close the form after submission
  };

  return (
    <div className="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50">
      <div className="bg-white p-6 rounded-lg shadow-lg w-96">
        <h2 className="text-xl font-bold mb-4 text-gray-900 justify-center">Send Credits</h2> 

        <form onSubmit={handleSubmit}>
          <div className="mb-3">
            <label className="block text-gray-900 font-medium">Wallet Address</label> {/* Darker Text */}
            <input
              type="text"
              value={walletAddress}
              onChange={(e) => {
                console.log("Wallet Address:", e.target.value); // Debugging
                setWalletAddress(e.target.value);
              }}
              className="w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 text-gray-900" // Darker Input Text
              required
            />
          </div>

          <div className="mb-4">
            <label className="block text-gray-900 font-medium">Amount (INR)</label> {/* Darker Text */}
            <input
              type="number"
              value={amount}
              onChange={(e) => {
                console.log("Amount:", e.target.value); // Debugging
                setAmount(e.target.value);
              }}
              className="w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 text-gray-900" // Darker Input Text
              required
            />
          </div>

          <div className="flex justify-between">
            <button type="submit" className="px-4 py-2 bg-blue-500 text-white rounded-md hover:bg-blue-600">
              Send
            </button>
            <button type="button" onClick={onClose} className="px-4 py-2 bg-gray-300 text-gray-900 rounded-md hover:bg-gray-400">
              Cancel
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default SendCreditsForm;
