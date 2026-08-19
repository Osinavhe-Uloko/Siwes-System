const fs = require('fs');

const path = 'src/pages/Landing.tsx';
let content = fs.readFileSync(path, 'utf8');

content = content.replace(
  "const { user } = useAuth();",
  "const { user, loading } = useAuth();"
);

const before = `{user ? ( <Link to="/dashboard" className="inline-flex items-center justify-center rounded-full bg-primary dark:bg-dark-primary px-4 py-1.5 text-sm font-medium text-white shadow-sm hover:bg-primary/90 dark:hover:bg-dark-primary/90 transition-colors focus:outline-none focus:ring-2 focus:ring-primary dark:focus:ring-dark-primary focus:ring-offset-2"> Go to Dashboard </Link> ) : ( <> <Link to="/login" className="text-sm font-medium text-text-secondary dark:text-dark-text-secondary hover:text-text-primary dark:hover:text-dark-text-primary dark:hover:text-white transition-colors"> Sign In </Link> <Link to="/register" className="inline-flex items-center justify-center rounded-full bg-primary dark:bg-dark-primary px-4 py-1.5 text-sm font-medium text-white shadow-sm hover:bg-surface dark:hover:bg-dark-surface dark:hover:bg-background dark:hover:bg-dark-background transition-colors focus:outline-none focus:ring-2 focus:ring-primary dark:focus:ring-dark-primary dark:focus:ring-white focus:ring-offset-2 dark:focus:ring-offset-slate-900"> Register </Link> </> )}`;

const after = `{loading ? (
                <div className="h-6 w-6 animate-spin rounded-full border-b-2 border-primary dark:border-dark-primary"></div>
              ) : user ? (
                <Link to="/dashboard" className="inline-flex items-center justify-center rounded-full bg-primary dark:bg-dark-primary px-4 py-1.5 text-sm font-medium text-white shadow-sm hover:bg-primary/90 dark:hover:bg-dark-primary/90 transition-colors focus:outline-none focus:ring-2 focus:ring-primary dark:focus:ring-dark-primary focus:ring-offset-2">
                  Access Dashboard
                </Link>
              ) : (
                <>
                  <Link to="/login" className="text-sm font-medium text-text-secondary dark:text-dark-text-secondary hover:text-text-primary dark:hover:text-dark-text-primary dark:hover:text-white transition-colors">
                    Sign In
                  </Link>
                  <Link to="/register" className="inline-flex items-center justify-center rounded-full bg-primary dark:bg-dark-primary px-4 py-1.5 text-sm font-medium text-white shadow-sm hover:bg-surface dark:hover:bg-dark-surface dark:hover:bg-background dark:hover:bg-dark-background transition-colors focus:outline-none focus:ring-2 focus:ring-primary dark:focus:ring-dark-primary dark:focus:ring-white focus:ring-offset-2 dark:focus:ring-offset-slate-900">
                    Register
                  </Link>
                </>
              )}`;

content = content.replace(before, after);

fs.writeFileSync(path, content, 'utf8');
