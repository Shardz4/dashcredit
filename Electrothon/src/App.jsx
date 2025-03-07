import React from 'react';
import { BrowserRouter, Routes, Route } from "react-router-dom";
import About from './pages/about';
import Payments from './pages/Payments';
import Transactions from './pages/Transactions';

const App = () => {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<About />} />
        <Route path="/payments" element={<Payments />} />
        <Route path="/transactions" element={<Transactions />} />
      </Routes>
    </BrowserRouter>
  );
};

export default App;  
