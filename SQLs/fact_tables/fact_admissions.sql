-- =====================================================
-- FACT TABLE: Admissions
-- Name: fact_admissions
-- Description: Core admission data with patient demographics,
--              location info, and length of stay calculations
-- =====================================================
CREATE OR REPLACE VIEW fact_admissions AS
SELECT
    -- Primary Key
    a.admission_id,
    
    -- Foreign Keys (for relationships in Power BI)
    a.patient_id,
    a.department_id,
    a.branch_id,
    
    -- Date/Time Fields
    a.admission_time,
    a.discharge_time,
    DATE(a.admission_time) AS admission_date,
    DATE(a.discharge_time) AS discharge_date,
    EXTRACT(HOUR FROM a.admission_time) AS admission_hour,
    EXTRACT(DOW FROM a.admission_time) AS admission_day_of_week,
    
    -- Admission Details
    a.admission_type,
    a.bed_type,
    
    -- Patient Demographics (denormalized for convenience)
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
    
    -- Location Details (denormalized for convenience)
    b.branch_name,
    d.department_name,
    
    -- Calculated Metrics
    CASE 
        WHEN a.discharge_time IS NOT NULL THEN
            ROUND(
                EXTRACT(EPOCH FROM (a.discharge_time - a.admission_time)) / 86400::numeric, 
                2
            )
        ELSE NULL 
    END AS length_of_stay_days,
    
    -- Status Flags
    CASE WHEN a.discharge_time IS NULL THEN 1 ELSE 0 END AS is_active_admission,
    CASE WHEN a.discharge_time IS NOT NULL THEN 1 ELSE 0 END AS is_discharged

FROM hospital.admission a
LEFT JOIN hospital.patient p ON a.patient_id = p.patient_id
LEFT JOIN hospital.branch b ON a.branch_id = b.branch_id
LEFT JOIN hospital.department d ON a.department_id = d.department_id;


---

-- ## **What This Query Provides:**

-- ✅ **All admission records** with one row per admission  
-- ✅ **Pre-calculated LOS** (Length of Stay) in days  
-- ✅ **Patient demographics** built-in (age, gender, insurance)  
-- ✅ **Location details** (branch name, department name)  
-- ✅ **Time intelligence fields** (hour, day of week)  
-- ✅ **Status flags** (active vs discharged)  
-- ✅ **Age groups** pre-categorized  /

---
