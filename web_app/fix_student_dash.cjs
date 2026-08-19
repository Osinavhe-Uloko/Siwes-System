const fs = require('fs');

const path = 'src/components/dashboards/StudentDashboard.tsx';
let content = fs.readFileSync(path, 'utf8');

// 1. Add new imports
content = content.replace("import { AlertCircle, BookOpen, Clock, CheckCircle } from 'lucide-react';", 
"import { AlertCircle, BookOpen, Clock, CheckCircle, Mail, Phone, User as UserIcon } from 'lucide-react';");

// 2. Add state for supervisors
content = content.replace("const [stats, setStats] = useState({ pending: 0, reviewed: 0, flags: 0 });",
`const [stats, setStats] = useState({ pending: 0, reviewed: 0, flags: 0 });
  const [supervisors, setSupervisors] = useState<{institution?: any, industry?: any}>({});`);
  
// 3. Add firestore imports needed (doc, getDoc)
content = content.replace("import { collection, query, where, getDocs, orderBy, limit } from 'firebase/firestore';",
"import { collection, query, where, getDocs, doc, getDoc } from 'firebase/firestore';");

// 4. Update fetch logic
const fetchLogic = `      setStats({ pending, reviewed, flags: flagsDocs.size });
      
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
      }`;
      
content = content.replace("setStats({ pending, reviewed, flags: flagsDocs.size });", fetchLogic);

// 5. Add UI for supervisors
const uiHTML = `
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
`;

content = content.replace("</div>\n    </div>\n  );\n}", uiHTML);

fs.writeFileSync(path, content, 'utf8');
