import React, { useState, useEffect } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { db } from '../lib/firebase';
import { collection, query, where, orderBy, getDocs, addDoc, Timestamp } from 'firebase/firestore';
import { format } from 'date-fns';
import { CheckCircle, Clock, AlertTriangle, MessageSquare, BookOpen } from 'lucide-react';

export function Logbook() {
 const { user } = useAuth();
 const [entries, setEntries] = useState<any[]>([]);
 const [loading, setLoading] = useState(true);
 
 const [showForm, setShowForm] = useState(false);
 const [newEntry, setNewEntry] = useState({
 entry_date: format(new Date(), 'yyyy-MM-dd'),
 content: '',
 week_number: 1
 });
 const [submitting, setSubmitting] = useState(false);

 const fetchEntries = async () => {
 if (!user) return;
 const q = query(
 collection(db, 'logbook_entries'), 
 where('student_id', '==', user.id),
 orderBy('entry_date', 'desc')
 );
 const snap = await getDocs(q);
 setEntries(snap.docs.map(d => ({ id: d.id, ...d.data() })));
 setLoading(false);
 };

 useEffect(() => {
 fetchEntries();
 }, [user]);

 const handleSubmit = async (e: React.FormEvent) => {
 e.preventDefault();
 if (!user) return;
 setSubmitting(true);

 try {
 const now = Date.now();
 
 // Anomaly detection: 3 or more entries in 30 mins
 const thirtyMinsAgo = now - (30 * 60 * 1000);
 const recentQ = query(
 collection(db, 'logbook_entries'),
 where('student_id', '==', user.id),
 where('submitted_at', '>=', thirtyMinsAgo)
 );
 const recentSnap = await getDocs(recentQ);
 
 const newEntryDoc = {
 student_id: user.id,
 entry_date: newEntry.entry_date,
 submitted_at: now,
 content: newEntry.content,
 week_number: Number(newEntry.week_number),
 status: 'pending'
 };

 const docRef = await addDoc(collection(db, 'logbook_entries'), newEntryDoc);

 if (recentSnap.size >= 2) {
 // This is the 3rd entry within 30 mins
 await addDoc(collection(db, 'compliance_flags'), {
 student_id: user.id,
 logbook_entry_id: docRef.id,
 flag_type: 'backdated_cluster',
 detected_at: now,
 resolved: false
 });
 }

 setNewEntry({
 entry_date: format(new Date(), 'yyyy-MM-dd'),
 content: '',
 week_number: newEntry.week_number
 });
 setShowForm(false);
 fetchEntries();
 } catch (err) {
 console.error(err);
 alert('Failed to submit entry');
 } finally {
 setSubmitting(false);
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
 <div className="space-y-6 max-w-4xl mx-auto">
 <div className="flex items-center justify-between">
 <h1 className="text-2xl font-bold text-text-primary dark:text-dark-text-primary">My Logbook</h1>
 <button
 onClick={() => setShowForm(!showForm)}
 className="rounded-md bg-primary dark:bg-dark-primary px-4 py-2 text-sm font-medium text-white hover:bg-primary/90 dark:hover:bg-dark-primary/90"
 >
 {showForm ? 'Cancel' : 'Add Entry'}
 </button>
 </div>

 {showForm && (
 <form onSubmit={handleSubmit} className="rounded-xl bg-surface dark:bg-dark-surface p-6 shadow-sm border border-text-secondary/20 dark:border-dark-text-secondary/20">
 <h2 className="text-lg font-medium text-text-primary dark:text-dark-text-primary mb-4">New Logbook Entry</h2>
 <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
 <div>
 <label className="block text-sm font-medium text-text-primary dark:text-dark-text-primary">Date of Activity</label>
 <input
 type="date"
 required
 value={newEntry.entry_date}
 onChange={e => setNewEntry({...newEntry, entry_date: e.target.value})}
 className="mt-1 block w-full rounded-md border border-text-secondary/30 dark:border-dark-text-secondary/30 py-2 px-3 shadow-sm focus:border-primary dark:focus:border-dark-primary focus:outline-none focus:ring-1 focus:ring-primary dark:focus:ring-dark-primary sm:text-sm"
 />
 </div>
 <div>
 <label className="block text-sm font-medium text-text-primary dark:text-dark-text-primary">Week Number</label>
 <input
 type="number"
 required
 min="1"
 value={newEntry.week_number}
 onChange={e => setNewEntry({...newEntry, week_number: parseInt(e.target.value)})}
 className="mt-1 block w-full rounded-md border border-text-secondary/30 dark:border-dark-text-secondary/30 py-2 px-3 shadow-sm focus:border-primary dark:focus:border-dark-primary focus:outline-none focus:ring-1 focus:ring-primary dark:focus:ring-dark-primary sm:text-sm"
 />
 </div>
 <div className="sm:col-span-2">
 <label className="block text-sm font-medium text-text-primary dark:text-dark-text-primary">Activity Description</label>
 <p className="text-xs text-text-secondary dark:text-dark-text-secondary mb-2">Detailed description of tasks performed.</p>
 <textarea
 required
 rows={4}
 value={newEntry.content}
 onChange={e => setNewEntry({...newEntry, content: e.target.value})}
 className="mt-1 block w-full rounded-md border border-text-secondary/30 dark:border-dark-text-secondary/30 py-2 px-3 shadow-sm focus:border-primary dark:focus:border-dark-primary focus:outline-none focus:ring-1 focus:ring-primary dark:focus:ring-dark-primary sm:text-sm"
 />
 </div>
 </div>
 <div className="mt-4 flex justify-end">
 <button
 type="submit"
 disabled={submitting}
 className="rounded-md bg-primary dark:bg-dark-primary px-4 py-2 text-sm font-medium text-white hover:bg-primary/90 dark:hover:bg-dark-primary/90 disabled:opacity-50"
 >
 {submitting ? 'Submitting...' : 'Submit Entry'}
 </button>
 </div>
 <p className="mt-2 text-xs text-text-secondary dark:text-dark-text-secondary italic">
 Note: The server will permanently record the exact time of submission. Submitting multiple days of work at once may flag your account for backdating.
 </p>
 </form>
 )}

 <div className="space-y-4">
 {entries.length === 0 ? (
 <div className="rounded-xl bg-surface dark:bg-dark-surface p-8 text-center border border-text-secondary/20 dark:border-dark-text-secondary/20">
 <BookOpen className="mx-auto h-12 w-12 text-text-secondary dark:text-dark-text-secondary" />
 <h3 className="mt-2 text-sm font-medium text-text-primary dark:text-dark-text-primary">No entries yet</h3>
 <p className="mt-1 text-sm text-text-secondary dark:text-dark-text-secondary">Get started by creating a new logbook entry.</p>
 </div>
 ) : (
 entries.map(entry => (
 <div key={entry.id} className="rounded-xl bg-surface dark:bg-dark-surface shadow-sm border border-text-secondary/20 dark:border-dark-text-secondary/20 overflow-hidden">
 <div className="bg-background dark:bg-dark-background border-b border-text-secondary/20 dark:border-dark-text-secondary/20 p-4 flex flex-col sm:flex-row sm:items-center justify-between gap-2">
 <div>
 <h3 className="text-sm font-bold text-text-primary dark:text-dark-text-primary">
 Week {entry.week_number} • {format(new Date(entry.entry_date), 'EEEE, MMMM d, yyyy')}
 </h3>
 <p className="text-xs text-text-secondary dark:text-dark-text-secondary mt-1">
 Submitted: {format(new Date(entry.submitted_at), 'MMM d, yyyy h:mm a')}
 </p>
 </div>
 <div>
 {entry.status === 'pending' && (
 <span className="inline-flex items-center gap-1.5 rounded-full bg-status-pending/20 dark:bg-dark-status-pending/20 px-2 py-1 text-xs font-medium text-status-pending dark:text-dark-status-pending">
 <Clock className="h-3 w-3" /> Pending Review
 </span>
 )}
 {entry.status === 'reviewed' && (
 <span className="inline-flex items-center gap-1.5 rounded-full bg-status-approved/20 dark:bg-dark-status-approved/20 px-2 py-1 text-xs font-medium text-status-approved dark:text-dark-status-approved">
 <CheckCircle className="h-3 w-3" /> Reviewed
 </span>
 )}
 {entry.status === 'flagged' && (
 <span className="inline-flex items-center gap-1.5 rounded-full bg-status-overdue/20 dark:bg-dark-status-overdue/20 px-2 py-1 text-xs font-medium text-status-overdue dark:text-dark-status-overdue">
 <AlertTriangle className="h-3 w-3" /> Flagged
 </span>
 )}
 </div>
 </div>
 <div className="p-4">
 <p className="text-sm text-text-primary dark:text-dark-text-primary whitespace-pre-wrap">{entry.content}</p>
 
 {entry.supervisor_comment && (
 <div className="mt-4 rounded-md bg-primary/10 dark:bg-dark-primary/10 p-3 flex gap-3 border border-primary/20 dark:border-dark-primary/20">
 <MessageSquare className="h-5 w-5 text-primary dark:text-dark-primary shrink-0" />
 <div>
 <p className="text-xs font-medium text-primary dark:text-dark-primary mb-1">Supervisor Comment</p>
 <p className="text-sm text-blue-800">{entry.supervisor_comment}</p>
 </div>
 </div>
 )}
 </div>
 </div>
 ))
 )}
 </div>
 </div>
 );
}
