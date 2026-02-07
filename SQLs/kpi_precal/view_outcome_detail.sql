-- =====================================================
-- SPECIALIZED VIEW: Outcome Details
-- Name: view_outcome_detail
-- Description: Patient outcomes with detailed context for
--              quality metrics and readmission analysis
-- =====================================================
CREATE OR REPLACE VIEW view_outcome_detail AS
SELECT
    -- Primary Keys
    o.admission_id,
    a.patient_id,
    
    -- Foreign Keys
    a.department_id,
    a.branch_id,
    
    -- Dates
    a.admission_time,
    a.discharge_time,
    DATE(a.admission_time) AS admission_date,
    DATE(a.discharge_time) AS discharge_date,
    
    -- Outcome Details
    o.outcome_status,
    o.readmitted_30d,
    
    -- Outcome Categories
    CASE 
        WHEN o.outcome_status IN ('Recovered', 'Improved') THEN 'Positive'
        WHEN o.outcome_status = 'Transferred' THEN 'Neutral'
        WHEN o.outcome_status = 'Deceased' THEN 'Negative'
        ELSE 'Unknown'
    END AS outcome_category,
    
    -- Readmission Flag
    CASE 
        WHEN o.readmitted_30d = TRUE THEN 'Readmitted'
        ELSE 'Not Readmitted'
    END AS readmission_status,
    
    -- Patient Demographics
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
    
    -- Location Details
    b.branch_name,
    d.department_name,
    
    -- Admission Context
    a.admission_type,
    a.bed_type,
    
    -- Length of Stay
    CASE 
        WHEN a.discharge_time IS NOT NULL THEN
            ROUND(
                EXTRACT(EPOCH FROM (a.discharge_time - a.admission_time)) / 86400::numeric, 
                2
            )
        ELSE NULL 
    END AS length_of_stay_days,
    
    -- LOS Category
    CASE 
        WHEN a.discharge_time IS NOT NULL THEN
            CASE 
                WHEN EXTRACT(EPOCH FROM (a.discharge_time - a.admission_time)) / 86400 < 1 THEN 'Same Day'
                WHEN EXTRACT(EPOCH FROM (a.discharge_time - a.admission_time)) / 86400 BETWEEN 1 AND 3 THEN 'Short Stay (1-3 days)'
                WHEN EXTRACT(EPOCH FROM (a.discharge_time - a.admission_time)) / 86400 BETWEEN 4 AND 7 THEN 'Medium Stay (4-7 days)'
                WHEN EXTRACT(EPOCH FROM (a.discharge_time - a.admission_time)) / 86400 BETWEEN 8 AND 14 THEN 'Long Stay (8-14 days)'
                ELSE 'Extended Stay (15+ days)'
            END
        ELSE NULL
    END AS los_category,
    
    -- Financial Context
    bil.total_cost,
    bil.insurance_covered,
    (bil.total_cost - bil.insurance_covered) AS patient_payment,
    
    -- Procedure Count for this admission
    (
        SELECT COUNT(procedure_id)
        FROM hospital.procedure pr
        WHERE pr.admission_id = a.admission_id
    ) AS total_procedures_count,
    
    -- Emergency Procedure Flag
    (
        SELECT COUNT(procedure_id) > 0
        FROM hospital.procedure pr
        WHERE pr.admission_id = a.admission_id
          AND pr.emergency_flag = TRUE
    ) AS had_emergency_procedure,
    
    -- Risk Indicators
    CASE 
        WHEN p.age < 5 OR p.age > 70 THEN TRUE
        ELSE FALSE
    END AS is_high_risk_age,
    
    CASE 
        WHEN a.admission_type = 'Emergency' THEN TRUE
        ELSE FALSE
    END AS is_emergency_admission,
    
    -- Combined Risk Score (0-3)
    (
        CASE WHEN p.age < 5 OR p.age > 70 THEN 1 ELSE 0 END +
        CASE WHEN a.admission_type = 'Emergency' THEN 1 ELSE 0 END +
        CASE WHEN o.readmitted_30d = TRUE THEN 1 ELSE 0 END
    ) AS risk_score,
    
    -- Time Intelligence
    EXTRACT(MONTH FROM a.admission_time) AS admission_month,
    EXTRACT(YEAR FROM a.admission_time) AS admission_year,
    TO_CHAR(a.admission_time, 'YYYY-MM') AS year_month

FROM hospital.outcome o
INNER JOIN hospital.admission a ON o.admission_id = a.admission_id
LEFT JOIN hospital.patient p ON a.patient_id = p.patient_id
LEFT JOIN hospital.branch b ON a.branch_id = b.branch_id
LEFT JOIN hospital.department d ON a.department_id = d.department_id
LEFT JOIN hospital.billing bil ON a.admission_id = bil.admission_id

ORDER BY a.admission_time DESC;