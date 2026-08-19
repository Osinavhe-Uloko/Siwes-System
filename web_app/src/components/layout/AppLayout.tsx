import { Outlet, Link, useNavigate, useLocation } from 'react-router-dom';
import { useAuth } from '../../contexts/AuthContext';
import { useTheme } from '../../contexts/ThemeContext';
import { 
 LayoutDashboard, 
 BookOpen, 
 Briefcase, 
 Users, 
 AlertTriangle, 
 Bell, 
 LogOut,
 User as UserIcon,
 Menu,
 X,
 Sun,
 Moon
} from 'lucide-react';
import { useState } from 'react';
import { clsx } from 'clsx';
import { twMerge } from 'tailwind-merge';

export function cn(...inputs: (string | undefined | null | false)[]) {
 return twMerge(clsx(inputs));
}

export function AppLayout() {
 const { user, signOut } = useAuth();
 const { theme, toggleTheme } = useTheme();
 const navigate = useNavigate();
 const location = useLocation();
 const [sidebarOpen, setSidebarOpen] = useState(false);
  const [showNotifications, setShowNotifications] = useState(false);

 const handleSignOut = async () => {
 await signOut();
 navigate('/');
 };

 const navItems = [
 { name: 'Dashboard', path: '/dashboard', icon: LayoutDashboard, roles: ['student', 'institution_supervisor', 'industry_supervisor', 'coordinator'] },
 { name: 'Logbook', path: '/dashboard/logbook', icon: BookOpen, roles: ['student'] },
 { name: 'Placement', path: '/dashboard/placement', icon: Briefcase, roles: ['student', 'industry_supervisor'] },
 { name: 'Supervisors', path: '/dashboard/supervisors', icon: Users, roles: ['coordinator'] },
 { name: 'Students', path: '/dashboard/students', icon: Users, roles: ['coordinator', 'institution_supervisor', 'industry_supervisor'] },
 { name: 'Flags', path: '/dashboard/flags', icon: AlertTriangle, roles: ['coordinator', 'institution_supervisor'] },
 ];

 const filteredNav = navItems.filter(item => item.roles.includes(user?.role || ''));

 return (
 <div className="flex h-screen bg-background dark:bg-dark-background font-sans selection:bg-blue-200 dark:selection:bg-blue-900 transition-colors">
 {/* Mobile sidebar backdrop */}
 {sidebarOpen && (
 <div 
 className="fixed inset-0 z-40 bg-primary dark:bg-dark-primary/40 dark:bg-black/60 backdrop-blur-sm lg:hidden transition-opacity"
 onClick={() => setSidebarOpen(false)}
 />
 )}

 {/* Sidebar */}
 <aside 
 className={cn(
 "fixed inset-y-0 left-0 z-50 w-72 bg-surface dark:bg-dark-surface border-r border-text-secondary/20 dark:border-dark-text-secondary/20 text-text-primary dark:text-dark-text-primary transition-transform lg:static lg:translate-x-0 flex flex-col",
 sidebarOpen ? "translate-x-0 shadow-2xl" : "-translate-x-full"
 )}
 >
 <div className="flex h-20 items-center justify-between px-6 border-b border-text-secondary/10 dark:border-dark-text-secondary/10 ">
 <Link to="/" className="flex items-center gap-2.5">
 <img src="/logo.jpg" alt="ITF Logo" className="h-8 w-8 rounded-full object-contain" />
 <span className="text-xl font-bold tracking-tight text-text-primary dark:text-dark-text-primary ">SIWES Monitor</span>
 </Link>
 <button className="lg:hidden text-text-secondary dark:text-dark-text-secondary hover:text-text-secondary dark:hover:text-dark-text-secondary dark:hover:text-surface dark:hover:text-dark-surface" onClick={() => setSidebarOpen(false)}>
 <X className="h-6 w-6" />
 </button>
 </div>

 <div className="flex-1 overflow-y-auto py-6 px-4">
 <div className="mb-8 px-2">
 <p className="text-xs font-semibold text-text-secondary dark:text-dark-text-secondary uppercase tracking-wider mb-3">Main Menu</p>
 <nav className="space-y-1">
 {filteredNav.map((item) => {
 const Icon = item.icon;
 const isActive = location.pathname === item.path || (item.path !== '/dashboard' && location.pathname.startsWith(item.path));
 return (
 <Link
 key={item.name}
 to={item.path}
 onClick={() => setSidebarOpen(false)}
 className={cn(
 "flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-medium transition-all duration-200",
 isActive 
 ? "bg-primary/10 dark:bg-dark-primary/10 text-primary dark:text-dark-primary shadow-sm shadow-blue-100/50 dark:shadow-none" 
 : "text-text-secondary dark:text-dark-text-secondary hover:bg-background dark:hover:bg-dark-background dark:hover:bg-surface dark:hover:bg-dark-surface hover:text-text-primary dark:hover:text-dark-text-primary dark:hover:text-surface dark:hover:text-dark-surface"
 )}
 >
 <Icon className={cn("h-5 w-5", isActive ? "text-primary dark:text-dark-primary " : "text-text-secondary dark:text-dark-text-secondary ")} />
 {item.name}
 </Link>
 );
 })}
 </nav>
 </div>
 </div>

 <div className="p-4 border-t border-text-secondary/10 dark:border-dark-text-secondary/10 ">
 <div className="flex items-center gap-3 px-3 py-3 rounded-xl bg-background dark:bg-dark-background mb-4 border border-text-secondary/10 dark:border-dark-text-secondary/10 ">
 <div className="h-10 w-10 rounded-full bg-primary/20 dark:bg-dark-primary/20 flex items-center justify-center text-primary dark:text-dark-primary font-bold">
 {user?.name?.charAt(0)}
 </div>
 <div className="flex-1 min-w-0">
 <p className="text-sm font-semibold text-text-primary dark:text-dark-text-primary truncate">{user?.name}</p>
 <p className="text-xs text-text-secondary dark:text-dark-text-secondary capitalize truncate">{user?.role?.replace('_', ' ')}</p>
 </div>
 </div>
 <button
 onClick={handleSignOut}
 className="flex w-full items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-medium text-text-secondary dark:text-dark-text-secondary transition-colors hover:bg-status-overdue/10 dark:hover:bg-dark-status-overdue/10 dark:hover:bg-status-overdue/90 dark:hover:bg-dark-status-overdue/90/20 hover:text-status-overdue dark:hover:text-dark-status-overdue dark:hover:text-status-overdue dark:hover:text-dark-status-overdue group"
 >
 <LogOut className="h-5 w-5 text-text-secondary dark:text-dark-text-secondary group-hover:text-red-500 dark:group-hover:text-status-overdue dark:hover:text-dark-status-overdue" />
 Sign Out
 </button>
 </div>
 </aside>

 {/* Main Content */}
 <main className="flex flex-1 flex-col overflow-hidden min-w-0 bg-background dark:bg-dark-background ">
 <header className="flex h-20 items-center justify-between border-b border-text-secondary/20 dark:border-dark-text-secondary/20 bg-surface dark:bg-dark-surface/80 backdrop-blur-md px-4 sm:px-6 lg:px-10 z-10 sticky top-0 transition-colors">
 <div className="flex items-center gap-4">
 <button 
 className="lg:hidden p-2 -ml-2 text-text-secondary dark:text-dark-text-secondary hover:bg-background dark:hover:bg-dark-background dark:hover:bg-surface dark:hover:bg-dark-surface rounded-lg"
 onClick={() => setSidebarOpen(true)}
 >
 <Menu className="h-6 w-6" />
 </button>
 <h1 className="text-xl font-bold text-text-primary dark:text-dark-text-primary hidden sm:block capitalize">
 {location.pathname.split('/').pop() === 'dashboard' ? 'Overview' : location.pathname.split('/').pop()}
 </h1>
 </div>
 
 <div className="flex items-center gap-3 sm:gap-5">
 <button onClick={toggleTheme} className="p-2 text-text-secondary dark:text-dark-text-secondary hover:text-text-secondary dark:hover:text-dark-text-secondary dark:hover:text-text-secondary dark:hover:text-dark-text-secondary hover:bg-background dark:hover:bg-dark-background dark:hover:bg-surface dark:hover:bg-dark-surface rounded-full transition-colors">
 {theme === 'dark' ? <Sun className="h-5 w-5" /> : <Moon className="h-5 w-5" />}
 </button>
 <div className="sm:relative">
            <button 
              onClick={() => setShowNotifications(!showNotifications)}
              className="relative p-2 text-text-secondary dark:text-dark-text-secondary hover:text-text-primary dark:hover:text-dark-text-primary hover:bg-background dark:hover:bg-dark-background rounded-full transition-colors"
            >
              <Bell className="h-5 w-5" />
              <span className="absolute top-1.5 right-1.5 flex h-2 w-2 rounded-full bg-status-overdue/90 dark:bg-dark-status-overdue/90 ring-2 ring-white dark:ring-slate-900"></span>
            </button>
            
            {showNotifications && (
              <div className="absolute right-4 left-4 top-16 sm:left-auto sm:right-0 sm:top-auto sm:mt-2 w-auto sm:w-80 rounded-xl bg-surface dark:bg-dark-surface shadow-lg border border-text-secondary/10 dark:border-dark-text-secondary/10 py-2 z-50 overflow-hidden transform origin-top-right">
                <div className="px-4 py-2 border-b border-text-secondary/10 dark:border-dark-text-secondary/10 flex justify-between items-center">
                  <h3 className="text-sm font-semibold text-text-primary dark:text-dark-text-primary">Notifications</h3>
                  <button onClick={() => setShowNotifications(false)} className="text-text-secondary dark:text-dark-text-secondary hover:text-text-primary dark:hover:text-dark-text-primary">
                    <X className="h-4 w-4" />
                  </button>
                </div>
                <div className="max-h-96 overflow-y-auto">
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
                </div>
              </div>
            )}
          </div>
 <div className="h-8 w-px bg-background dark:bg-dark-background hidden sm:block"></div>
 <div className="flex items-center gap-3">
 <div className="h-9 w-9 overflow-hidden rounded-full bg-gradient-to-tr from-blue-100 to-blue-50 border border-primary/20 dark:border-dark-primary/20 flex items-center justify-center text-primary dark:text-dark-primary shadow-sm">
 <UserIcon className="h-5 w-5" />
 </div>
 </div>
 </div>
 </header>
 
 <div className="flex-1 overflow-auto p-4 sm:p-6 lg:p-10 scroll-smooth">
 <div className="max-w-7xl mx-auto w-full">
 <Outlet />
 </div>
 </div>
 </main>
 </div>
 );
}
