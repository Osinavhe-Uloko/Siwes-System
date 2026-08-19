import { collection, query, where, getDocs, addDoc, orderBy, limit } from 'firebase/firestore';
import { db } from './firebase';

export async function detectMissedEntries() {
 console.log('Running compliance detection checks...');
 const now = Date.now();
 const threeDaysMs = 3 * 24 * 60 * 60 * 1000;
 const sevenDaysMs = 7 * 24 * 60 * 60 * 1000;

 try {
 // Check all active students
 const studentsSnap = await getDocs(query(collection(db, 'users'), where('role', '==', 'student')));
 
 for (const studentDoc of studentsSnap.docs) {
 const studentId = studentDoc.id;

 // Check for missed entries (no entry in last 3 days)
 const lastEntryQ = query(
 collection(db, 'logbook_entries'),
 where('student_id', '==', studentId),
 orderBy('submitted_at', 'desc'),
 limit(1)
 );
 const lastEntrySnap = await getDocs(lastEntryQ);
 
 if (!lastEntrySnap.empty) {
 const lastEntry = lastEntrySnap.docs[0].data();
 if (now - lastEntry.submitted_at > threeDaysMs) {
 // Has this already been flagged recently?
 const existingFlagQ = query(
 collection(db, 'compliance_flags'),
 where('student_id', '==', studentId),
 where('flag_type', '==', 'missed_entry'),
 where('resolved', '==', false)
 );
 const existingFlagSnap = await getDocs(existingFlagQ);
 
 if (existingFlagSnap.empty) {
 await addDoc(collection(db, 'compliance_flags'), {
 student_id: studentId,
 flag_type: 'missed_entry',
 detected_at: now,
 resolved: false
 });
 console.log(`Flagged student ${studentId} for missed entry`);
 }
 }
 }

 // Check for overdue reviews
 const unreviewedQ = query(
 collection(db, 'logbook_entries'),
 where('student_id', '==', studentId),
 where('status', '==', 'pending')
 );
 const unreviewedSnap = await getDocs(unreviewedQ);
 
 for (const entryDoc of unreviewedSnap.docs) {
 const entry = entryDoc.data();
 if (now - entry.submitted_at > sevenDaysMs) {
 const existingFlagQ = query(
 collection(db, 'compliance_flags'),
 where('logbook_entry_id', '==', entryDoc.id),
 where('flag_type', '==', 'overdue_review'),
 where('resolved', '==', false)
 );
 const existingFlagSnap = await getDocs(existingFlagQ);
 
 if (existingFlagSnap.empty) {
 await addDoc(collection(db, 'compliance_flags'), {
 student_id: studentId,
 logbook_entry_id: entryDoc.id,
 flag_type: 'overdue_review',
 detected_at: now,
 resolved: false
 });
 console.log(`Flagged entry ${entryDoc.id} for overdue review`);
 }
 }
 }
 }
 } catch (error) {
 console.error('Error running compliance checks:', error);
 }
}
