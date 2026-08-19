import { useEffect, useState } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { collection, query, where, getDocs, doc, updateDoc, documentId } from 'firebase/firestore';
import { db } from '../lib/firebase';
import { format } from 'date-fns';
import { AlertTriangle, CheckCircle, Clock } from 'lucide-react';

export function Flags() {
 const { user } = useAuth();
 const [flags, setFlags] = useState<any[]>([]);
 const [loading, setLoading] = useState(true);

 const fetchFlags = async () => {
 let q;
 if (user?.role === 'coordinator') {
 q = query(collection(db, 'compliance_flags'), where('resolved', '==', false));
 } else {
 // For institution supervisors, ideally we only fetch flags for their assigned students,
 // but for simplicity here we just fetch all unresolved if they have access.
 q = query(collection(db, 'compliance_flags'), where('resolved', '==', false));
 }

 const snap = await getDocs(q);
 
 // Fetch student info for each flag
 const flagsData = await Promise.all(snap.docs.map(async (d) => {
 const data = d.data() as any;
 const studentDoc = await getDocs(query(collection(db, 'users'), where(documentId(), '==', data.student_id)));
 const studentName = studentDoc.empty ? 'Unknown Student' : studentDoc.docs[0].data().name;
 return { id: d.id, ...data, studentName };
 }));
 
 setFlags(flagsData.sort((a, b) => b.detected_at - a.detected_at));
 setLoading(false);
 };

 useEffect(() => {
 fetchFlags();
 }, [user]);

 const handleResolve = async (flagId: string) => {
 const note = prompt('Enter resolution note:');
 if (note === null) return;
 
 try {
 await updateDoc(doc(db, 'compliance_flags', flagId), {
 resolved: true,
 resolved_by: user?.id,
 resolution_note: note || 'Resolved by ' + user?.name
 });
 fetchFlags();
 } catch (err) {
 console.error(err);
 alert('Failed to resolve flag');
 }
 };

 if (loading) {
 return (
 <div className="flex justify-center p-12">
 <div className="h-8 w-8 animate-spin rounded-full border-b-2 border-primary dark:border-dark-primary"></div>
 </div>
 );
 }

 return (
 <div className="space-y-6">
 <h1 className="text-2xl font-bold text-text-primary dark:text-dark-text-primary">Compliance Flags</h1>

 <div className="rounded-xl bg-surface dark:bg-dark-surface shadow-sm border border-text-secondary/20 dark:border-dark-text-secondary/20">
 <div className="border-b border-text-secondary/20 dark:border-dark-text-secondary/20 p-6 flex justify-between items-center">
 <h2 className="text-lg font-medium text-text-primary dark:text-dark-text-primary">Active Incidents</h2>
 </div>
 <div className="divide-y divide-slate-200">
 {flags.length === 0 ? (
 <div className="p-8 text-center text-sm text-text-secondary dark:text-dark-text-secondary">
 <CheckCircle className="mx-auto h-12 w-12 text-status-approved dark:text-dark-status-approved mb-2" />
 No active compliance flags. All good!
 </div>
 ) : (
 flags.map(flag => (
 <div key={flag.id} className="p-6 flex flex-col sm:flex-row sm:items-start justify-between gap-4 hover:bg-background dark:hover:bg-dark-background">
 <div className="flex gap-4">
 <div className="mt-1">
 {flag.flag_type === 'backdated_cluster' && <AlertTriangle className="h-6 w-6 text-red-500" />}
 {flag.flag_type === 'missed_entry' && <Clock className="h-6 w-6 text-status-pending dark:text-dark-status-pending" />}
 {flag.flag_type === 'overdue_review' && <Clock className="h-6 w-6 text-yellow-500" />}
 </div>
 <div>
 <h3 className="text-base font-medium text-text-primary dark:text-dark-text-primary">
 {flag.flag_type.replace('_', ' ').toUpperCase()}
 </h3>
 <p className="text-sm text-text-secondary dark:text-dark-text-secondary mt-1">
 Student: <span className="font-medium text-text-primary dark:text-dark-text-primary">{flag.studentName}</span>
 </p>
 <p className="text-xs text-text-secondary dark:text-dark-text-secondary mt-1">
 Detected: {format(new Date(flag.detected_at), 'MMM d, yyyy h:mm a')}
 </p>
 </div>
 </div>
 <button
 onClick={() => handleResolve(flag.id)}
 className="rounded-md bg-surface dark:bg-dark-surface px-3 py-1.5 text-sm font-medium text-text-primary dark:text-dark-text-primary shadow-sm ring-1 ring-inset ring-text-secondary/30 dark:ring-dark-text-secondary/30 hover:bg-background dark:hover:bg-dark-background"
 >
 Mark Resolved
 </button>
 </div>
 ))
 )}
 </div>
 </div>
 </div>
 );
}
