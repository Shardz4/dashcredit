import React from "react";
import { FaArrowUp } from "react-icons/fa"; // Arrow icon for debit

const TransactionItem = ({ recipient, type, amount, time }) => {
  return (
    <div
      style={{
        display: "flex",
        alignItems: "center",
        justifyContent: "space-between",
        padding: "16px",
        backgroundColor: "#4b5563",
        borderRadius: "8px",
        marginBottom: "8px",
      }}
    >
      {/* Left side: Icon, Recipient, and Type */}
      <div style={{ display: "flex", alignItems: "center" }}>
        <div
          style={{
            width: "40px",
            height: "40px",
            backgroundColor: "white",
            borderRadius: "6px",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            marginRight: "12px",
          }}
        >
          <FaArrowUp style={{ fontSize: "18px", color: "black" }} />
        </div>
        <div>
          <p style={{ color: "#1f2937", fontWeight: "600", margin: 0 }}>{recipient}</p>
          <p style={{ fontSize: "14px", color: "#e5e7eb", margin: 0 }}>{type}</p>
        </div>
      </div>

      {/* Right side: Amount and Time */}
      <div style={{ textAlign: "right" }}>
        <p
          style={{
            fontWeight: "600",
            color: type === "Debit" ? "#ef4444" : "#10b981",
            margin: 0,
          }}
        >
          {type === "Debit" ? "-" : "+"} {amount}
        </p>
        <p style={{ fontSize: "14px", color: "#6b7280", margin: 0 }}>{time}</p>
      </div>
    </div>
  );
};

export default TransactionItem;
