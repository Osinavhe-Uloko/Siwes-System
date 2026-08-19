export type Role = 'student' | 'institution_supervisor' | 'industry_supervisor' | 'coordinator';

export interface User {
 id: string;
 name: string;
 email: string;
 phone: string;
 role: Role;
 created_at: number;
}

export interface StudentProfile {
 matric_number: string;
 department: string;
 level: string;
 institution_supervisor_id?: string;
}

export interface Student extends User, StudentProfile {}

export interface Placement {
 id: string;
 student_id: string;
 company_name: string;
 company_address: string;
 state: string;
 industry_sector: string;
 start_date: string;
 end_date: string;
 industry_supervisor_id?: string;
}

export interface LogbookEntry {
 id: string;
 student_id: string;
 entry_date: string; // YYYY-MM-DD
 submitted_at: number; 
 content: string;
 week_number: number;
 status: 'pending' | 'reviewed' | 'flagged';
 supervisor_comment?: string;
 grade?: string;
}

export interface ComplianceFlag {
 id: string;
 student_id: string;
 logbook_entry_id?: string;
 flag_type: 'backdated_cluster' | 'missed_entry' | 'overdue_review' | 'inactive_supervisor';
 detected_at: number;
 resolved: boolean;
 resolved_by?: string;
 resolution_note?: string;
}

export interface SupervisorVisitLog {
 id: string;
 institution_supervisor_id: string;
 student_id: string;
 visit_date: string;
 mode: 'physical' | 'virtual';
 notes: string;
}

export interface Assessment {
 id: string;
 student_id: string;
 industry_score?: number;
 institution_score?: number;
 final_grade?: string;
 comments?: string;
}
