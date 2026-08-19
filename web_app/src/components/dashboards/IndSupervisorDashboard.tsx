import { useAuth } from '../../contexts/AuthContext';
import { useEffect, useState } from 'react';
import { collection, query, where, getDocs } from 'firebase/firestore';
import { db } from '../../lib/firebase';

export function IndSupervisorDashboard() {
 const { user } = useAuth();
 const [placements, setPlacements] = useState<any[]>([]);

 useEffect(() => {
 if (!user) return;
 const fetchPlacements = async () => {
 const q = query(collection(db, 'placements'), where('industry_supervisor_id', '==', user.id));
 const snap = await getDocs(q);
 setPlacements(snap.docs.map(d => ({ id: d.id, ...d.data() })));
 };
 fetchPlacements();
 }, [user]);

 return (
 <div className="space-y-6">
 <h1 className="text-2xl font-bold text-text-primary dark:text-dark-text-primary">Industry Supervisor Dashboard</h1>
 
 <div className="rounded-xl bg-surface dark:bg-dark-surface shadow-sm border border-text-secondary/10 dark:border-dark-text-secondary/10">
 <div className="border-b border-text-secondary/10 dark:border-dark-text-secondary/10 p-6">
 <h2 className="text-lg font-medium text-text-primary dark:text-dark-text-primary">Students on Placement</h2>
 </div>
 <div className="divide-y divide-slate-100">
 {placements.length === 0 ? (
 <div className="p-8 text-center text-sm text-text-secondary dark:text-dark-text-secondary">No students currently assigned to you.</div>
 ) : (
 placements.map(placement => (
 <div key={placement.id} className="p-4">
 <p className="text-sm font-medium text-text-primary dark:text-dark-text-primary">Student ID: {placement.student_id}</p>
 <p className="text-sm text-text-secondary dark:text-dark-text-secondary">Started: {placement.start_date}</p>
 </div>
 ))
 )}
 </div>
 </div>
 </div>
 );
}
