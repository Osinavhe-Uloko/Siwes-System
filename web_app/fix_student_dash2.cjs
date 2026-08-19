const fs = require('fs');
const path = 'src/components/dashboards/StudentDashboard.tsx';
let content = fs.readFileSync(path, 'utf8');

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

content = content.replace(" </div> </div> </div> );}", uiHTML);
fs.writeFileSync(path, content, 'utf8');
