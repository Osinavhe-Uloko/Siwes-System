import { useAuth } from '../../contexts/AuthContext';
import { useEffect, useState } from 'react';
import { collection, query, where, getDocs } from 'firebase/firestore';
import { db } from '../../lib/firebase';
import { Link } from 'react-router-dom';
import { Users, AlertCircle } from 'lucide-react';

export function InstSupervisorDashboard() {
 const { user } = useAuth();
 const [students, setStudents] = useState<any[]>([]);
  const [flagCount, setFlagCount] = useState(0);

 useEffect(() => {
 if (!user) return;
 const fetchStudents = async () => {
 const q = query(collection(db, 'users'), where('role', '==', 'student')); // simplified for demo so all registered students appear
 const snap = await getDocs(q);
 
      setStudents(snap.docs.map(d => ({ id: d.id, ...d.data() })));
      
      if (snap.docs.length > 0) {
        const studentIds = snap.docs.map(d => d.id);
        // Firestore 'in' query supports up to 10 items, good enough for this prototype
        // Better yet, just fetch all unresolved flags and filter, or fetch per student.
        // Let's do it simply by fetching all compliance flags and filtering by studentIds
        const flagsQ = query(collection(db, 'compliance_flags'), where('resolved', '==', false));
        const flagsSnap = await getDocs(flagsQ);
        let count = 0;
        flagsSnap.docs.forEach(doc => {
          if (studentIds.includes(doc.data().student_id)) count++;
        });
        setFlagCount(count);
      }

 };
 fetchStudents();
 }, [user]);

 return (
 <div className="space-y-6">
 <h1 className="text-2xl font-bold text-text-primary dark:text-dark-text-primary">Institution Supervisor Dashboard</h1>
 
 <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
 <div className="rounded-xl bg-surface dark:bg-dark-surface p-6 shadow-sm border border-text-secondary/10 dark:border-dark-text-secondary/10">
 <div className="flex items-center justify-between">
 <div>
 <p className="text-sm font-medium text-text-secondary dark:text-dark-text-secondary">Assigned Students</p>
 <p className="text-2xl font-bold text-text-primary dark:text-dark-text-primary">{students.length}</p>
 </div>
 <div className="rounded-lg bg-primary/20 dark:bg-dark-primary/20 p-3 text-primary dark:text-dark-primary">
 <Users className="h-6 w-6" />
 </div>
 </div>
 </div>
 
 <div className="rounded-xl bg-surface dark:bg-dark-surface p-6 shadow-sm border border-status-overdue/20 dark:border-dark-status-overdue/20">
 <div className="flex items-center justify-between">
 <div>
 <p className="text-sm font-medium text-text-secondary dark:text-dark-text-secondary">Flags to Review</p>
 <p className="text-2xl font-bold text-status-overdue dark:text-dark-status-overdue">{flagCount}</p>
 </div>
 <div className="rounded-lg bg-status-overdue/20 dark:bg-dark-status-overdue/20 p-3 text-status-overdue dark:text-dark-status-overdue">
 <AlertCircle className="h-6 w-6" />
 </div>
 </div>
 </div>
 </div>

 <div className="rounded-xl bg-surface dark:bg-dark-surface shadow-sm border border-text-secondary/10 dark:border-dark-text-secondary/10">
 <div className="border-b border-text-secondary/10 dark:border-dark-text-secondary/10 p-6 flex justify-between items-center">
 <h2 className="text-lg font-medium text-text-primary dark:text-dark-text-primary">Your Students</h2>
 <Link to="/dashboard/students" className="text-sm font-medium text-primary dark:text-dark-primary">View All</Link>
 </div>
 <div className="divide-y divide-slate-100">
 {students.slice(0, 5).map(student => (
 <div key={student.id} className="flex items-center justify-between p-4 hover:bg-background dark:hover:bg-dark-background">
 <div>
 <p className="text-sm font-medium text-text-primary dark:text-dark-text-primary">{student.name}</p>
 <p className="text-sm text-text-secondary dark:text-dark-text-secondary">{student.matric_number}</p>
 </div>
 <Link to={`/dashboard/students/${student.id}`} className="text-sm font-medium text-primary dark:text-dark-primary">
 View Logbook
 </Link>
 </div>
 ))}
 {students.length === 0 && (
 <div className="p-8 text-center text-sm text-text-secondary dark:text-dark-text-secondary">No students assigned yet.</div>
 )}
 </div>
 </div>
 </div>
 );
}
