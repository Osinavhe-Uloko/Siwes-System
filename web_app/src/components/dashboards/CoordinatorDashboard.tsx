import { useEffect, useState } from 'react';
import { collection, getDocs, query, where } from 'firebase/firestore';
import { db } from '../../lib/firebase';
import { Users, AlertTriangle, ShieldCheck, FileText, Activity } from 'lucide-react';
import { PieChart, Pie, Cell, BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer } from 'recharts';
import { Link } from 'react-router-dom';
import { detectMissedEntries } from '../../lib/compliance';

export function CoordinatorDashboard() {
 const [stats, setStats] = useState({
 totalStudents: 0,
 compliant: 0,
 atRisk: 0,
 flagged: 0,
 activeFlags: 0,
 });
 const [flagData, setFlagData] = useState<any[]>([]);
 const [loading, setLoading] = useState(true);

 useEffect(() => {
 const fetchStats = async () => {
 await detectMissedEntries(); // Run detection first
 
 const studentsSnap = await getDocs(query(collection(db, 'users'), where('role', '==', 'student')));
 const flagsSnap = await getDocs(query(collection(db, 'compliance_flags'), where('resolved', '==', false)));
 
 const students = studentsSnap.docs.map(d => ({ id: d.id }));
 const flags = flagsSnap.docs.map(d => d.data());
 
 const flaggedStudentIds = new Set(flags.map(f => f.student_id));
 
 let compliant = 0;
 let flagged = flaggedStudentIds.size;
 let atRisk = 0; // Simplified for demo
 compliant = students.length - flagged - atRisk;

 const flagCounts = flags.reduce((acc: any, curr: any) => {
 acc[curr.flag_type] = (acc[curr.flag_type] || 0) + 1;
 return acc;
 }, {});

 const chartData = Object.keys(flagCounts).map(key => ({
 name: key.replace('_', ' ').toUpperCase(),
 value: flagCounts[key]
 }));

 setStats({
 totalStudents: students.length,
 compliant,
 atRisk,
 flagged,
 activeFlags: flags.length
 });
 setFlagData(chartData);
 setLoading(false);
 };

 fetchStats();
 }, []);

 const COLORS = ['#ef4444', '#f59e0b', '#3b82f6', '#10b981'];

 if (loading) {
 return (
 <div className="flex justify-center p-12">
 <div className="h-8 w-8 animate-spin rounded-full border-b-2 border-primary dark:border-dark-primary"></div>
 </div>
 );
 }

 return (
 <div className="space-y-6">
 <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
 <h1 className="text-2xl font-bold text-text-primary dark:text-dark-text-primary">Monitoring Dashboard</h1>
 <button className="flex items-center justify-center gap-2 rounded-md bg-surface dark:bg-dark-surface px-4 py-2 text-sm font-medium text-text-primary dark:text-dark-text-primary shadow-sm ring-1 ring-inset ring-text-secondary/30 dark:ring-dark-text-secondary/30 hover:bg-background dark:hover:bg-dark-background transition-colors">
 <FileText className="h-4 w-4" />
 Export Report
 </button>
 </div>

 <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
 <div className="rounded-xl bg-surface dark:bg-dark-surface p-6 shadow-sm border border-text-secondary/10 dark:border-dark-text-secondary/10">
 <div className="flex items-center justify-between">
 <div>
 <p className="text-sm font-medium text-text-secondary dark:text-dark-text-secondary">Total Students</p>
 <p className="text-2xl font-bold text-text-primary dark:text-dark-text-primary">{stats.totalStudents}</p>
 </div>
 <div className="rounded-lg bg-primary/20 dark:bg-dark-primary/20 p-3 text-primary dark:text-dark-primary">
 <Users className="h-6 w-6" />
 </div>
 </div>
 </div>

 <div className="rounded-xl bg-surface dark:bg-dark-surface p-6 shadow-sm border border-text-secondary/10 dark:border-dark-text-secondary/10">
 <div className="flex items-center justify-between">
 <div>
 <p className="text-sm font-medium text-text-secondary dark:text-dark-text-secondary">Compliant</p>
 <p className="text-2xl font-bold text-status-approved dark:text-dark-status-approved">{stats.compliant}</p>
 </div>
 <div className="rounded-lg bg-status-approved/20 dark:bg-dark-status-approved/20 p-3 text-status-approved dark:text-dark-status-approved">
 <ShieldCheck className="h-6 w-6" />
 </div>
 </div>
 </div>

 <div className="rounded-xl bg-surface dark:bg-dark-surface p-6 shadow-sm border border-text-secondary/10 dark:border-dark-text-secondary/10">
 <div className="flex items-center justify-between">
 <div>
 <p className="text-sm font-medium text-text-secondary dark:text-dark-text-secondary">Flagged Students</p>
 <p className="text-2xl font-bold text-status-overdue dark:text-dark-status-overdue">{stats.flagged}</p>
 </div>
 <div className="rounded-lg bg-status-overdue/20 dark:bg-dark-status-overdue/20 p-3 text-status-overdue dark:text-dark-status-overdue">
 <AlertTriangle className="h-6 w-6" />
 </div>
 </div>
 </div>

 <div className="rounded-xl bg-surface dark:bg-dark-surface p-6 shadow-sm border border-text-secondary/10 dark:border-dark-text-secondary/10">
 <div className="flex items-center justify-between">
 <div>
 <p className="text-sm font-medium text-text-secondary dark:text-dark-text-secondary">Active Flags</p>
 <p className="text-2xl font-bold text-status-pending dark:text-dark-status-pending">{stats.activeFlags}</p>
 </div>
 <div className="rounded-lg bg-status-pending/20 dark:bg-dark-status-pending/20 p-3 text-status-pending dark:text-dark-status-pending">
 <AlertTriangle className="h-6 w-6" />
 </div>
 </div>
 </div>
 </div>

 <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
 <div className="rounded-xl bg-surface dark:bg-dark-surface p-6 shadow-sm border border-text-secondary/10 dark:border-dark-text-secondary/10">
 <h2 className="text-lg font-medium text-text-primary dark:text-dark-text-primary mb-4">Active Flags by Type</h2>
 <div className="h-64">
 <ResponsiveContainer width="100%" height="100%">
 <PieChart>
 <Pie
 data={flagData}
 cx="50%"
 cy="50%"
 innerRadius={60}
 outerRadius={80}
 paddingAngle={5}
 dataKey="value"
 >
 {flagData.map((entry, index) => (
 <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
 ))}
 </Pie>
 <Tooltip />
 </PieChart>
 </ResponsiveContainer>
 </div>
 <div className="mt-4 flex flex-wrap justify-center gap-4 text-sm">
 {flagData.map((entry, index) => (
 <div key={entry.name} className="flex items-center gap-2">
 <div className="h-3 w-3 rounded-full" style={{ backgroundColor: COLORS[index % COLORS.length] }} />
 <span className="text-text-secondary dark:text-dark-text-secondary">{entry.name} ({entry.value})</span>
 </div>
 ))}
 </div>
 </div>

 <div className="rounded-xl bg-surface dark:bg-dark-surface shadow-sm border border-text-secondary/10 dark:border-dark-text-secondary/10 flex flex-col">
 <div className="border-b border-text-secondary/10 dark:border-dark-text-secondary/10 p-6 flex justify-between items-center">
 <h2 className="text-lg font-medium text-text-primary dark:text-dark-text-primary">Recent Flags needing review</h2>
 <Link to="/dashboard/flags" className="text-sm font-medium text-primary dark:text-dark-primary hover:text-primary dark:hover:text-dark-primary">
 View All
 </Link>
 </div>
 <div className="flex-1 p-6 flex items-center justify-center">
 <p className="text-text-secondary dark:text-dark-text-secondary text-sm">Use the Flags page to monitor and resolve specific incidents.</p>
 </div>
 </div>
 </div>
 </div>
 );
}
