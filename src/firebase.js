import { initializeApp } from "firebase/app";
import { getFirestore } from "firebase/firestore"
import { collection, addDoc, getDocs } from "@firebase/firestore"; // Update this


// Your web app's Firebase configuration
const firebaseConfig = {
  apiKey: "AIzaSyB0Cj4Rc69DXAjPwAgKrvSV3VHTCNJHE4I",
  authDomain: "my-portfolio-44aed.firebaseapp.com",
  projectId: "my-portfolio-44aed",
  storageBucket: "my-portfolio-44aed.firebasestorage.app",
  messagingSenderId: "878374228632",
  appId: "1:878374228632:web:de0b7943e8c0a3635b76ed",
  measurementId: "G-KR18W9FZCK"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

export { db, collection, addDoc };