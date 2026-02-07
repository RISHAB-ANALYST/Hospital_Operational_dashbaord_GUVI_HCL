-- =====================================================
-- FACT TABLE: Procedures
-- Name: fact_procedures
-- Description: Detailed procedure records with emergency flags,
--              timing analysis, and volume tracking
-- =====================================================
CREATE OR REPLACE VIEW fact_procedures AS
SELECT
    -- Primary Key
    pr.procedure_id,
    
    -- Foreign Keys (for relationships in Power BI)
    pr.admission_id,
    a.patient_id,
    a.department_id,
    a.branch_id,
    
    -- Date/Time Fields
    pr.procedure_time,
    DATE(pr.procedure_time) AS procedure_date,
    EXTRACT(HOUR FROM pr.procedure_time) AS procedure_hour,
    EXTRACT(DOW FROM pr.procedure_time) AS procedure_day_of_week,
    TO_CHAR(pr.procedure_time, 'Month') AS procedure_month_name,
    EXTRACT(MONTH FROM pr.procedure_time) AS procedure_month,
    EXTRACT(YEAR FROM pr.procedure_time) AS procedure_year,
    
    -- Procedure Details
    pr.procedure_type,
    pr.emergency_flag,
    
    -- Categorization
    CASE 
        WHEN pr.emergency_flag = TRUE THEN 'Emergency'
        ELSE 'Scheduled'
    END AS procedure_category,
    
    -- Patient Demographics (denormalized)
    p.age,
    CASE 
        WHEN p.age < 18 THEN 'Pediatric'
        WHEN p.age BETWEEN 18 AND 35 THEN 'Young Adult'
        WHEN p.age BETWEEN 36 AND 55 THEN 'Middle Age'
        WHEN p.age BETWEEN 56 AND 70 THEN 'Senior'
        ELSE 'Elderly'
    END AS age_group,
    p.gender,
    p.insurance_type,
    
    -- Location Details (denormalized)
    b.branch_name,
    d.department_name,
    
    -- Admission Context
    a.admission_type,
    a.bed_type,
    
    -- Count Flags (for easy aggregation)
    1 AS procedure_count,
    CASE WHEN pr.emergency_flag = TRUE THEN 1 ELSE 0 END AS emergency_procedure_count,
    CASE WHEN pr.emergency_flag = FALSE THEN 1 ELSE 0 END AS scheduled_procedure_count

FROM hospital.procedure pr
INNER JOIN hospital.admission a ON pr.admission_id = a.admission_id
LEFT JOIN hospital.patient p ON a.patient_id = p.patient_id
LEFT JOIN hospital.branch b ON a.branch_id = b.branch_id
LEFT JOIN hospital.department d ON a.department_id = d.department_id;