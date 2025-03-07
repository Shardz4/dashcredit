import React, { useState } from "react";

const About = () => {
  // State to hold profile image URL (default profile picture)
  const [profilePic, setProfilePic] = useState(
    "https://via.placeholder.com/150/808080/FFFFFF?text=Profile"
  );

  return (
    <div className="text-gray-50 flex flex-col items-center justify-center min-h-screen">
      {/* Profile Image (default or uploaded) */}
      <img
        src={profilePic}
        alt="Profile"
        className="w-32 h-32  border-4 border-gray-300 shadow-lg"
      />

      <h1 className="m-3 text-4xl font-bold">About Page</h1>

      <div className="mb-4 m-3 flex items-center justify-center gap-2">
        <button className="flex items-center justify-center w-60 py-2 bg-white text-gray-700 font-semibold rounded-full border border-gray-300 hover:bg-gray-300">
          <a href="/payments">Payments</a>
        </button>
        <button className="flex items-center justify-center w-60 py-2 bg-white text-gray-700 font-semibold rounded-full border border-gray-300 hover:bg-gray-300">
          <a href="/transactions">Transactions</a>
        </button>
      </div>
    </div>
  );
};

export default About;
