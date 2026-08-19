const fs = require('fs');

const path = 'src/components/layout/AppLayout.tsx';
let content = fs.readFileSync(path, 'utf8');

const before = '<div className="fixed top-20 right-4 left-4 sm:absolute sm:inset-auto sm:right-0 sm:mt-2 sm:w-80 rounded-xl bg-surface dark:bg-dark-surface shadow-lg border border-text-secondary/10 dark:border-dark-text-secondary/10 py-2 z-50">';
const after = '<div className="absolute right-0 sm:right-0 mt-2 w-[calc(100vw-2rem)] max-w-xs sm:w-80 sm:max-w-md rounded-xl bg-surface dark:bg-dark-surface shadow-lg border border-text-secondary/10 dark:border-dark-text-secondary/10 py-2 z-50 overflow-hidden transform origin-top-right">';

content = content.replace(before, after);

fs.writeFileSync(path, content, 'utf8');
