import { useAuth } from '../../contexts/AuthContext';
import { Link } from 'react-router-dom';
import { AlertCircle, BookOpen, Clock, CheckCircle, Mail, Phone, User as UserIcon } from 'lucide-react';
import { useEffect, useState } from 'react';
import { collection, query, where, getDocs, doc, getDoc } from 'firebase/firestore';
import { db } from '../../lib/firebase';

export function StudentDashboard() {
 const { user } = useAuth();
 const [stats, setStats] = useState({ pending: 0, reviewed: 0, flags: 0 });
  const [supervisors, setSupervisors] = useState<{institution?: any, industry?: any}>({});

 useEffect(() => {
 if (!user) return;
 const fetchStats = async () => {
 // Basic counts
 const q = query(collection(db, 'logbook_entries'), where('student_id', '==', user.id));
 const docs = await getDocs(q);
 let pending = 0;
 let reviewed = 0;
 docs.forEach(d => {
 if (d.data().status === 'pending') pending++;
 if (d.data().status === 'reviewed') reviewed++;
 });
 
 const flagsQ = query(collection(db, 'compliance_flags'), where('student_id', '==', user.id), where('resolved', '==', false));
 const flagsDocs = await getDocs(flagsQ);
 
       setStats({ pending, reviewed, flags: flagsDocs.size });
      
      // Fetch Supervisors
      try {
        const studentDoc = await getDoc(doc(db, 'users', user.id));
        const studentData = studentDoc.data();
        
        let instSup = null;
        if (studentData?.institution_supervisor_id) {
          const instDoc = await getDoc(doc(db, 'users', studentData.institution_supervisor_id));
          if (instDoc.exists()) instSup = instDoc.data();
        }
        
        let indSup = null;
        const placementQ = query(collection(db, 'placements'), where('student_id', '==', user.id));
        const placementDocs = await getDocs(placementQ);
        if (!placementDocs.empty) {
          const placementData = placementDocs.docs[0].data();
          if (placementData.industry_supervisor_id) {
            const indDoc = await getDoc(doc(db, 'users', placementData.industry_supervisor_id));
            if (indDoc.exists()) indSup = indDoc.data();
          }
        }
        
        setSupervisors({ institution: instSup, industry: indSup });
      } catch (err) {
        console.error("Error fetching supervisors", err);
      }
 };
 fetchStats();
 }, [user]);

 return (
 <div className="space-y-6">
 <h1 className="text-2xl font-bold text-text-primary dark:text-dark-text-primary ">Welcome, {user?.name}</h1>
 
 <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
 <div className="rounded-xl bg-surface dark:bg-dark-surface p-6 shadow-sm border border-text-secondary/10 dark:border-dark-text-secondary/10 transition-colors">
 <div className="flex items-center gap-4">
 <div className="rounded-lg bg-primary/20 dark:bg-dark-primary/20 p-3 text-primary dark:text-dark-primary ">
 <BookOpen className="h-6 w-6" />
 </div>
 <div>
 <p className="text-sm font-medium text-text-secondary dark:text-dark-text-secondary ">Total Entries</p>
 <p className="text-2xl font-bold text-text-primary dark:text-dark-text-primary ">{stats.pending + stats.reviewed}</p>
 </div>
 </div>
 </div>
 
 <div className="rounded-xl bg-surface dark:bg-dark-surface p-6 shadow-sm border border-text-secondary/10 dark:border-dark-text-secondary/10 transition-colors">
 <div className="flex items-center gap-4">
 <div className="rounded-lg bg-status-pending/20 dark:bg-dark-status-pending/20 p-3 text-status-pending dark:text-dark-status-pending ">
 <Clock className="h-6 w-6" />
 </div>
 <div>
 <p className="text-sm font-medium text-text-secondary dark:text-dark-text-secondary ">Pending Review</p>
 <p className="text-2xl font-bold text-text-primary dark:text-dark-text-primary ">{stats.pending}</p>
 </div>
 </div>
 </div>
 
 <div className="rounded-xl bg-surface dark:bg-dark-surface p-6 shadow-sm border border-text-secondary/10 dark:border-dark-text-secondary/10 transition-colors">
 <div className="flex items-center gap-4">
 <div className="rounded-lg bg-status-approved/20 dark:bg-dark-status-approved/20 p-3 text-status-approved dark:text-dark-status-approved ">
 <CheckCircle className="h-6 w-6" />
 </div>
 <div>
 <p className="text-sm font-medium text-text-secondary dark:text-dark-text-secondary ">Reviewed</p>
 <p className="text-2xl font-bold text-text-primary dark:text-dark-text-primary ">{stats.reviewed}</p>
 </div>
 </div>
 </div>
 
 <div className="rounded-xl bg-surface dark:bg-dark-surface p-6 shadow-sm border border-status-overdue/20 dark:border-dark-status-overdue/20 transition-colors">
 <div className="flex items-center gap-4">
 <div className="rounded-lg bg-status-overdue/20 dark:bg-dark-status-overdue/20 p-3 text-status-overdue dark:text-dark-status-overdue ">
 <AlertCircle className="h-6 w-6" />
 </div>
 <div>
 <p className="text-sm font-medium text-text-secondary dark:text-dark-text-secondary ">Active Flags</p>
 <p className="text-2xl font-bold text-status-overdue dark:text-dark-status-overdue ">{stats.flags}</p>
 </div>
 </div>
 </div>
 </div>

 <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
 <div className="rounded-xl bg-surface dark:bg-dark-surface shadow-sm border border-text-secondary/10 dark:border-dark-text-secondary/10 transition-colors">
 <div className="border-b border-text-secondary/10 dark:border-dark-text-secondary/10 p-6">
 <h2 className="text-lg font-medium text-text-primary dark:text-dark-text-primary ">Quick Actions</h2>
 </div>
 <div className="p-6">
 <Link
 to="/dashboard/logbook"
 className="block w-full rounded-md bg-primary dark:bg-dark-primary px-4 py-3 text-center font-medium text-white hover:bg-primary/90 dark:hover:bg-dark-primary/90 transition-colors"
 >
 Add New Logbook Entry
 </Link>
 </div>
 </div>

 <div className="rounded-xl bg-surface dark:bg-dark-surface shadow-sm border border-text-secondary/10 dark:border-dark-text-secondary/10 transition-colors">
 <div className="border-b border-text-secondary/10 dark:border-dark-text-secondary/10 p-6">
 <h2 className="text-lg font-medium text-text-primary dark:text-dark-text-primary ">Compliance Status</h2>
 </div>
 <div className="p-6">
 {stats.flags > 0 ? (
 <div className="rounded-md bg-status-overdue/10 dark:bg-dark-status-overdue/10 p-4 border border-status-overdue/30 dark:border-dark-status-overdue/30 ">
 <div className="flex items-start">
 <AlertCircle className="h-5 w-5 text-status-overdue dark:text-dark-status-overdue mt-0.5" />
 <div className="ml-3">
 <h3 className="text-sm font-medium text-status-overdue dark:text-dark-status-overdue ">Action Required</h3>
 <p className="mt-1 text-sm text-status-overdue dark:text-dark-status-overdue ">
 You have {stats.flags} active compliance flag(s). Please review your notifications or contact your supervisor.
 </p>
 </div>
 </div>
 </div>
 ) : (
 <div className="rounded-md bg-status-approved/10 dark:bg-dark-status-approved/10 p-4 border border-status-approved/30 dark:border-dark-status-approved/30 ">
 <div className="flex items-start">
 <CheckCircle className="h-5 w-5 text-status-approved dark:text-dark-status-approved mt-0.5" />
 <div className="ml-3">
 <h3 className="text-sm font-medium text-status-approved dark:text-dark-status-approved ">Good Standing</h3>
 <p className="mt-1 text-sm text-status-approved dark:text-dark-status-approved ">
 Your logbook entries are up to date and compliant. Keep it up!
 </p>
 </div>
 </div>
 </div>
 )}
 </div>
       </div>
    </div>
      {/* Supervisors Section */}
      <div className="rounded-xl bg-surface dark:bg-dark-surface shadow-sm border border-text-secondary/10 dark:border-dark-text-secondary/10 transition-colors col-span-1 lg:col-span-2">
        <div className="border-b border-text-secondary/10 dark:border-dark-text-secondary/10 p-6">
          <h2 className="text-lg font-medium text-text-primary dark:text-dark-text-primary">My Supervisors</h2>
        </div>
        <div className="p-6 grid grid-cols-1 md:grid-cols-2 gap-6">
          {/* Institution Supervisor */}
          <div className="flex flex-col rounded-lg border border-text-secondary/10 dark:border-dark-text-secondary/10 p-4">
            <h3 className="text-sm font-medium text-text-secondary dark:text-dark-text-secondary mb-3">Institution Supervisor</h3>
            {supervisors.institution ? (
              <div className="flex flex-col gap-3">
                <div className="flex items-center gap-3">
                  <div className="h-10 w-10 rounded-full bg-primary/10 dark:bg-dark-primary/10 flex items-center justify-center text-primary dark:text-dark-primary">
                    <UserIcon className="h-5 w-5" />
                  </div>
                  <div>
                    <p className="text-sm font-semibold text-text-primary dark:text-dark-text-primary">{supervisors.institution.name}</p>
                    <p className="text-xs text-text-secondary dark:text-dark-text-secondary">{supervisors.institution.email}</p>
                  </div>
                </div>
                <a href={"mailto:" + supervisors.institution.email} className="mt-2 inline-flex items-center justify-center gap-2 rounded-md bg-background dark:bg-dark-background px-3 py-2 text-sm font-medium text-text-primary dark:text-dark-text-primary hover:bg-text-secondary/10 transition-colors w-full">
                  <Mail className="h-4 w-4" />
                  Contact via Email
                </a>
              </div>
            ) : (
              <p className="text-sm text-text-secondary dark:text-dark-text-secondary py-4 text-center">Not assigned yet</p>
            )}
          </div>
          
          {/* Industry Supervisor */}
          <div className="flex flex-col rounded-lg border border-text-secondary/10 dark:border-dark-text-secondary/10 p-4">
            <h3 className="text-sm font-medium text-text-secondary dark:text-dark-text-secondary mb-3">Industry Supervisor</h3>
            {supervisors.industry ? (
              <div className="flex flex-col gap-3">
                <div className="flex items-center gap-3">
                  <div className="h-10 w-10 rounded-full bg-primary/10 dark:bg-dark-primary/10 flex items-center justify-center text-primary dark:text-dark-primary">
                    <UserIcon className="h-5 w-5" />
                  </div>
                  <div>
                    <p className="text-sm font-semibold text-text-primary dark:text-dark-text-primary">{supervisors.industry.name}</p>
                    <p className="text-xs text-text-secondary dark:text-dark-text-secondary">{supervisors.industry.email}</p>
                  </div>
                </div>
                <a href={"mailto:" + supervisors.industry.email} className="mt-2 inline-flex items-center justify-center gap-2 rounded-md bg-background dark:bg-dark-background px-3 py-2 text-sm font-medium text-text-primary dark:text-dark-text-primary hover:bg-text-secondary/10 transition-colors w-full">
                  <Mail className="h-4 w-4" />
                  Contact via Email
                </a>
              </div>
            ) : (
              <p className="text-sm text-text-secondary dark:text-dark-text-secondary py-4 text-center">Not assigned yet</p>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}