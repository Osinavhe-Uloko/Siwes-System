import { useState, useEffect } from 'react';
import { collection, query, where, getDocs } from 'firebase/firestore';
import { db } from '../lib/firebase';
import { User } from '../types';
import { Link } from 'react-router-dom';
import { Search, GraduationCap, Building2 } from 'lucide-react';

export function Students() {
 const [students, setStudents] = useState<User[]>([]);
 const [loading, setLoading] = useState(true);
 const [searchTerm, setSearchTerm] = useState('');

 useEffect(() => {
 const fetchStudents = async () => {
 try {
 const q = query(collection(db, 'users'), where('role', '==', 'student'));
 const snapshot = await getDocs(q);
 const data = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() } as User));
 setStudents(data);
 } catch (error) {
 console.error('Error fetching students:', error);
 } finally {
 setLoading(false);
 }
 };
 fetchStudents();
 }, []);

 const filteredStudents = students.filter(s => 
 s.name.toLowerCase().includes(searchTerm.toLowerCase()) || 
 s.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
 (s.matric_number && s.matric_number.toLowerCase().includes(searchTerm.toLowerCase()))
 );

 return (
 <div className="space-y-6">
 <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
 <div>
 <h2 className="text-2xl font-bold tracking-tight text-text-primary dark:text-dark-text-primary">Students</h2>
 <p className="mt-1 text-sm text-text-secondary dark:text-dark-text-secondary">
 Monitor and manage students on industrial attachment.
 </p>
 </div>
 <div className="relative">
 <div className="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3">
 <Search className="h-4 w-4 text-text-secondary dark:text-dark-text-secondary" />
 </div>
 <input
 type="text"
 className="block w-full sm:w-64 rounded-xl border-0 py-2 pl-10 pr-3 text-text-primary dark:text-dark-text-primary ring-1 ring-inset ring-text-secondary/30 dark:ring-dark-text-secondary/30 placeholder:text-slate-400 focus:ring-2 focus:ring-inset focus:ring-primary dark:focus:ring-dark-primary sm:text-sm sm:leading-6"
 placeholder="Search students..."
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
 <div className="bg-surface dark:bg-dark-surface rounded-2xl border border-text-secondary/20 dark:border-dark-text-secondary/20 shadow-sm overflow-hidden">
 <div className="overflow-x-auto">
 <table className="min-w-full divide-y divide-slate-200">
 <thead className="bg-background dark:bg-dark-background">
 <tr>
 <th scope="col" className="px-6 py-3 text-left text-xs font-semibold text-text-secondary dark:text-dark-text-secondary uppercase tracking-wider">
 Student Info
 </th>
 <th scope="col" className="px-6 py-3 text-left text-xs font-semibold text-text-secondary dark:text-dark-text-secondary uppercase tracking-wider">
 Academic Details
 </th>
 <th scope="col" className="px-6 py-3 text-left text-xs font-semibold text-text-secondary dark:text-dark-text-secondary uppercase tracking-wider">
 Status
 </th>
 <th scope="col" className="relative px-6 py-3">
 <span className="sr-only">Actions</span>
 </th>
 </tr>
 </thead>
 <tbody className="divide-y divide-slate-200 bg-surface dark:bg-dark-surface">
 {filteredStudents.map((student) => (
 <tr key={student.id} className="hover:bg-background dark:hover:bg-dark-background transition-colors">
 <td className="px-6 py-4 whitespace-nowrap">
 <div className="flex items-center">
 <div className="h-10 w-10 flex-shrink-0 rounded-full bg-primary/20 dark:bg-dark-primary/20 flex items-center justify-center text-primary dark:text-dark-primary font-bold">
 {student.name.charAt(0)}
 </div>
 <div className="ml-4">
 <div className="text-sm font-medium text-text-primary dark:text-dark-text-primary">{student.name}</div>
 <div className="text-sm text-text-secondary dark:text-dark-text-secondary">{student.email}</div>
 </div>
 </div>
 </td>
 <td className="px-6 py-4 whitespace-nowrap">
 <div className="text-sm text-text-primary dark:text-dark-text-primary flex items-center gap-2">
 <GraduationCap className="h-4 w-4 text-text-secondary dark:text-dark-text-secondary" />
 {student.matric_number || 'N/A'}
 </div>
 <div className="text-sm text-text-secondary dark:text-dark-text-secondary mt-1">{student.department || 'N/A'} • {student.level || 'N/A'}L</div>
 </td>
 <td className="px-6 py-4 whitespace-nowrap">
 <span className="inline-flex items-center gap-1.5 rounded-full bg-status-approved/10 dark:bg-dark-status-approved/10 px-2.5 py-1 text-xs font-medium text-status-approved dark:text-dark-status-approved ring-1 ring-inset ring-status-approved dark:ring-dark-status-approved/20">
 <span className="h-1.5 w-1.5 rounded-full bg-emerald-500"></span>
 Active
 </span>
 </td>
 <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
 <Link to={`/dashboard/students/${student.id}`} className="text-primary dark:text-dark-primary hover:text-primary dark:hover:text-dark-primary font-semibold">
 View Profile
 </Link>
 </td>
 </tr>
 ))}
 {filteredStudents.length === 0 && (
 <tr>
 <td colSpan={4} className="px-6 py-12 text-center text-text-secondary dark:text-dark-text-secondary">
 No students found matching your search.
 </td>
 </tr>
 )}
 </tbody>
 </table>
 </div>
 </div>
 )}
 </div>
 );
}
