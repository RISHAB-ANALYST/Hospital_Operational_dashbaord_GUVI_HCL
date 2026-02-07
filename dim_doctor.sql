-- =====================================================
-- DIMENSION TABLE: Doctor
-- Name: dim_doctor
-- Description: Doctor master data with capacity info
-- =====================================================
CREATE OR REPLACE VIEW dim_doctor AS
SELECT
    -- Primary Key
    d.doctor_id,
    
    -- Foreign Key
    d.department_id,
    
    -- Capacity Info
    d.max_daily_hours,
    
    -- Department Context (denormalized)
    dept.department_name,
    dept.branch_id,
    b.branch_name,
    
    -- Capacity Categories
    CASE 
        WHEN d.max_daily_hours <= 6 THEN 'Part-Time'
        WHEN d.max_daily_hours BETWEEN 7 AND 8 THEN 'Full-Time'
        ELSE 'Extended Hours'
    END AS work_schedule_type,
    
    -- Weekly Capacity (assuming 5-day work week)
    (d.max_daily_hours * 5) AS max_weekly_hours,
    
    -- Active Flag
    TRUE AS is_active

FROM hospital.doctor d
LEFT JOIN hospital.department dept ON d.department_id = dept.department_id
LEFT JOIN hospital.branch b ON dept.branch_id = b.branch_id
ORDER BY dept.department_name, d.doctor_id;