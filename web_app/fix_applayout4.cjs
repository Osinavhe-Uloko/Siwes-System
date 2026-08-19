const fs = require('fs');

const path = 'src/components/layout/AppLayout.tsx';
let content = fs.readFileSync(path, 'utf8');

const oldNotifs = `<div className="max-h-96 overflow-y-auto">
                  <div className="px-4 py-3 hover:bg-background dark:hover:bg-dark-background transition-colors border-b border-text-secondary/5 dark:border-dark-text-secondary/5">
                    <p className="text-sm text-text-primary dark:text-dark-text-primary">New compliance flag detected</p>
                    <p className="text-xs text-text-secondary dark:text-dark-text-secondary mt-1">2 hours ago</p>
                  </div>
                  <div className="px-4 py-3 hover:bg-background dark:hover:bg-dark-background transition-colors">
                    <p className="text-sm text-text-primary dark:text-dark-text-primary">Logbook entry reviewed</p>
                    <p className="text-xs text-text-secondary dark:text-dark-text-secondary mt-1">Yesterday</p>
                  </div>
                </div>
                <div className="px-4 py-2 border-t border-text-secondary/10 dark:border-dark-text-secondary/10 text-center">
                  <Link to="/dashboard" onClick={() => setShowNotifications(false)} className="text-xs font-medium text-primary dark:text-dark-primary hover:underline">
                    View all
                  </Link>
                </div>`;

const newNotifs = `<div className="max-h-96 overflow-y-auto">
                  <Link to="/dashboard/flags" onClick={() => setShowNotifications(false)} className="block px-4 py-3 hover:bg-background dark:hover:bg-dark-background transition-colors border-b border-text-secondary/5 dark:border-dark-text-secondary/5">
                    <p className="text-sm text-text-primary dark:text-dark-text-primary">New compliance flag detected</p>
                    <p className="text-xs text-text-secondary dark:text-dark-text-secondary mt-1">2 hours ago</p>
                  </Link>
                  <Link to="/dashboard/logbook" onClick={() => setShowNotifications(false)} className="block px-4 py-3 hover:bg-background dark:hover:bg-dark-background transition-colors">
                    <p className="text-sm text-text-primary dark:text-dark-text-primary">Logbook entry reviewed</p>
                    <p className="text-xs text-text-secondary dark:text-dark-text-secondary mt-1">Yesterday</p>
                  </Link>
                </div>
                <div className="px-4 py-2 border-t border-text-secondary/10 dark:border-dark-text-secondary/10 text-center">
                  <Link to="/dashboard/flags" onClick={() => setShowNotifications(false)} className="text-xs font-medium text-primary dark:text-dark-primary hover:underline">
                    View all flags
                  </Link>
                </div>`;

content = content.replace(oldNotifs, newNotifs);

fs.writeFileSync(path, content, 'utf8');
