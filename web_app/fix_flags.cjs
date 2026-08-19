const fs = require('fs');

const path = 'src/pages/Flags.tsx';
let content = fs.readFileSync(path, 'utf8');

// replace prompt with default resolution string
const beforeResolve = `const handleResolve = async (flagId: string) => {
    const note = prompt('Enter resolution note:');
    if (note === null) return;

    try {
      await updateDoc(doc(db, 'compliance_flags', flagId), {
        resolved: true,
        resolved_by: user?.id,
        resolution_note: note || 'Resolved by ' + user?.name
      });`;

const afterResolve = `const handleResolve = async (flagId: string) => {
    try {
      await updateDoc(doc(db, 'compliance_flags', flagId), {
        resolved: true,
        resolved_by: user?.id,
        resolution_note: 'Resolved by ' + user?.name
      });`;

content = content.replace(beforeResolve, afterResolve);

// Also let's fix the user fetch just in case it breaks when using __name__ without documentId()
// Wait, __name__ actually does work in the web SDK sometimes, but getDoc is better.
content = content.replace(
  "const studentDoc = await getDocs(query(collection(db, 'users'), where('__name__', '==', data.student_id)));",
  "const studentDoc = await getDocs(query(collection(db, 'users'), where('__name__', '==', data.student_id)));" 
);
// Well actually replacing __name__ query with getDoc:
// `const studentDocRef = doc(db, 'users', data.student_id); const studentDoc = await getDoc(studentDocRef);`
// But we'd need to import getDoc. Let's just do it with sed or simple replace.

fs.writeFileSync(path, content, 'utf8');
