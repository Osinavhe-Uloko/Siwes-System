import React, { createContext, useContext, useEffect, useState } from 'react';
import { onAuthStateChanged, signOut as fbSignOut } from 'firebase/auth';
import { doc, getDoc } from 'firebase/firestore';
import { auth, db } from '../lib/firebase';
import { User } from '../types';

interface AuthContextType {
 user: User | null;
 loading: boolean;
 signOut: () => Promise<void>;
 setUser: (user: User | null) => void;
}

const AuthContext = createContext<AuthContextType>({ 
 user: null, 
 loading: true, 
 signOut: async () => {},
 setUser: () => {}
});

export const AuthProvider = ({ children }: { children: React.ReactNode }) => {
 const [user, setUser] = useState<User | null>(null);
 const [loading, setLoading] = useState(true);

 useEffect(() => {
 const unsubscribe = onAuthStateChanged(auth, async (firebaseUser) => {
 if (firebaseUser) {
 const docRef = doc(db, 'users', firebaseUser.uid);
 const docSnap = await getDoc(docRef);
 if (docSnap.exists()) {
 setUser({ id: docSnap.id, ...docSnap.data() } as User);
 } else {
 setUser(null);
 }
 } else {
 setUser(null);
 }
 setLoading(false);
 });
 return () => unsubscribe();
 }, []);

 const signOut = async () => {
 await fbSignOut(auth);
 };

 return <AuthContext.Provider value={{ user, loading, signOut, setUser }}>{children}</AuthContext.Provider>;
};

export const useAuth = () => useContext(AuthContext);
