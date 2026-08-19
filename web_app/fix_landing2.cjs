const fs = require('fs');

const path = 'src/pages/Landing.tsx';
let content = fs.readFileSync(path, 'utf8');

// Replace "Go to Dashboard" with "Access Dashboard"
content = content.replace("Go to Dashboard", "Access Dashboard");

// Replace the {user ? ...} with {loading ? ... : user ? ...} in the nav
content = content.replace(/\{user \? \([\s\S]*?<\/Link>\s*\)\s*:\s*\([\s\S]*?<\/>\s*\)\}/,
`{loading ? (
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
              )}`);

// There is a second block down in the hero section:
// {user ? ( ...Access Dashboard... ) : ( ...Access Dashboard... Register as Student... )}
content = content.replace(/\{user \? \([\s\S]*?<\/Link>\s*\)\s*:\s*\([\s\S]*?Register as Student[\s\S]*?<\/>\s*\)\}/,
`{loading ? (
            <div className="h-10 w-10 animate-spin rounded-full border-b-2 border-primary dark:border-dark-primary mx-auto"></div>
          ) : user ? (
            <Link to="/dashboard" className="inline-flex items-center justify-center gap-2 rounded-full bg-primary dark:bg-dark-primary px-8 py-3.5 text-base font-medium text-white shadow-sm hover:bg-primary/90 dark:hover:bg-dark-primary/90 transition-colors focus:outline-none focus:ring-2 focus:ring-primary dark:focus:ring-dark-primary focus:ring-offset-2">
              Access Dashboard <ArrowRight className="h-4 w-4" />
            </Link>
          ) : (
            <>
              <Link to="/login" className="inline-flex items-center justify-center gap-2 rounded-full bg-primary dark:bg-dark-primary px-8 py-3.5 text-base font-medium text-white shadow-sm hover:bg-primary/90 dark:hover:bg-dark-primary/90 transition-colors focus:outline-none focus:ring-2 focus:ring-primary dark:focus:ring-dark-primary focus:ring-offset-2">
                Sign In
              </Link>
              <Link to="/register" className="inline-flex items-center justify-center rounded-full bg-surface dark:bg-dark-surface px-8 py-3.5 text-base font-medium text-text-primary dark:text-dark-text-primary shadow-sm ring-1 ring-inset ring-text-secondary/30 dark:ring-dark-text-secondary/30 hover:bg-background dark:hover:bg-dark-background dark:hover:bg-surface dark:hover:bg-dark-surface transition-colors">
                Register as Student
              </Link>
            </>
          )}`);

fs.writeFileSync(path, content, 'utf8');
