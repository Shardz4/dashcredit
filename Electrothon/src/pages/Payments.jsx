import React, { useState } from "react";
import SendCreditsForm from "../components/SendCreditsForm"; // Import Send Form Component

export default function Payment() {
  const userId = "0x1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6";
  const qrCodeUrl = `https://res.cloudinary.com/dgxbpno1j/image/upload/v1741385116/Untitled_1_cmgsta.png`;

  // State to control QR code visibility
  const [showQR, setShowQR] = useState(false);
  // State to control Send Credits Form visibility
  const [showForm, setShowForm] = useState(false);

  function onReceive() {
    setShowQR(true); // Show QR Code
  }

  return (
    <div className="text-gray-50 flex flex-col items-center justify-center min-h-screen">
      <h1 className="m-2">{userId}</h1>
      <h1 className="text-4xl font-bold">Available Credits: 1000 INR</h1>

      <div className="mb-4 m-3 flex items-center justify-center gap-1">
        <button
          className="flex items-center justify-center w-60 py-2 bg-white text-gray-700 font-semibold rounded-full border border-gray-300 hover:bg-gray-300"
          onClick={() => setShowForm(true)}
        >
          Send
        </button>

        <button
          className="flex items-center justify-center w-60 py-2 bg-white text-gray-700 font-semibold rounded-full border border-gray-300 hover:bg-gray-300"
          onClick={onReceive}
        >
          Receive
        </button>
      </div>

      {/* Conditionally show QR Code */}
      {showQR && (
        <div className="mt-6">
          <h2 className="text-2xl font-bold">User QR Code</h2>
          <img src={qrCodeUrl} alt="QR Code" className="mt-2 h-50 w-50" />
        </div>
      )}

      {/* Show Send Credits Form */}
      {showForm && <SendCreditsForm onClose={() => setShowForm(false)} />}
    </div>
  );
}
