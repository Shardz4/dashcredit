# DashCredit

DashCredit is a decentralized platform designed to become a university's effort to increase their student's productivity by leveraging blockchain technology. By utilizing smart contracts, DashCredit aims to provide transparent, secure, and efficient solution to increase participation by giving participants a reward for what they do whcih they can then exchange indie their own institution.

## Features
- *Multi-Platform accessibility*: Works on both android and ios devices along with website (currently locally deployed)
- *Decentralized Credit Management*: Eliminates intermediaries, allowing direct interactions between lenders and borrowers.
- *Smart Contracts*: Automates agreements, ensuring trust and reducing potential disputes.
- *Transparency*: All transactions are recorded on the  Aptos blockchain, promoting openness and accountability.
- *Security*: Utilizes blockchain's inherent security features to protect user data and transactions.

## Repository Structure

- *DashCredits/*: Contains the core smart contract code written in Move language.
- *Electrothon_frontend/*: Frontend application developed using React and TypeScript.
- *contract/*: Smart contract deployment scripts and related configurations.
  

## Technologies Used

- *Move*: A safe and flexible programming language for smart contracts.
- *Flutter*: An easy to build framework for mobile applications
- *Firebase*: A secure authentication gateway for users
- *React*: JavaScript library for building user interfaces.
- *CSS & HTML*: For styling and structuring the web application.

## Getting Started

1. *Clone the repository*:

   bash
   git clone https://github.com/Shardz4/dashcredit.git
   cd dashcredit
2. **Navigate to Electrothon-frontend**:
   bash
   cd Electrothon-frontend
   npm install
   npm run dev
   
3. *Comile move code*:
  ```bash
    aptos move compile
    aptos move publish --package-dir . --profile default
