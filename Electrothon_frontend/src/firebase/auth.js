import {auth} from './firebase';
import { createUserWithEmailAndPassword, GoogleAuthProvider, sendEmailVerification } from 'firebase/auth';

export const doCreateUserWithEmailAndPassword = async(email, password) =>{
    return createUserWithEmailAndPassword(auth, email, password);
};

export const doSignInWithEmailAndPassword = async() =>{
    const provider=new GoogleAuthProvider();
    const result=await signInWithPopup(auth,provider);

    //result.user
    return result;
};

export const doSignOut=()=>{
    return auth.signOut();
}

// export const doPasswordChange=(password)=>{
//     return updatePassword(auth.currentUser,password);
// }

// export const doPasswordReset=(email)=>{
//     return sendPasswordResetEmail(auth,email);
// }

// export const doSendEmailVerification=()=>{
//     return sendEmailVerification(auth.currentUser,{
//         url:`${Windows.location.origin}/login`,
//     });
// }