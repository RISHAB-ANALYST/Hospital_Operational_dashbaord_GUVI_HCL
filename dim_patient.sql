-- =====================================================
-- DIMENSION TABLE: Patient
-- Name: dim_patient
-- Description: Patient master data with demographics
-- =====================================================
CREATE OR REPLACE VIEW dim_patient AS
SELECT
    -- Primary Key
    patient_id,
    
    -- Demographics
    age,
    gender,
    insurance_type,
    
    -- Age Grouping
    CASE 
        WHEN age < 18 THEN 'Pediatric'
        WHEN age BETWEEN 18 AND 35 THEN 'Young Adult'
        WHEN age BETWEEN 36 AND 55 THEN 'Middle Age'
        WHEN age BETWEEN 56 AND 70 THEN 'Senior'
        ELSE 'Elderly'
    END AS age_group,
    
    -- Age Bands (more granular)
    CASE 
        WHEN age < 10 THEN '0-9'
        WHEN age BETWEEN 10 AND 19 THEN '10-19'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        WHEN age BETWEEN 50 AND 59 THEN '50-59'
        WHEN age BETWEEN 60 AND 69 THEN '60-69'
        WHEN age BETWEEN 70 AND 79 THEN '70-79'
        ELSE '80+'
    END AS age_band,
    
    -- Insurance Category
    CASE 
        WHEN insurance_type IN ('Private', 'Premium') THEN 'Private Insurance'
        WHEN insurance_type = 'Government' THEN 'Government Insurance'
        WHEN insurance_type IN ('Self-pay', 'None') THEN 'Self-Pay'
        ELSE 'Other'
    END AS insurance_category,
    
    -- Risk Category (based on age)
    CASE 
        WHEN age < 5 OR age > 65 THEN 'High Risk'
        WHEN age BETWEEN 5 AND 17 OR age BETWEEN 56 AND 65 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS risk_category

FROM hospital.patient
ORDER BY patient_id;