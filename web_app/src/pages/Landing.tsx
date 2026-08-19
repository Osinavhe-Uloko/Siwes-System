import { Link } from 'react-router-dom';
import { ArrowRight, ShieldCheck, Users, BookOpen, Sun, Moon } from 'lucide-react';
import { useAuth } from '../contexts/AuthContext';
import { useTheme } from '../contexts/ThemeContext';

export function Landing() {
 const { user, loading } = useAuth();
 const { theme, toggleTheme } = useTheme();

 return (
 <div className="min-h-screen bg-background dark:bg-dark-background font-sans selection:bg-blue-200 dark:selection:bg-blue-900 transition-colors">
 {/* Navigation */}
 <nav className="fixed top-0 left-0 right-0 z-50 bg-surface dark:bg-dark-surface/80 backdrop-blur-md border-b border-text-secondary/20 dark:border-dark-text-secondary/20 transition-colors">
 <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
 <div className="flex justify-between items-center h-16">
 <div className="flex items-center gap-2">
 <img src="/logo.jpg" alt="ITF Logo" className="h-8 w-8 rounded-full object-contain" />
 <span className="text-xl font-bold tracking-tight text-text-primary dark:text-dark-text-primary ">SIWES Monitor</span>
 </div>
 <div className="flex items-center gap-3">
 <button onClick={toggleTheme} className="p-2 text-text-secondary dark:text-dark-text-secondary hover:text-text-secondary dark:hover:text-dark-text-secondary dark:hover:text-text-secondary dark:hover:text-dark-text-secondary hover:bg-background dark:hover:bg-dark-background dark:hover:bg-surface dark:hover:bg-dark-surface rounded-full transition-colors ">
 {theme === 'dark' ? <Sun className="h-5 w-5" /> : <Moon className="h-5 w-5" />}
 </button>
 {loading ? (
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
              )}
 </div>
 </div>
 </div>
 </nav>

 {/* Hero Section */}
 <main className="pt-32 pb-16 sm:pt-40 sm:pb-24 lg:pb-32 px-4 sm:px-6 lg:px-8 max-w-7xl mx-auto text-center">
 <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-primary/10 dark:bg-dark-primary/10 border border-primary/20 dark:border-dark-primary/20 text-primary dark:text-dark-primary text-sm font-medium mb-8">
 <span className="flex h-2 w-2 rounded-full bg-primary dark:bg-dark-primary "></span>
 Real-time Compliance Monitoring
 </div>
 <h1 className="text-5xl sm:text-7xl font-extrabold text-text-primary dark:text-dark-text-primary tracking-tight max-w-4xl mx-auto leading-tight">
 Next-Generation <span className="text-primary dark:text-dark-primary ">SIWES</span> Management
 </h1>
 <p className="mt-6 text-lg sm:text-xl text-text-secondary dark:text-dark-text-secondary max-w-2xl mx-auto leading-relaxed">
 Ensure transparency and accountability during industrial attachment with real-time anomaly detection, automated compliance flagging, and comprehensive supervisor tracking.
 </p>
 <div className="mt-10 flex flex-col sm:flex-row justify-center gap-3">
 {loading ? (
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
          )}
 </div>

 {/* Feature Grid */}
 <div className="mt-32 grid grid-cols-1 gap-8 sm:grid-cols-3 max-w-5xl mx-auto text-left">
 <div className="bg-surface dark:bg-dark-surface rounded-2xl p-8 shadow-sm border border-text-secondary/10 dark:border-dark-text-secondary/10 hover:shadow-md transition-shadow">
 <div className="h-12 w-12 bg-primary/20 dark:bg-dark-primary/20 rounded-xl flex items-center justify-center mb-6">
 <ShieldCheck className="h-6 w-6 text-primary dark:text-dark-primary " />
 </div>
 <h3 className="text-xl font-bold text-text-primary dark:text-dark-text-primary mb-3">Integrity Safeguards</h3>
 <p className="text-text-secondary dark:text-dark-text-secondary leading-relaxed">
 Automated anomaly detection prevents backdated clustering and ensures logbook entries are submitted in real-time.
 </p>
 </div>
 <div className="bg-surface dark:bg-dark-surface rounded-2xl p-8 shadow-sm border border-text-secondary/10 dark:border-dark-text-secondary/10 hover:shadow-md transition-shadow">
 <div className="h-12 w-12 bg-status-approved/20 dark:bg-dark-status-approved/20 rounded-xl flex items-center justify-center mb-6">
 <BookOpen className="h-6 w-6 text-status-approved dark:text-dark-status-approved " />
 </div>
 <h3 className="text-xl font-bold text-text-primary dark:text-dark-text-primary mb-3">Digital Logbooks</h3>
 <p className="text-text-secondary dark:text-dark-text-secondary leading-relaxed">
 Immutable server-timestamped entries that preserve record integrity while giving supervisors instant access for review.
 </p>
 </div>
 <div className="bg-surface dark:bg-dark-surface rounded-2xl p-8 shadow-sm border border-text-secondary/10 dark:border-dark-text-secondary/10 hover:shadow-md transition-shadow">
 <div className="h-12 w-12 bg-status-pending/20 dark:bg-dark-status-pending/20 rounded-xl flex items-center justify-center mb-6">
 <Users className="h-6 w-6 text-status-pending dark:text-dark-status-pending " />
 </div>
 <h3 className="text-xl font-bold text-text-primary dark:text-dark-text-primary mb-3">Active Monitoring</h3>
 <p className="text-text-secondary dark:text-dark-text-secondary leading-relaxed">
 Supervisors and coordinators receive instant flags for missed entries, overdue reviews, and inactive attachments.
 </p>
 </div>
 </div>
 </main>
 </div>
 );
}
