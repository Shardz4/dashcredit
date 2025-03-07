import React from "react";
import { FaArrowUp } from "react-icons/fa"; // Arrow icon for debit (you can add a different one for credit)

const TransactionItem = ({ recipient, type, amount, time }) => {
  return (
    <div className="flex items-center justify-between p-4 bg-gray-600 rounded-lg mb-2">
      {/* Left side: Icon, Recipient, and Type */}
      <div className="flex items-center">
        <div className="w-10 h-10 bg-white rounded-md flex items-center justify-center mr-3">
          <FaArrowUp
            className={`text-lg ${type === "Debit" ? "text-black" : "text-black"}`} // Adjust color if needed
          />
        </div>
        <div>
          <p className="text-gray-800 font-semibold">{recipient}</p>
          <p className="text-sm text-gray-200">{type}</p>
        </div>
      </div>

      {/* Right side: Amount and Time */}
      <div className="text-right">
        <p
          className={`font-semibold ${
            type === "Debit" ? "text-red-500" : "text-green-500"
          }`}
        >
          {type === "Debit" ? "-" : "+"}
          {amount}
        </p>
        <p className="text-sm text-gray-500">{time}</p>
      </div>
    </div>
  );
};

export default TransactionItem;