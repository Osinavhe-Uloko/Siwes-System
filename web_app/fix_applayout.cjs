const fs = require('fs');

const path = 'src/components/layout/AppLayout.tsx';
let content = fs.readFileSync(path, 'utf8');

// 1. Add state
content = content.replace("const [sidebarOpen, setSidebarOpen] = useState(false);",
`const [sidebarOpen, setSidebarOpen] = useState(false);
  const [showNotifications, setShowNotifications] = useState(false);`);

// 2. Add dropdown
const notifButton = `<button className="relative p-2 text-text-secondary dark:text-dark-text-secondary hover:text-text-secondary dark:hover:text-dark-text-secondary dark:hover:text-text-secondary dark:hover:text-dark-text-secondary hover:bg-background dark:hover:bg-dark-background dark:hover:bg-surface dark:hover:bg-dark-surface rounded-full transition-colors">
            <Bell className="h-5 w-5" />
            <span className="absolute top-1.5 right-1.5 flex h-2 w-2 rounded-full bg-status-overdue/90 dark:bg-dark-status-overdue/90 ring-2 ring-white dark:ring-slate-900"></span>
          </button>`;

const newNotifButton = `<div className="relative">
            <button 
              onClick={() => setShowNotifications(!showNotifications)}
              className="relative p-2 text-text-secondary dark:text-dark-text-secondary hover:text-text-primary dark:hover:text-dark-text-primary hover:bg-background dark:hover:bg-dark-background rounded-full transition-colors"
            >
              <Bell className="h-5 w-5" />
              <span className="absolute top-1.5 right-1.5 flex h-2 w-2 rounded-full bg-status-overdue/90 dark:bg-dark-status-overdue/90 ring-2 ring-white dark:ring-slate-900"></span>
            </button>
            
            {showNotifications && (
              <div className="absolute right-0 mt-2 w-80 rounded-xl bg-surface dark:bg-dark-surface shadow-lg border border-text-secondary/10 dark:border-dark-text-secondary/10 py-2 z-50">
                <div className="px-4 py-2 border-b border-text-secondary/10 dark:border-dark-text-secondary/10 flex justify-between items-center">
                  <h3 className="text-sm font-semibold text-text-primary dark:text-dark-text-primary">Notifications</h3>
                  <button onClick={() => setShowNotifications(false)} className="text-text-secondary dark:text-dark-text-secondary hover:text-text-primary dark:hover:text-dark-text-primary">
                    <X className="h-4 w-4" />
                  </button>
                </div>
                <div className="max-h-96 overflow-y-auto">
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
                </div>
              </div>
            )}
          </div>`;

content = content.replace(/<button className="relative p-2 text-text-secondary[\s\S]*?<\/button>/, newNotifButton);

fs.writeFileSync(path, content, 'utf8');
