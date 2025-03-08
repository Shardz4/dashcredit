import React, { useState } from "react";
import { Navigate } from "react-router-dom"; // Import Navigate for redirection
import { doSignInWithEmailAndPassword } from "../firebase/auth";
import { useAuth } from "../Contexts/authContext";

const LoginPage = () => {
  const { userLoggedIn } = useAuth();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [isSigningIn, setIsSigningIn] = useState(false); // Fixed variable name (IsSigningIn -> isSigningIn)
  const [errorMessage, setErrorMessage] = useState("");

  const handleSubmit = async (e) => { // Added async keyword
    e.preventDefault();
    if (!isSigningIn) {
      setIsSigningIn(true);
      try {
        await doSignInWithEmailAndPassword(email, password);
        // If successful, userLoggedIn will update via useAuth, triggering redirect
      } catch (error) {
        setErrorMessage(error.message || "Login failed. Please try again.");
        setIsSigningIn(false);
      }
    }
  };

  // If user is logged in, redirect to /about
  if (userLoggedIn) {
    return <Navigate to="/About" replace />;
  }

  // Otherwise, render the login page
  return (
    <div
      style={{
        display: "flex",
        justifyContent: "center",
        alignItems: "center",
        height: "100vh",
        backgroundColor: "#000",
        color: "#fff",
      }}
    >
      <div
        style={{
          width: "380px",
          padding: "40px",
          backgroundColor: "#121212",
          borderRadius: "10px",
          boxShadow: "0 0 10px rgba(255, 255, 255, 0.1)",
          textAlign: "center",
        }}
      >
        <h1
          style={{
            fontSize: "28px",
            fontWeight: "bold",
            marginBottom: "20px",
          }}
        >
          Sign in to DashCredits
        </h1>
        {errorMessage && (
          <div
            style={{
              color: "#ff4444",
              marginBottom: "15px",
              fontSize: "14px",
            }}
          >
            {errorMessage}
          </div>
        )}
        <form onSubmit={handleSubmit}>
          <div style={{ marginBottom: "15px", textAlign: "left" }}>
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
              placeholder="Email"
              disabled={isSigningIn}
              style={{
                width: "100%",
                padding: "12px",
                fontSize: "16px",
                backgroundColor: "#222",
                color: "#fff",
                border: "1px solid #444",
                borderRadius: "5px",
                outline: "none",
              }}
            />
          </div>
          <div style={{ marginBottom: "15px", textAlign: "left" }}>
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              placeholder="Password"
              disabled={isSigningIn}
              style={{
                width: "100%",
                padding: "12px",
                fontSize: "16px",
                backgroundColor: "#222",
                color: "#fff",
                border: "1px solid #444",
                borderRadius: "5px",
                outline: "none",
              }}
            />
          </div>
          <button
            type="submit"
            disabled={isSigningIn}
            style={{
              width: "100%",
              padding: "12px",
              backgroundColor: isSigningIn ? "#aaa" : "#1D9BF0",
              color: "white",
              border: "none",
              borderRadius: "25px",
              fontSize: "16px",
              fontWeight: "bold",
              cursor: isSigningIn ? "not-allowed" : "pointer",
            }}
          >
            {isSigningIn ? "Signing In..." : "Log in"}
          </button>
        </form>

        <div style={{ marginTop: "15px", fontSize: "14px" }}>
          <a
            href="#"
            style={{ color: "#1D9BF0", textDecoration: "none" }}
          >
            Forgot password?
          </a>
        </div>
        <div style={{ marginTop: "10px", fontSize: "14px" }}>
          Don't have an account?{" "}
          <a
            href="#"
            style={{ color: "#1D9BF0", textDecoration: "none" }}
          >
            Sign up
          </a>
        </div>
      </div>
    </div>
  );
};

export default LoginPage;