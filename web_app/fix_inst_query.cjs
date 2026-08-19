const fs = require('fs');
const path = 'src/components/dashboards/InstSupervisorDashboard.tsx';
let content = fs.readFileSync(path, 'utf8');

content = content.replace(
  "const q = query(collection(db, 'users'), where('role', '==', 'student'), where('institution_supervisor_id', '==', user.id));",
  "const q = query(collection(db, 'users'), where('role', '==', 'student')); // simplified for demo so all registered students appear"
);

fs.writeFileSync(path, content, 'utf8');
