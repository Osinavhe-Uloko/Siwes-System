import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { signInWithEmailAndPassword } from 'firebase/auth';
import { auth, db } from '../lib/firebase';
import { doc, getDoc } from 'firebase/firestore';
import { useAuth } from '../contexts/AuthContext';
import { User } from '../types';
import { seedDatabase } from '../lib/seed';


export function Login() {
 const [email, setEmail] = useState('');
 const [password, setPassword] = useState('');
 const [error, setError] = useState('');
 const [loading, setLoading] = useState(false);
 const navigate = useNavigate();
 const { setUser } = useAuth();

 const handleLogin = async (e: React.FormEvent) => {
 e.preventDefault();
 setError('');
 setLoading(true);

 try {
 const userCredential = await signInWithEmailAndPassword(auth, email, password);
 const docRef = doc(db, 'users', userCredential.user.uid);
 const docSnap = await getDoc(docRef);
 
 if (docSnap.exists()) {
 setUser({ id: docSnap.id, ...docSnap.data() } as User);
 navigate('/dashboard');
 } else {
 setError('User profile not found in database.');
 auth.signOut();
 }
 } catch (err: any) {
 if (err.code === 'auth/operation-not-allowed') {
 setError('Email/Password authentication is not enabled in this Firebase project. Please enable it in the Firebase Console -> Authentication -> Sign-in method.');
 } else {
 setError(err.message || 'Failed to login');
 }
 } finally {
 setLoading(false);
 }
 };

 return (
 <div className="flex min-h-screen font-sans bg-surface dark:bg-dark-surface">
 {/* Left side - Image/Branding */}
 <div className="hidden lg:flex lg:w-1/2 relative bg-primary dark:bg-dark-primary p-12 text-white overflow-hidden flex-col justify-between">
 <div className="absolute inset-0 opacity-10">
 <div className="absolute top-0 left-0 w-full h-full bg-[radial-gradient(circle_at_top_right,_var(--tw-gradient-stops))] from-blue-400 via-slate-900 to-slate-900"></div>
 </div>
 
 <div className="relative z-10">
 <Link to="/" className="flex items-center gap-3">
 <img src="/logo.jpg" alt="ITF Logo" className="h-10 w-10 rounded-full object-contain bg-white p-1" />
 <span className="text-2xl font-bold tracking-tight">SIWES Monitor</span>
 </Link>
 </div>

 <div className="relative z-10 max-w-xl">
 <h1 className="text-5xl font-bold leading-tight mb-6 tracking-tight">
 Active monitoring for a smarter attachment process.
 </h1>
 <p className="text-lg text-text-secondary dark:text-dark-text-secondary leading-relaxed">
 Ensure integrity, track compliance, and manage student logbooks in real-time. Join thousands of coordinators and supervisors enforcing standards effortlessly.
 </p>
 </div>
 
 <div className="relative z-10 flex gap-4 text-sm text-text-secondary dark:text-dark-text-secondary">
 <span>&copy; {new Date().getFullYear()} SIWES Monitor</span>
 <span className="mx-2">•</span>
 <a href="#" className="hover:text-white transition-colors">Privacy</a>
 <span className="mx-2">•</span>
 <a href="#" className="hover:text-white transition-colors">Terms</a>
 </div>
 </div>

 {/* Right side - Form */}
 <div className="flex w-full lg:w-1/2 items-center justify-center p-8 sm:p-12 lg:p-24 bg-background dark:bg-dark-background">
 <div className="w-full max-w-md space-y-10">
 <div className="lg:hidden flex items-center justify-center gap-3 mb-12">
 <img src="/logo.jpg" alt="ITF Logo" className="h-10 w-10 rounded-full object-contain bg-white p-1" />
 <span className="text-2xl font-bold tracking-tight text-text-primary dark:text-dark-text-primary">SIWES Monitor</span>
 </div>

 <div>
 <h2 className="text-3xl font-bold tracking-tight text-text-primary dark:text-dark-text-primary mb-2">Welcome back</h2>
 <p className="text-text-secondary dark:text-dark-text-secondary">Please enter your details to sign in.</p>
 </div>
 
 <form className="space-y-6" onSubmit={handleLogin}>
 {error && (
 <div className="rounded-lg bg-status-overdue/10 dark:bg-dark-status-overdue/10 p-4 text-sm text-status-overdue dark:text-dark-status-overdue border border-status-overdue/20 dark:border-dark-status-overdue/20 flex items-start">
 <span className="block sm:inline">{error}</span>
 </div>
 )}
 
 <div className="space-y-4">
 <div>
 <label className="block text-sm font-medium text-text-primary dark:text-dark-text-primary mb-1.5" htmlFor="email">Email</label>
 <input
 id="email"
 type="email"
 required
 value={email}
 onChange={(e) => setEmail(e.target.value)}
 className="block w-full rounded-xl border-0 py-3 px-4 text-text-primary dark:text-dark-text-primary shadow-sm ring-1 ring-inset ring-text-secondary/30 dark:ring-dark-text-secondary/30 placeholder:text-slate-400 focus:ring-2 focus:ring-inset focus:ring-primary dark:focus:ring-dark-primary sm:text-sm sm:leading-6 transition-shadow"
 placeholder="name@example.com"
 />
 </div>
 <div>
 <label className="block text-sm font-medium text-text-primary dark:text-dark-text-primary mb-1.5" htmlFor="password">Password</label>
 <input
 id="password"
 type="password"
 required
 value={password}
 onChange={(e) => setPassword(e.target.value)}
 className="block w-full rounded-xl border-0 py-3 px-4 text-text-primary dark:text-dark-text-primary shadow-sm ring-1 ring-inset ring-text-secondary/30 dark:ring-dark-text-secondary/30 placeholder:text-slate-400 focus:ring-2 focus:ring-inset focus:ring-primary dark:focus:ring-dark-primary sm:text-sm sm:leading-6 transition-shadow"
 placeholder="••••••••"
 />
 </div>
 </div>

 <div className="flex items-center justify-between">
 <div className="flex items-center">
 <input id="remember-me" name="remember-me" type="checkbox" className="h-4 w-4 rounded border-text-secondary/30 dark:border-dark-text-secondary/30 text-primary dark:text-dark-primary focus:ring-primary dark:focus:ring-dark-primary" />
 <label htmlFor="remember-me" className="ml-2 block text-sm text-text-primary dark:text-dark-text-primary">Remember me</label>
 </div>
 <div className="text-sm">
 <a href="#" className="font-semibold text-primary dark:text-dark-primary hover:text-primary dark:hover:text-dark-primary">Forgot password?</a>
 </div>
 </div>

 <div>
 <button
 type="submit"
 disabled={loading}
 className="flex w-full justify-center rounded-xl bg-primary dark:bg-dark-primary px-4 py-3.5 text-sm font-semibold text-white shadow-sm hover:bg-primary/90 dark:hover:bg-dark-primary/90 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-600 disabled:opacity-70 transition-all"
 >
 {loading ? 'Signing in...' : 'Sign In'}
 </button>
 </div>
 
 <div className="text-center text-sm pt-2">
 <span className="text-text-secondary dark:text-dark-text-secondary">Don't have an account? </span>
 <Link to="/register" className="font-semibold text-primary dark:text-dark-primary hover:text-primary dark:hover:text-dark-primary transition-colors">
 Register as Student
 </Link>
 </div>
 </form>

 <div className="mt-12 rounded-xl border border-text-secondary/20 dark:border-dark-text-secondary/20 bg-surface dark:bg-dark-surface p-6 shadow-sm">
 <h3 className="text-sm font-bold text-text-primary dark:text-dark-text-primary mb-3 uppercase tracking-wider">Demo Access</h3>
 <div className="space-y-3 text-sm text-text-secondary dark:text-dark-text-secondary">
 <div className="flex justify-between items-center border-b border-text-secondary/10 dark:border-dark-text-secondary/10 pb-2">
 <span className="font-medium">Coordinator</span>
 <span className="font-mono bg-background dark:bg-dark-background px-2 py-0.5 rounded text-xs">admin@uni.edu</span>
 </div>
 <div className="flex justify-between items-center border-b border-text-secondary/10 dark:border-dark-text-secondary/10 pb-2">
 <span className="font-medium">Inst. Supervisor</span>
 <span className="font-mono bg-background dark:bg-dark-background px-2 py-0.5 rounded text-xs">prof.smith@uni.edu</span>
 </div>
 <div className="flex justify-between items-center border-b border-text-secondary/10 dark:border-dark-text-secondary/10 pb-2">
 <span className="font-medium">Ind. Supervisor</span>
 <span className="font-mono bg-background dark:bg-dark-background px-2 py-0.5 rounded text-xs">manager@techcorp.com</span>
 </div>
 <div className="flex justify-between items-center">
 <span className="font-medium">Student</span>
 <span className="font-mono bg-background dark:bg-dark-background px-2 py-0.5 rounded text-xs">john.doe@student.edu</span>
 </div>
 </div>
 <div className="mt-4 pt-4 border-t border-text-secondary/10 dark:border-dark-text-secondary/10">
 <button 
 onClick={async () => {
 setLoading(true);
 await seedDatabase();
 setLoading(false);
 alert('Database seeded!');
 }}
 disabled={loading}
 className="w-full rounded-lg bg-background dark:bg-dark-background px-4 py-2.5 text-sm font-medium text-text-primary dark:text-dark-text-primary hover:bg-background dark:hover:bg-dark-background transition-colors flex items-center justify-center gap-2"
 >
 {loading ? 'Processing...' : 'Seed Initial Demo Data'}
 </button>
 <p className="text-xs text-center text-text-secondary dark:text-dark-text-secondary mt-2">Password for all accounts is: <span className="font-mono font-bold">password123</span></p>
 </div>
 </div>
 </div>
 </div>
 </div>
 );
}
