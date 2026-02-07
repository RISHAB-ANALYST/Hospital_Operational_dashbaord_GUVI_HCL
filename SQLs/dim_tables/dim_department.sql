-- =====================================================
-- DIMENSION TABLE: Department
-- Name: dim_department
-- Description: Hospital department master data
-- =====================================================
CREATE OR REPLACE VIEW dim_department AS
SELECT
    -- Primary Key
    d.department_id,
    
    -- Foreign Key
    d.branch_id,
    
    -- Department Details
    d.department_name,
    
    -- Branch Context (denormalized for convenience)
    b.branch_name,
    
    -- Department Type Classification
    CASE 
        WHEN d.department_name IN ('Emergency', 'ICU', 'Trauma') THEN 'Critical Care'
        WHEN d.department_name IN ('Cardiology', 'Oncology', 'Neurology') THEN 'Specialty'
        WHEN d.department_name IN ('Orthopedics', 'General Surgery') THEN 'Surgical'
        WHEN d.department_name IN ('Pediatrics', 'Obstetrics') THEN 'Maternal & Child'
        WHEN d.department_name = 'General Medicine' THEN 'General'
        ELSE 'Other'
    END AS department_type,
    
    -- Active Flag
    TRUE AS is_active

FROM hospital.department d
LEFT JOIN hospital.branch b ON d.branch_id = b.branch_id
ORDER BY b.branch_name, d.department_name;