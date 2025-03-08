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
    <div
      style={{
        position: "fixed",
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        backgroundColor: "rgba(0, 0, 0, 0.5)", // bg-black bg-opacity-50
      }}
    >
      <div
        style={{
          backgroundColor: "#FFFFFF", // bg-white
          padding: "1.5rem", // p-6
          borderRadius: "0.5rem", // rounded-lg
          boxShadow: "0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05)", // shadow-lg
          width: "24rem", // w-96 (384px)
        }}
      >
        <h2
          style={{
            fontSize: "1.25rem", // text-xl
            fontWeight: "700", // font-bold
            marginBottom: "1rem", // mb-4
            color: "#111827", // text-gray-900
            textAlign: "center", // justify-center (interpreted as text alignment)
          }}
        >
          Send Credits
        </h2>

        <form onSubmit={handleSubmit}>
          <div style={{ marginBottom: "0.75rem" /* mb-3 */ }}>
            <label
              style={{
                display: "block",
                color: "#111827", // text-gray-900
                fontWeight: "500", // font-medium
              }}
            >
              Wallet Address
            </label>
            <input
              type="text"
              value={walletAddress}
              onChange={(e) => {
                console.log("Wallet Address:", e.target.value); // Debugging
                setWalletAddress(e.target.value);
              }}
              style={{
                width: "100%", // w-full
                padding: "0.5rem 0.75rem", // px-3 py-2
                border: "1px solid #D1D5DB", // border (gray-300)
                borderRadius: "0.375rem", // rounded-md
                outline: "none", // focus:outline-none
                color: "#111827", // text-gray-900
              }}
              onFocus={(e) => (e.target.style.boxShadow = "0 0 0 2px #3B82F6")} // focus:ring-2 focus:ring-blue-500
              onBlur={(e) => (e.target.style.boxShadow = "none")}
              required
            />
          </div>

          <div style={{ marginBottom: "1rem" /* mb-4 */ }}>
            <label
              style={{
                display: "block",
                color: "#111827", // text-gray-900
                fontWeight: "500", // font-medium
              }}
            >
              Amount (INR)
            </label>
            <input
              type="number"
              value={amount}
              onChange={(e) => {
                console.log("Amount:", e.target.value); // Debugging
                setAmount(e.target.value);
              }}
              style={{
                width: "100%", // w-full
                padding: "0.5rem 0.75rem", // px-3 py-2
                border: "1px solid #D1D5DB", // border (gray-300)
                borderRadius: "0.375rem", // rounded-md
                outline: "none", // focus:outline-none
                color: "#111827", // text-gray-900
              }}
              onFocus={(e) => (e.target.style.boxShadow = "0 0 0 2px #3B82F6")} // focus:ring-2 focus:ring-blue-500
              onBlur={(e) => (e.target.style.boxShadow = "none")}
              required
            />
          </div>

          <div
            style={{
              display: "flex",
              justifyContent: "space-between", // flex justify-between
            }}
          >
            <button
              type="submit"
              style={{
                padding: "0.5rem 1rem", // px-4 py-2
                backgroundColor: "#3B82F6", // bg-blue-500
                color: "#FFFFFF", // text-white
                borderRadius: "0.375rem", // rounded-md
                border: "none",
              }}
              onMouseOver={(e) => (e.target.style.backgroundColor = "#2563EB")} // hover:bg-blue-600
              onMouseOut={(e) => (e.target.style.backgroundColor = "#3B82F6")}
            >
              Send
            </button>
            <button
              type="button"
              onClick={onClose}
              style={{
                padding: "0.5rem 1rem", // px-4 py-2
                backgroundColor: "#D1D5DB", // bg-gray-300
                color: "#111827", // text-gray-900
                borderRadius: "0.375rem", // rounded-md
                border: "none",
              }}
              onMouseOver={(e) => (e.target.style.backgroundColor = "#9CA3AF")} // hover:bg-gray-400
              onMouseOut={(e) => (e.target.style.backgroundColor = "#D1D5DB")}
            >
              Cancel
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default SendCreditsForm;