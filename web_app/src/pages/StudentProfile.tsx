import { useState, useEffect } from 'react';
import { useParams, Link } from 'react-router-dom';
import { collection, query, where, getDocs, doc, getDoc, orderBy, updateDoc } from 'firebase/firestore';
import { db } from '../lib/firebase';
import { User, LogbookEntry } from '../types';
import { ArrowLeft, User as UserIcon, Calendar, CheckCircle, Clock, AlertCircle } from 'lucide-react';
import { useAuth } from '../contexts/AuthContext';

export function StudentProfile() {
 const { id } = useParams<{ id: string }>();
 const [student, setStudent] = useState<User | null>(null);
 const [entries, setEntries] = useState<LogbookEntry[]>([]);
 const [loading, setLoading] = useState(true);
 const { user } = useAuth();

  const handleUpdateEntryStatus = async (entryId: string, newStatus: string) => {
    try {
      const entryRef = doc(db, 'logbook_entries', entryId);
      await updateDoc(entryRef, {
        status: newStatus
      });
      // Update local state
      setEntries(entries.map(e => e.id === entryId ? { ...e, status: newStatus as any } : e));
    } catch (err) {
      console.error("Error updating entry:", err);
      alert("Failed to update entry");
    }
  };


 useEffect(() => {
 const fetchStudentAndEntries = async () => {
 if (!id) return;
 try {
 const studentDoc = await getDoc(doc(db, 'users', id));
 if (studentDoc.exists()) {
 setStudent({ id: studentDoc.id, ...studentDoc.data() } as User);
 }

 const q = query(
 collection(db, 'logbook_entries'),
 where('student_id', '==', id),
 orderBy('entry_date', 'desc')
 );
 const snap = await getDocs(q);
 setEntries(snap.docs.map(d => ({ id: d.id, ...d.data() } as LogbookEntry)));
 } catch (error) {
 console.error('Error fetching student data:', error);
 } finally {
 setLoading(false);
 }
 };
 fetchStudentAndEntries();
 }, [id]);

 if (loading) {
 return (
 <div className="flex justify-center p-12">
 <div className="h-8 w-8 animate-spin rounded-full border-b-2 border-primary dark:border-dark-primary"></div>
 </div>
 );
 }

 if (!student) {
 return (
 <div className="text-center p-12">
 <p className="text-text-secondary dark:text-dark-text-secondary">Student not found.</p>
 <Link to="/dashboard/students" className="text-primary dark:text-dark-primary mt-4 inline-block hover:underline">
 Return to students
 </Link>
 </div>
 );
 }

 return (
 <div className="space-y-6 max-w-5xl mx-auto">
 <div className="flex items-center gap-4">
 <Link to="/dashboard/students" className="p-2 -ml-2 text-text-secondary dark:text-dark-text-secondary hover:text-text-secondary dark:hover:text-dark-text-secondary hover:bg-background dark:hover:bg-dark-background rounded-lg transition-colors">
 <ArrowLeft className="h-5 w-5" />
 </Link>
 <div>
 <h2 className="text-2xl font-bold tracking-tight text-text-primary dark:text-dark-text-primary">Student Profile</h2>
 <p className="text-sm text-text-secondary dark:text-dark-text-secondary">Viewing logbook and details for {student.name}</p>
 </div>
 </div>

 <div className="bg-surface dark:bg-dark-surface rounded-2xl p-6 shadow-sm border border-text-secondary/20 dark:border-dark-text-secondary/20">
 <div className="flex items-start gap-6">
 <div className="h-20 w-20 rounded-full bg-primary/20 dark:bg-dark-primary/20 flex items-center justify-center text-primary dark:text-dark-primary font-bold text-2xl shadow-inner">
 {student.name.charAt(0)}
 </div>
 <div className="flex-1">
 <h3 className="text-xl font-bold text-text-primary dark:text-dark-text-primary">{student.name}</h3>
 <p className="text-text-secondary dark:text-dark-text-secondary">{student.email} • {student.phone}</p>
 <div className="mt-4 grid grid-cols-2 gap-4 text-sm">
 <div>
 <span className="block text-text-secondary dark:text-dark-text-secondary font-medium">Matric Number</span>
 <span className="font-medium text-text-primary dark:text-dark-text-primary">{student.matric_number || 'N/A'}</span>
 </div>
 <div>
 <span className="block text-text-secondary dark:text-dark-text-secondary font-medium">Department</span>
 <span className="font-medium text-text-primary dark:text-dark-text-primary">{student.department || 'N/A'} ({student.level || 'N/A'}L)</span>
 </div>
 </div>
 </div>
 </div>
 </div>

 <div className="space-y-4">
 <h3 className="text-lg font-bold text-text-primary dark:text-dark-text-primary">Logbook Entries</h3>
 
 {entries.length === 0 ? (
 <div className="bg-surface dark:bg-dark-surface rounded-2xl p-8 text-center shadow-sm border border-text-secondary/20 dark:border-dark-text-secondary/20">
 <BookIcon className="h-12 w-12 text-text-secondary dark:text-dark-text-secondary mx-auto mb-3" />
 <p className="text-text-secondary dark:text-dark-text-secondary">No logbook entries found for this student.</p>
 </div>
 ) : (
 <div className="space-y-4">
 {entries.map((entry) => (
 <div key={entry.id} className="bg-surface dark:bg-dark-surface rounded-2xl shadow-sm border border-text-secondary/20 dark:border-dark-text-secondary/20 overflow-hidden">
 <div className="border-b border-text-secondary/10 dark:border-dark-text-secondary/10 bg-background dark:bg-dark-background p-4 flex justify-between items-center">
 <div className="flex items-center gap-3">
 <Calendar className="h-5 w-5 text-text-secondary dark:text-dark-text-secondary" />
 <span className="font-medium text-text-primary dark:text-dark-text-primary">{entry.entry_date}</span>
 <span className="text-xs font-semibold text-text-secondary dark:text-dark-text-secondary uppercase tracking-wider bg-background dark:bg-dark-background px-2 py-0.5 rounded-full">
 Week {entry.week_number}
 </span>
 </div>
 <span className={`inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-xs font-medium ring-1 ring-inset ${
 entry.status === 'reviewed' 
 ? 'bg-status-approved/10 dark:bg-dark-status-approved/10 text-status-approved dark:text-dark-status-approved ring-status-approved dark:ring-dark-status-approved/20'
 : entry.status === 'pending'
 ? 'bg-status-pending/10 dark:bg-dark-status-pending/10 text-status-pending dark:text-dark-status-pending ring-status-pending dark:ring-dark-status-pending/20'
 : 'bg-status-overdue/10 dark:bg-dark-status-overdue/10 text-status-overdue dark:text-dark-status-overdue ring-status-overdue dark:ring-dark-status-overdue/20'
 }`}>
 {entry.status === 'reviewed' && <CheckCircle className="h-3 w-3" />}
 {entry.status === 'pending' && <Clock className="h-3 w-3" />}
 {entry.status === 'flagged' && <AlertCircle className="h-3 w-3" />}
 {entry.status.charAt(0).toUpperCase() + entry.status.slice(1)}
 </span>
 </div>
 <div className="p-5">
 <p className="text-text-primary dark:text-dark-text-primary whitespace-pre-wrap">{entry.content}</p>
 
 {user?.role !== 'student' && entry.status === 'pending' && (
 <div className="mt-6 flex gap-3 pt-4 border-t border-text-secondary/10 dark:border-dark-text-secondary/10">
 <button onClick={() => handleUpdateEntryStatus(entry.id, 'reviewed')} className="rounded-lg bg-status-approved dark:bg-dark-status-approved px-4 py-2 text-sm font-semibold text-white shadow-sm hover:bg-status-approved/90 dark:hover:bg-dark-status-approved/90 transition-colors">
                      Approve Entry
                    </button>
 <button onClick={() => handleUpdateEntryStatus(entry.id, 'flagged')} className="rounded-lg bg-surface dark:bg-dark-surface px-4 py-2 text-sm font-semibold text-text-primary dark:text-dark-text-primary shadow-sm ring-1 ring-inset ring-text-secondary/30 dark:ring-dark-text-secondary/30 hover:bg-background dark:hover:bg-dark-background transition-colors">
                      Request Changes
                    </button>
 </div>
 )}
 </div>
 </div>
 ))}
 </div>
 )}
 </div>
 </div>
 );
}

// Quick helper
function BookIcon(props: any) {
 return (
 <svg
 {...props}
 xmlns="http://www.w3.org/2000/svg"
 width="24"
 height="24"
 viewBox="0 0 24 24"
 fill="none"
 stroke="currentColor"
 strokeWidth="2"
 strokeLinecap="round"
 strokeLinejoin="round"
 >
 <path d="M4 19.5v-15A2.5 2.5 0 0 1 6.5 2H20v20H6.5a2.5 2.5 0 0 1 0-5H20" />
 </svg>
 )
}
