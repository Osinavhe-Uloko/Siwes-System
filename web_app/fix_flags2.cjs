const fs = require('fs');

const path = 'src/pages/Flags.tsx';
let content = fs.readFileSync(path, 'utf8');

// Replace __name__ with documentId()
content = content.replace("import { collection, query, where, getDocs, doc, updateDoc } from 'firebase/firestore';", 
"import { collection, query, where, getDocs, doc, updateDoc, documentId } from 'firebase/firestore';");

content = content.replace(
  "const studentDoc = await getDocs(query(collection(db, 'users'), where('__name__', '==', data.student_id)));",
  "const studentDoc = await getDocs(query(collection(db, 'users'), where(documentId(), '==', data.student_id)));"
);

fs.writeFileSync(path, content, 'utf8');
