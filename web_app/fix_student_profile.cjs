const fs = require('fs');

const path = 'src/pages/StudentProfile.tsx';
let content = fs.readFileSync(path, 'utf8');

// Add updateDoc to imports
content = content.replace("orderBy } from 'firebase/firestore';", "orderBy, updateDoc } from 'firebase/firestore';");

// Add handlers
const handlers = `
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
`;

content = content.replace("const { user } = useAuth();", "const { user } = useAuth();\n" + handlers);

// Update buttons
content = content.replace(/<button className="rounded-lg bg-status-approved dark:bg-dark-status-approved px-4 py-2 text-sm font-semibold text-white shadow-sm hover:bg-green-500 transition-colors">\s*Approve Entry\s*<\/button>/g,
`<button onClick={() => handleUpdateEntryStatus(entry.id, 'reviewed')} className="rounded-lg bg-status-approved dark:bg-dark-status-approved px-4 py-2 text-sm font-semibold text-white shadow-sm hover:bg-status-approved/90 dark:hover:bg-dark-status-approved/90 transition-colors">
                      Approve Entry
                    </button>`);

content = content.replace(/<button className="rounded-lg bg-surface dark:bg-dark-surface px-4 py-2 text-sm font-semibold text-text-primary dark:text-dark-text-primary shadow-sm ring-1 ring-inset ring-text-secondary\/30 dark:ring-dark-text-secondary\/30 hover:bg-background dark:hover:bg-dark-background transition-colors">\s*Request Changes\s*<\/button>/g,
`<button onClick={() => handleUpdateEntryStatus(entry.id, 'flagged')} className="rounded-lg bg-surface dark:bg-dark-surface px-4 py-2 text-sm font-semibold text-text-primary dark:text-dark-text-primary shadow-sm ring-1 ring-inset ring-text-secondary/30 dark:ring-dark-text-secondary/30 hover:bg-background dark:hover:bg-dark-background transition-colors">
                      Request Changes
                    </button>`);

fs.writeFileSync(path, content, 'utf8');
