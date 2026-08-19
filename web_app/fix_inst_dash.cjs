const fs = require('fs');

const path = 'src/components/dashboards/InstSupervisorDashboard.tsx';
let content = fs.readFileSync(path, 'utf8');

// 1. Add state for flags count
content = content.replace("const [students, setStudents] = useState<any[]>([]);",
`const [students, setStudents] = useState<any[]>([]);
  const [flagCount, setFlagCount] = useState(0);`);

// 2. Add flags fetching logic
const fetchLogic = `
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
`;

content = content.replace("setStudents(snap.docs.map(d => ({ id: d.id, ...d.data() })));", fetchLogic);

// 3. Update UI to use flagCount
content = content.replace('<p className="text-2xl font-bold text-status-overdue dark:text-dark-status-overdue">0</p>',
'<p className="text-2xl font-bold text-status-overdue dark:text-dark-status-overdue">{flagCount}</p>');

fs.writeFileSync(path, content, 'utf8');
