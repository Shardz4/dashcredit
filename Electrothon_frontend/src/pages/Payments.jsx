import React, { useState } from "react";
import SendCreditsForm from "../components/SendCreditsForm";

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
    <div
      style={{
        color: "#F9FAFB", // text-gray-50
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        minHeight: "100vh",
        fontSize: "1rem", 
      }}
    >
      <h1 style={{ margin: "0.5rem" }}>{userId}</h1>
      <h1
        style={{
          fontSize: "3.5rem", // text-4xl
          fontWeight: "700", // font-bold
        }}
      >
        Available Credits: 1000 INR
      </h1>

      <div
        style={{
          marginBottom: "1rem",
          margin: "0.75rem",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          gap: "0.25rem",
        }}
      >
        <button
          style={{
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            width: "15rem", // w-60 (240px)
            padding: "0.5rem", // py-2
            backgroundColor: "#FFFFFF", // bg-white
            color: "#4B5563", // text-gray-700
            fontWeight: "600", // font-semibold
            borderRadius: "9999px", // rounded-full
            border: "1px solid #D1D5DB", // border-gray-300
          }}
          onMouseOver={(e) => (e.target.style.backgroundColor = "#D1D5DB")} // hover:bg-gray-300
          onMouseOut={(e) => (e.target.style.backgroundColor = "#FFFFFF")}
          onClick={() => setShowForm(true)}
        >
          Send
        </button>

        <button
          style={{
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            width: "15rem", // w-60 (240px)
            padding: "0.5rem", // py-2
            backgroundColor: "#FFFFFF", // bg-white
            color: "#4B5563", // text-gray-700
            fontWeight: "600", // font-semibold
            borderRadius: "9999px", // rounded-full
            border: "1px solid #D1D5DB", // border-gray-300
          }}
          onMouseOver={(e) => (e.target.style.backgroundColor = "#D1D5DB")} // hover:bg-gray-300
          onMouseOut={(e) => (e.target.style.backgroundColor = "#FFFFFF")}
          onClick={onReceive}
        >
          Receive
        </button>
      </div>

      {/* Conditionally show QR Code */}
      {showQR && (
        <div style={{ marginTop: "1.5rem" }}>
          <h2
            style={{
              fontSize: "1.5rem", // text-2xl
              fontWeight: "700", // font-bold
            }}
          >
            User QR Code
          </h2>
          <img
            src={qrCodeUrl}
            alt="QR Code"
            style={{
              marginTop: "0.5rem",
              height: "12.5rem", // h-50 (200px)
              width: "12.5rem", // w-50 (200px)
            }}
          />
        </div>
      )}

      {/* Show Send Credits Form */}
      {showForm && <SendCreditsForm onClose={() => setShowForm(false)} />}
    </div>
  );
}