import React from "react";

const Header = () => {
  return (
    <header
      style={{
        display: "flex",
        alignItems: "center",
        justifyContent: "space-between",
        padding: "15px 30px",
        backgroundColor: "#121212",
        color: "#fff",
        boxShadow: "0 2px 10px rgba(0,0,0,0.2)",
      }}
    >
      {/* Left: Profile DP */}
      <img
        src="https://via.placeholder.com/40"
        alt="Profile"
        style={{
          width: "40px",
          height: "40px",
          borderRadius: "50%",
          objectFit: "cover",
          cursor: "pointer",
        }}
      />

      {/* Center: Heading */}
      <h1 style={{ fontSize: "22px", fontWeight: "bold" }}>DashCredit</h1>

      {/* Right: Logout Button */}
      <button
        style={{
          padding: "8px 15px",
          backgroundColor: "white",
          color: "black",
          border: "none",
          borderRadius: "5px",
          cursor: "pointer",
          fontWeight: "bold",
        }}
        onClick={() => alert("Logging out...")}
      >
        Logout
      </button>
    </header>
  );
};

export default Header;
