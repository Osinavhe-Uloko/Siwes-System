const fs = require('fs');

const path = 'src/components/layout/AppLayout.tsx';
let content = fs.readFileSync(path, 'utf8');

const before = '<div className="absolute -right-2 sm:right-0 mt-2 w-[calc(100vw-1rem)] sm:w-80 max-w-md rounded-xl bg-surface dark:bg-dark-surface shadow-lg border border-text-secondary/10 dark:border-dark-text-secondary/10 py-2 z-50">';
const after = '<div className="fixed top-20 right-4 left-4 sm:absolute sm:inset-auto sm:right-0 sm:mt-2 sm:w-80 rounded-xl bg-surface dark:bg-dark-surface shadow-lg border border-text-secondary/10 dark:border-dark-text-secondary/10 py-2 z-50">';

content = content.replace(before, after);

fs.writeFileSync(path, content, 'utf8');
