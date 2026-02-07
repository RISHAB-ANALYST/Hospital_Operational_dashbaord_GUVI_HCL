-- =====================================================
-- FACT TABLE: Financials
-- Name: fact_financials
-- Description: Billing data with cost breakdowns, insurance coverage,
--              and financial KPIs per admission
-- =====================================================
CREATE OR REPLACE VIEW fact_financials AS
SELECT
    -- Primary Key
    b.admission_id,
    
    -- Foreign Keys (for relationships in Power BI)
    a.patient_id,
    a.department_id,
    a.branch_id,
    
    -- Date Fields (for time-based analysis)
    DATE(a.admission_time) AS admission_date,
    DATE(a.discharge_time) AS discharge_date,
    EXTRACT(MONTH FROM a.admission_time) AS billing_month,
    EXTRACT(YEAR FROM a.admission_time) AS billing_year,
    TO_CHAR(a.admission_time, 'YYYY-MM') AS year_month,
    
    -- Financial Metrics
    b.total_cost,
    b.insurance_covered,
    (b.total_cost - b.insurance_covered) AS patient_out_of_pocket,
    
    -- Cost Breakdown Percentages
    ROUND(
        (b.insurance_covered / NULLIF(b.total_cost, 0) * 100), 
        2
    ) AS insurance_coverage_percentage,
    
    ROUND(
        ((b.total_cost - b.insurance_covered) / NULLIF(b.total_cost, 0) * 100), 
        2
    ) AS patient_payment_percentage,
    
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
    br.branch_name,
    d.department_name,
    
    -- Admission Context
    a.admission_type,
    a.bed_type,
    
    -- Length of Stay (for cost per day calculation)
    CASE 
        WHEN a.discharge_time IS NOT NULL THEN
            ROUND(
                EXTRACT(EPOCH FROM (a.discharge_time - a.admission_time)) / 86400::numeric, 
                2
            )
        ELSE NULL 
    END AS length_of_stay_days,
    
    -- Cost per Day
    CASE 
        WHEN a.discharge_time IS NOT NULL THEN
            ROUND(
                b.total_cost / NULLIF(
                    EXTRACT(EPOCH FROM (a.discharge_time - a.admission_time)) / 86400::numeric, 
                    0
                ),
                2
            )
        ELSE NULL 
    END AS cost_per_day,
    
    -- Discharge Flag (for cost per discharge calculation)
    CASE WHEN a.discharge_time IS NOT NULL THEN 1 ELSE 0 END AS is_discharged

FROM hospital.billing b
INNER JOIN hospital.admission a ON b.admission_id = a.admission_id
LEFT JOIN hospital.patient p ON a.patient_id = p.patient_id
LEFT JOIN hospital.branch br ON a.branch_id = br.branch_id
LEFT JOIN hospital.department d ON a.department_id = d.department_id;