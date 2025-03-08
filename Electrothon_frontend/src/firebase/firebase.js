// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import {getAuth} from "firebase/auth";
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
const firebaseConfig = {
  apiKey: "AIzaSyANFpwVHwRzxEdCQNINne4GdVDdU2SghSI",
  authDomain: "dashcredits.firebaseapp.com",
  projectId: "dashcredits",
  storageBucket: "dashcredits.firebasestorage.app",
  messagingSenderId: "669380654036",
  appId: "1:669380654036:web:6459f71ae6a9713dee1c41"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
export {app,auth}