import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider, useAuth } from './contexts/AuthContext';
import { ThemeProvider } from './contexts/ThemeContext';
import { AppLayout } from './components/layout/AppLayout';
import { Landing } from './pages/Landing';
import { Login } from './pages/Login';
import { Register } from './pages/Register';
import { Dashboard } from './pages/Dashboard';
import { Logbook } from './pages/Logbook';
import { Flags } from './pages/Flags';
import { Placement } from './pages/Placement';
import { Supervisors } from './pages/Supervisors';
import { Students } from './pages/Students';
import { StudentProfile } from './pages/StudentProfile';


function ProtectedRoute({ children, allowedRoles }: { children: React.ReactNode, allowedRoles?: string[] }) {
 const { user, loading } = useAuth();
 
 if (loading) {
 return (
 <div className="flex min-h-screen items-center justify-center bg-background dark:bg-dark-background">
 <div className="flex flex-col items-center gap-4">
 <div className="bg-primary dark:bg-dark-primary p-3 rounded-2xl animate-pulse">
 <img src="/logo.jpg" alt="ITF Logo" className="h-8 w-8 rounded-full object-contain bg-white p-1" />
 </div>
 <p className="text-sm font-medium text-text-secondary dark:text-dark-text-secondary animate-pulse">Authenticating...</p>
 </div>
 </div>
 );
 }
 if (!user) return <Navigate to="/login" />;
 if (allowedRoles && !allowedRoles.includes(user.role)) return <Navigate to="/dashboard" />;
 
 return <>{children}</>;
}

export default function App() {
 return (
 <ThemeProvider>
 <AuthProvider>
 <BrowserRouter>
 <Routes>
 <Route path="/" element={<Landing />} />
 <Route path="/login" element={<Login />} />
 <Route path="/register" element={<Register />} />
 
 <Route path="/dashboard" element={<ProtectedRoute><AppLayout /></ProtectedRoute>}>
 <Route index element={<Dashboard />} />
 <Route path="logbook" element={
 <ProtectedRoute allowedRoles={['student']}>
 <Logbook />
 </ProtectedRoute>
 } />
 <Route path="placement" element={
 <ProtectedRoute allowedRoles={['student', 'industry_supervisor']}>
 <Placement />
 </ProtectedRoute>
 } />
 <Route path="supervisors" element={
 <ProtectedRoute allowedRoles={['coordinator']}>
 <Supervisors />
 </ProtectedRoute>
 } />
 <Route path="students" element={
 <ProtectedRoute allowedRoles={['coordinator', 'institution_supervisor', 'industry_supervisor']}>
 <Students />
 </ProtectedRoute>
 } />
 <Route path="students/:id" element={
 <ProtectedRoute allowedRoles={['coordinator', 'institution_supervisor', 'industry_supervisor']}>
 <StudentProfile />
 </ProtectedRoute>
 } />
 <Route path="flags" element={
 <ProtectedRoute allowedRoles={['coordinator', 'institution_supervisor']}>
 <Flags />
 </ProtectedRoute>
 } />
 </Route>
 </Routes>
 </BrowserRouter>
 </AuthProvider>
 </ThemeProvider>
 );
}
