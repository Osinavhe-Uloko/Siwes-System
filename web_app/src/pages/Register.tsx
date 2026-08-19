import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { createUserWithEmailAndPassword } from 'firebase/auth';
import { auth, db } from '../lib/firebase';
import { doc, setDoc } from 'firebase/firestore';


export function Register() {
 const [formData, setFormData] = useState({
 name: '',
 email: '',
 phone: '',
 password: '',
 matric_number: '',
 department: '',
 level: '',
 });
 const [error, setError] = useState('');
 const [loading, setLoading] = useState(false);
 const navigate = useNavigate();

 const handleRegister = async (e: React.FormEvent) => {
 e.preventDefault();
 setError('');
 setLoading(true);

 try {
 const userCredential = await createUserWithEmailAndPassword(auth, formData.email, formData.password);
 const uid = userCredential.user.uid;

 await setDoc(doc(db, 'users', uid), {
 name: formData.name,
 email: formData.email,
 phone: formData.phone,
 role: 'student',
 created_at: Date.now(),
 matric_number: formData.matric_number,
 department: formData.department,
 level: formData.level,
 });

 navigate('/dashboard');
 } catch (err: any) {
 if (err.code === 'auth/operation-not-allowed') {
 setError('Email/Password authentication is not enabled in this Firebase project. Please enable it in the Firebase Console -> Authentication -> Sign-in method.');
 } else {
 setError(err.message || 'Failed to register');
 }
 } finally {
 setLoading(false);
 }
 };

 const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
 setFormData(prev => ({ ...prev, [e.target.name]: e.target.value }));
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
 Start your industrial attachment on the right track.
 </h1>
 <p className="text-lg text-text-secondary dark:text-dark-text-secondary leading-relaxed">
 Create an account to securely log your daily activities, track compliance, and stay connected with your supervisors.
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
 <div className="flex w-full lg:w-1/2 items-center justify-center p-8 sm:p-12 lg:p-16 bg-background dark:bg-dark-background overflow-y-auto">
 <div className="w-full max-w-md space-y-8 my-auto">
 <div className="lg:hidden flex items-center justify-center gap-3 mb-8">
 <img src="/logo.jpg" alt="ITF Logo" className="h-10 w-10 rounded-full object-contain bg-white p-1" />
 <span className="text-2xl font-bold tracking-tight text-text-primary dark:text-dark-text-primary">SIWES Monitor</span>
 </div>

 <div>
 <h2 className="text-3xl font-bold tracking-tight text-text-primary dark:text-dark-text-primary mb-2">Create an account</h2>
 <p className="text-text-secondary dark:text-dark-text-secondary">Register as a student to begin logging your SIWES activities.</p>
 </div>
 
 <form className="space-y-6" onSubmit={handleRegister}>
 {error && (
 <div className="rounded-lg bg-status-overdue/10 dark:bg-dark-status-overdue/10 p-4 text-sm text-status-overdue dark:text-dark-status-overdue border border-status-overdue/20 dark:border-dark-status-overdue/20 flex items-start">
 <span className="block sm:inline">{error}</span>
 </div>
 )}
 
 <div className="grid grid-cols-1 sm:grid-cols-2 gap-5">
 <div className="sm:col-span-2">
 <label className="block text-sm font-medium text-text-primary dark:text-dark-text-primary mb-1.5" htmlFor="name">Full Name</label>
 <input
 id="name"
 name="name"
 type="text"
 required
 value={formData.name}
 onChange={handleChange}
 className="block w-full rounded-xl border-0 py-2.5 px-4 text-text-primary dark:text-dark-text-primary shadow-sm ring-1 ring-inset ring-text-secondary/30 dark:ring-dark-text-secondary/30 focus:ring-2 focus:ring-inset focus:ring-primary dark:focus:ring-dark-primary sm:text-sm transition-shadow"
 placeholder="John Doe"
 />
 </div>
 
 <div className="sm:col-span-2">
 <label className="block text-sm font-medium text-text-primary dark:text-dark-text-primary mb-1.5" htmlFor="email">Email</label>
 <input
 id="email"
 name="email"
 type="email"
 required
 value={formData.email}
 onChange={handleChange}
 className="block w-full rounded-xl border-0 py-2.5 px-4 text-text-primary dark:text-dark-text-primary shadow-sm ring-1 ring-inset ring-text-secondary/30 dark:ring-dark-text-secondary/30 focus:ring-2 focus:ring-inset focus:ring-primary dark:focus:ring-dark-primary sm:text-sm transition-shadow"
 placeholder="name@example.com"
 />
 </div>

 <div>
 <label className="block text-sm font-medium text-text-primary dark:text-dark-text-primary mb-1.5" htmlFor="matric_number">Matric Number</label>
 <input
 id="matric_number"
 name="matric_number"
 type="text"
 required
 value={formData.matric_number}
 onChange={handleChange}
 className="block w-full rounded-xl border-0 py-2.5 px-4 text-text-primary dark:text-dark-text-primary shadow-sm ring-1 ring-inset ring-text-secondary/30 dark:ring-dark-text-secondary/30 focus:ring-2 focus:ring-inset focus:ring-primary dark:focus:ring-dark-primary sm:text-sm transition-shadow"
 placeholder="CSC/19/001"
 />
 </div>

 <div>
 <label className="block text-sm font-medium text-text-primary dark:text-dark-text-primary mb-1.5" htmlFor="phone">Phone Number</label>
 <input
 id="phone"
 name="phone"
 type="tel"
 required
 value={formData.phone}
 onChange={handleChange}
 className="block w-full rounded-xl border-0 py-2.5 px-4 text-text-primary dark:text-dark-text-primary shadow-sm ring-1 ring-inset ring-text-secondary/30 dark:ring-dark-text-secondary/30 focus:ring-2 focus:ring-inset focus:ring-primary dark:focus:ring-dark-primary sm:text-sm transition-shadow"
 placeholder="08000000000"
 />
 </div>

 <div>
 <label className="block text-sm font-medium text-text-primary dark:text-dark-text-primary mb-1.5" htmlFor="department">Department</label>
 <input
 id="department"
 name="department"
 type="text"
 required
 value={formData.department}
 onChange={handleChange}
 className="block w-full rounded-xl border-0 py-2.5 px-4 text-text-primary dark:text-dark-text-primary shadow-sm ring-1 ring-inset ring-text-secondary/30 dark:ring-dark-text-secondary/30 focus:ring-2 focus:ring-inset focus:ring-primary dark:focus:ring-dark-primary sm:text-sm transition-shadow"
 placeholder="Computer Science"
 />
 </div>

 <div>
 <label className="block text-sm font-medium text-text-primary dark:text-dark-text-primary mb-1.5" htmlFor="level">Level</label>
 <select
 id="level"
 name="level"
 required
 value={formData.level}
 onChange={handleChange}
 className="block w-full rounded-xl border-0 py-2.5 px-4 text-text-primary dark:text-dark-text-primary shadow-sm ring-1 ring-inset ring-text-secondary/30 dark:ring-dark-text-secondary/30 focus:ring-2 focus:ring-inset focus:ring-primary dark:focus:ring-dark-primary sm:text-sm transition-shadow bg-surface dark:bg-dark-surface"
 >
 <option value="">Select Level</option>
 <option value="300">300 Level</option>
 <option value="400">400 Level</option>
 <option value="500">500 Level</option>
 </select>
 </div>

 <div className="sm:col-span-2">
 <label className="block text-sm font-medium text-text-primary dark:text-dark-text-primary mb-1.5" htmlFor="password">Password</label>
 <input
 id="password"
 name="password"
 type="password"
 required
 value={formData.password}
 onChange={handleChange}
 className="block w-full rounded-xl border-0 py-2.5 px-4 text-text-primary dark:text-dark-text-primary shadow-sm ring-1 ring-inset ring-text-secondary/30 dark:ring-dark-text-secondary/30 focus:ring-2 focus:ring-inset focus:ring-primary dark:focus:ring-dark-primary sm:text-sm transition-shadow"
 placeholder="••••••••"
 />
 </div>
 </div>

 <div>
 <button
 type="submit"
 disabled={loading}
 className="flex w-full justify-center rounded-xl bg-primary dark:bg-dark-primary px-4 py-3.5 text-sm font-semibold text-white shadow-sm hover:bg-primary/90 dark:hover:bg-dark-primary/90 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-600 disabled:opacity-70 transition-all"
 >
 {loading ? 'Registering...' : 'Create Account'}
 </button>
 </div>
 
 <div className="text-center text-sm pt-2">
 <span className="text-text-secondary dark:text-dark-text-secondary">Already have an account? </span>
 <Link to="/login" className="font-semibold text-primary dark:text-dark-primary hover:text-primary dark:hover:text-dark-primary transition-colors">
 Sign in
 </Link>
 </div>
 </form>
 </div>
 </div>
 </div>
 );
}
