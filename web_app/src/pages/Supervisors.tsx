import { useState, useEffect } from 'react';
import { collection, query, where, getDocs } from 'firebase/firestore';
import { db } from '../lib/firebase';
import { User } from '../types';
import { Search, UserCheck, Shield } from 'lucide-react';

export function Supervisors() {
 const [supervisors, setSupervisors] = useState<User[]>([]);
 const [loading, setLoading] = useState(true);
 const [searchTerm, setSearchTerm] = useState('');

 useEffect(() => {
 const fetchSupervisors = async () => {
 try {
 const q = query(
 collection(db, 'users'),
 where('role', 'in', ['institution_supervisor', 'industry_supervisor'])
 );
 const snapshot = await getDocs(q);
 const data = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() } as User));
 setSupervisors(data);
 } catch (error) {
 console.error('Error fetching supervisors:', error);
 } finally {
 setLoading(false);
 }
 };
 fetchSupervisors();
 }, []);

 const filteredSupervisors = supervisors.filter(s => 
 s.name.toLowerCase().includes(searchTerm.toLowerCase()) || 
 s.email.toLowerCase().includes(searchTerm.toLowerCase())
 );

 return (
 <div className="space-y-6">
 <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
 <div>
 <h2 className="text-2xl font-bold tracking-tight text-text-primary dark:text-dark-text-primary">Supervisors</h2>
 <p className="mt-1 text-sm text-text-secondary dark:text-dark-text-secondary">
 Manage industry and institutional supervisors.
 </p>
 </div>
 <div className="relative">
 <div className="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3">
 <Search className="h-4 w-4 text-text-secondary dark:text-dark-text-secondary" />
 </div>
 <input
 type="text"
 className="block w-full sm:w-64 rounded-xl border-0 py-2 pl-10 pr-3 text-text-primary dark:text-dark-text-primary ring-1 ring-inset ring-text-secondary/30 dark:ring-dark-text-secondary/30 placeholder:text-slate-400 focus:ring-2 focus:ring-inset focus:ring-primary dark:focus:ring-dark-primary sm:text-sm sm:leading-6"
 placeholder="Search supervisors..."
 value={searchTerm}
 onChange={(e) => setSearchTerm(e.target.value)}
 />
 </div>
 </div>

 {loading ? (
 <div className="flex justify-center p-12">
 <div className="h-8 w-8 animate-spin rounded-full border-b-2 border-primary dark:border-dark-primary"></div>
 </div>
 ) : (
 <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
 {filteredSupervisors.map((supervisor) => (
 <div key={supervisor.id} className="bg-surface dark:bg-dark-surface rounded-2xl p-6 shadow-sm border border-text-secondary/20 dark:border-dark-text-secondary/20 flex flex-col">
 <div className="flex items-start justify-between mb-4">
 <div className="h-12 w-12 rounded-full bg-background dark:bg-dark-background flex items-center justify-center text-text-secondary dark:text-dark-text-secondary font-bold text-lg">
 {supervisor.name.charAt(0)}
 </div>
 <span className={`inline-flex items-center gap-1 rounded-full px-2.5 py-1 text-xs font-medium ring-1 ring-inset ${
 supervisor.role === 'institution_supervisor' 
 ? 'bg-primary/10 dark:bg-dark-primary/10 text-primary dark:text-dark-primary ring-primary dark:ring-dark-primary/20'
 : 'bg-indigo-50 text-indigo-700 ring-indigo-600/20'
 }`}>
 {supervisor.role === 'institution_supervisor' ? <UserCheck className="h-3 w-3" /> : <Shield className="h-3 w-3" />}
 {supervisor.role === 'institution_supervisor' ? 'Institution' : 'Industry'}
 </span>
 </div>
 
 <div className="flex-1">
 <h3 className="text-base font-bold text-text-primary dark:text-dark-text-primary truncate">{supervisor.name}</h3>
 <p className="text-sm text-text-secondary dark:text-dark-text-secondary truncate mb-1">{supervisor.email}</p>
 <p className="text-xs text-text-secondary dark:text-dark-text-secondary">{supervisor.phone}</p>
 </div>

 <div className="mt-6 pt-4 border-t border-text-secondary/10 dark:border-dark-text-secondary/10">
 <button className="w-full rounded-lg bg-surface dark:bg-dark-surface px-3 py-2 text-sm font-semibold text-text-primary dark:text-dark-text-primary shadow-sm ring-1 ring-inset ring-text-secondary/30 dark:ring-dark-text-secondary/30 hover:bg-background dark:hover:bg-dark-background transition-colors">
 View Details
 </button>
 </div>
 </div>
 ))}

 {filteredSupervisors.length === 0 && (
 <div className="col-span-full py-12 text-center text-text-secondary dark:text-dark-text-secondary bg-surface dark:bg-dark-surface rounded-2xl border border-text-secondary/20 dark:border-dark-text-secondary/20">
 No supervisors found matching your search.
 </div>
 )}
 </div>
 )}
 </div>
 );
}
