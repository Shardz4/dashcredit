import React from 'react';
import { BrowserRouter, Routes, Route } from "react-router-dom";
import About from './pages/About';
import Payments from './pages/Payments';
import Transactions from './pages/Transactions';
// import Login from './pages/LoginPage';
import Header from './components/Header';

const App = () => {
  return (
    <BrowserRouter>
    <Header />
      <Routes>
        {/* <Route path="/login" element={<Login />} /> */}
        <Route path="/" element={<About />} />
        <Route path="/payments" element={<Payments />} />
        <Route path="/transactions" element={<Transactions />} />
      </Routes>
    </BrowserRouter>
  );
};

export default App;  
