import { Briefcase, Building, MapPin, Calendar } from 'lucide-react';
import { useAuth } from '../contexts/AuthContext';

export function Placement() {
 const { user } = useAuth();
 
 // Dummy data representing placement
 const placementData = {
 companyName: 'Tech Innovators Ltd',
 industry: 'Software Development',
 address: '123 Tech Avenue, Lagos, Nigeria',
 startDate: '2026-01-10',
 endDate: '2026-07-10',
 status: 'Active',
 supervisorName: 'Jane Smith',
 supervisorEmail: 'jane.smith@techinnovators.com'
 };

 return (
 <div className="space-y-6">
 <div>
 <h2 className="text-2xl font-bold tracking-tight text-text-primary dark:text-dark-text-primary">Placement Details</h2>
 <p className="mt-1 text-sm text-text-secondary dark:text-dark-text-secondary">
 Information regarding your current industrial attachment.
 </p>
 </div>

 <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
 <div className="col-span-1 lg:col-span-2 space-y-6">
 <div className="bg-surface dark:bg-dark-surface rounded-2xl p-6 shadow-sm border border-text-secondary/20 dark:border-dark-text-secondary/20">
 <div className="flex items-center justify-between mb-6">
 <div className="flex items-center gap-4">
 <div className="h-12 w-12 rounded-xl bg-primary/10 dark:bg-dark-primary/10 border border-primary/20 dark:border-dark-primary/20 flex items-center justify-center">
 <Building className="h-6 w-6 text-primary dark:text-dark-primary" />
 </div>
 <div>
 <h3 className="text-lg font-bold text-text-primary dark:text-dark-text-primary">{placementData.companyName}</h3>
 <p className="text-sm text-text-secondary dark:text-dark-text-secondary">{placementData.industry}</p>
 </div>
 </div>
 <span className="inline-flex items-center rounded-full bg-status-approved/10 dark:bg-dark-status-approved/10 px-2.5 py-1 text-xs font-medium text-status-approved dark:text-dark-status-approved ring-1 ring-inset ring-status-approved dark:ring-dark-status-approved/20">
 {placementData.status}
 </span>
 </div>

 <dl className="grid grid-cols-1 sm:grid-cols-2 gap-x-4 gap-y-6">
 <div>
 <dt className="flex items-center gap-2 text-sm font-medium text-text-secondary dark:text-dark-text-secondary mb-1">
 <MapPin className="h-4 w-4" /> Location
 </dt>
 <dd className="text-sm text-text-primary dark:text-dark-text-primary">{placementData.address}</dd>
 </div>
 <div>
 <dt className="flex items-center gap-2 text-sm font-medium text-text-secondary dark:text-dark-text-secondary mb-1">
 <Calendar className="h-4 w-4" /> Duration
 </dt>
 <dd className="text-sm text-text-primary dark:text-dark-text-primary">
 {new Date(placementData.startDate).toLocaleDateString()} - {new Date(placementData.endDate).toLocaleDateString()}
 </dd>
 </div>
 </dl>
 </div>
 </div>

 <div className="col-span-1">
 <div className="bg-surface dark:bg-dark-surface rounded-2xl p-6 shadow-sm border border-text-secondary/20 dark:border-dark-text-secondary/20">
 <h3 className="text-base font-bold text-text-primary dark:text-dark-text-primary mb-4">Industry Supervisor</h3>
 <div className="flex items-center gap-3 mb-4">
 <div className="h-10 w-10 rounded-full bg-background dark:bg-dark-background flex items-center justify-center text-text-secondary dark:text-dark-text-secondary font-bold">
 {placementData.supervisorName.charAt(0)}
 </div>
 <div>
 <p className="text-sm font-medium text-text-primary dark:text-dark-text-primary">{placementData.supervisorName}</p>
 <p className="text-xs text-text-secondary dark:text-dark-text-secondary">{placementData.supervisorEmail}</p>
 </div>
 </div>
 <button className="w-full rounded-lg bg-surface dark:bg-dark-surface px-3 py-2 text-sm font-semibold text-text-primary dark:text-dark-text-primary shadow-sm ring-1 ring-inset ring-text-secondary/30 dark:ring-dark-text-secondary/30 hover:bg-background dark:hover:bg-dark-background transition-colors">
 Contact Supervisor
 </button>
 </div>
 </div>
 </div>
 </div>
 );
}
