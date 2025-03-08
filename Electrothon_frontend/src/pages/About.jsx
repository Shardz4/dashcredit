import React, { useState } from "react";

const About = () => {
  // State to hold profile image URL (default profile picture)
  const [profilePic, setProfilePic] = useState(
    "https://via.placeholder.com/150/808080/FFFFFF?text=Profile"
  );

  return (
    <div style={{ 
      color: "#f9fafb", 
      display: "flex", 
      flexDirection: "column", 
      alignItems: "center", 
      justifyContent: "center", 
      minHeight: "100vh" 
    }}>
      {/* Profile Image */}
      <img
        src={profilePic}
        alt="Profile"
        style={{
          width: "128px",
          height: "128px",
          border: "4px solid #d1d5db",
          boxShadow: "0 4px 6px rgba(0, 0, 0, 0.1)",
        }}
      />

      <h1 style={{ margin: "12px", fontSize: "32px", fontWeight: "bold" }}>
        About Page
      </h1>

      <div style={{ marginBottom: "16px", display: "flex", gap: "10px" }}>
        <button
          style={{
            width: "240px",
            padding: "10px 0",
            backgroundColor: "white",
            color: "#374151",
            fontWeight: "600",
            borderRadius: "9999px",
            border: "1px solid #d1d5db",
            cursor: "pointer",
            transition: "0.3s"
          }}
          onMouseOver={(e) => (e.target.style.backgroundColor = "#d1d5db")}
          onMouseOut={(e) => (e.target.style.backgroundColor = "white")}
        >
          <a href="/payments" style={{ textDecoration: "none", color: "inherit" }}>
            Payments
          </a>
        </button>

        <button
          style={{
            width: "240px",
            padding: "10px 0",
            backgroundColor: "white",
            color: "#374151",
            fontWeight: "600",
            borderRadius: "9999px",
            border: "1px solid #d1d5db",
            cursor: "pointer",
            transition: "0.3s"
          }}
          onMouseOver={(e) => (e.target.style.backgroundColor = "#d1d5db")}
          onMouseOut={(e) => (e.target.style.backgroundColor = "white")}
        >
          <a href="/transactions" style={{ textDecoration: "none", color: "inherit" }}>
            Transactions
          </a>
        </button>
      </div>
    </div>
  );
};

export default About;
