-- Check current row counts
SELECT 'branch' as table_name, COUNT(*) as row_count FROM hospital.branch
UNION ALL
SELECT 'department', COUNT(*) FROM hospital.department
UNION ALL
SELECT 'patient', COUNT(*) FROM hospital.patient
UNION ALL
SELECT 'doctor', COUNT(*) FROM hospital.doctor
UNION ALL
SELECT 'admission', COUNT(*) FROM hospital.admission
UNION ALL
SELECT 'procedure', COUNT(*) FROM hospital.procedure
UNION ALL
SELECT 'billing', COUNT(*) FROM hospital.billing
UNION ALL
SELECT 'outcome', COUNT(*) FROM hospital.outcome
UNION ALL
SELECT 'doctor_workload', COUNT(*) FROM hospital.doctor_workload
UNION ALL
SELECT 'bed_occupancy', COUNT(*) FROM hospital.bed_occupancy;

-- Admissions by branch
SELECT branch_id, COUNT(*) AS admissions
FROM hospital.admission
GROUP BY branch_id;


-- Admissions by department
SELECT department_id,COUNT (*)
FROM hospital.admission
GROUP BY department_id
ORDER BY 2 DESC;


