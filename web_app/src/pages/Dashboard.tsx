import { useAuth } from '../contexts/AuthContext';
import { StudentDashboard } from '../components/dashboards/StudentDashboard';
import { CoordinatorDashboard } from '../components/dashboards/CoordinatorDashboard';
import { InstSupervisorDashboard } from '../components/dashboards/InstSupervisorDashboard';
import { IndSupervisorDashboard } from '../components/dashboards/IndSupervisorDashboard';

export function Dashboard() {
 const { user } = useAuth();

 if (!user) return null;

 switch (user.role) {
 case 'student':
 return <StudentDashboard />;
 case 'coordinator':
 return <CoordinatorDashboard />;
 case 'institution_supervisor':
 return <InstSupervisorDashboard />;
 case 'industry_supervisor':
 return <IndSupervisorDashboard />;
 default:
 return <div>Invalid role</div>;
 }
}
