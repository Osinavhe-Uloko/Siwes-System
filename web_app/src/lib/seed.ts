import { collection, writeBatch, doc, setDoc } from 'firebase/firestore';
import { createUserWithEmailAndPassword, signInWithEmailAndPassword } from 'firebase/auth';
import { auth, db } from './firebase';

export async function seedDatabase() {
 console.log('Seeding database...');
 
 // Create Demo Users
 const demoUsers = [
 { email: 'admin@uni.edu', pass: 'password123', name: 'Dr. Coordinator', role: 'coordinator' },
 { email: 'prof.smith@uni.edu', pass: 'password123', name: 'Prof. Smith', role: 'institution_supervisor' },
 { email: 'manager@techcorp.com', pass: 'password123', name: 'John Manager', role: 'industry_supervisor' },
 { email: 'john.doe@student.edu', pass: 'password123', name: 'John Doe', role: 'student', matric: 'CSC/19/001' },
 { email: 'jane.smith@student.edu', pass: 'password123', name: 'Jane Smith', role: 'student', matric: 'CSC/19/002' },
 ];

 const userRecords: any = {};

 for (const u of demoUsers) {
 try {
 let cred;
 try {
 cred = await signInWithEmailAndPassword(auth, u.email, u.pass);
 console.log(`User ${u.email} already exists`);
 } catch (err: any) {
 if (err.code === 'auth/invalid-credential' || err.code === 'auth/user-not-found' || err.code === 'auth/invalid-login-credentials') {
 cred = await createUserWithEmailAndPassword(auth, u.email, u.pass);
 const userData: any = {
 name: u.name,
 email: u.email,
 phone: '0800000000',
 role: u.role,
 created_at: Date.now()
 };
 if (u.role === 'student') {
 userData.matric_number = u.matric;
 userData.department = 'Computer Science';
 userData.level = '400';
 }
 await setDoc(doc(db, 'users', cred.user.uid), userData);
 } else {
 throw err;
 }
 }
 userRecords[u.role] = cred.user.uid;
 } catch (e: any) {
 if (e.code === 'auth/operation-not-allowed') {
 console.error('Email/Password authentication is not enabled. Cannot seed database.');
 throw new Error('Email/Password authentication is not enabled. Please enable it in the Firebase Console -> Authentication -> Sign-in method.');
 } else {
 console.error('Error with user:', u.email, e);
 }
 }
 }

 // If we couldn't create them (maybe auth rate limits), stop here
 if (!userRecords['student']) return;

 const batch = writeBatch(db);

 // Seed some placements
 const placementRef = doc(collection(db, 'placements'));
 batch.set(placementRef, {
 student_id: userRecords['student'],
 company_name: 'Tech Corp',
 company_address: '123 Tech Way',
 state: 'Lagos',
 industry_sector: 'IT',
 start_date: '2023-01-01',
 end_date: '2023-06-30',
 industry_supervisor_id: userRecords['industry_supervisor']
 });

 // Assign student to institution supervisor
 batch.update(doc(db, 'users', userRecords['student']), {
 institution_supervisor_id: userRecords['institution_supervisor'],
 placement_id: placementRef.id
 });

 // Add Logbook Entries
 const now = Date.now();
 const dayMs = 24 * 60 * 60 * 1000;
 
 for (let i = 0; i < 5; i++) {
 const entryRef = doc(collection(db, 'logbook_entries'));
 batch.set(entryRef, {
 student_id: userRecords['student'],
 entry_date: new Date(now - (i * dayMs)).toISOString().split('T')[0],
 submitted_at: now - (i * dayMs) + 3600000,
 content: `Implemented feature ${i} for the backend API. Learned about Node.js performance.`,
 week_number: 1,
 status: i < 3 ? 'reviewed' : 'pending',
 supervisor_comment: i < 3 ? 'Good progress.' : null
 });
 }

 // Add some flags
 const flagRef = doc(collection(db, 'compliance_flags'));
 batch.set(flagRef, {
 student_id: userRecords['student'],
 flag_type: 'backdated_cluster',
 detected_at: now,
 resolved: false
 });

 await batch.commit();
 console.log('Seeding complete.');
}
