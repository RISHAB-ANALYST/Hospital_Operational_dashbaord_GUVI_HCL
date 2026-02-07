-- =====================================================
-- SPECIALIZED VIEW: KPI Summary
-- Name: view_kpi_summary
-- Description: Pre-calculated KPIs aggregated at different levels
--              for fast dashboard card rendering
-- =====================================================
CREATE OR REPLACE VIEW view_kpi_summary AS
WITH admission_metrics AS (
    SELECT
        a.branch_id,
        a.department_id,
        DATE(a.admission_time) AS metric_date,
        
        -- Admission Counts
        COUNT(DISTINCT a.admission_id) AS total_admissions,
        COUNT(DISTINCT CASE WHEN a.discharge_time IS NOT NULL THEN a.admission_id END) AS total_discharges,
        COUNT(DISTINCT CASE WHEN a.discharge_time IS NULL THEN a.admission_id END) AS active_admissions,
        
        -- Emergency vs Scheduled
        COUNT(DISTINCT CASE WHEN a.admission_type = 'Emergency' THEN a.admission_id END) AS emergency_admissions,
        COUNT(DISTINCT CASE WHEN a.admission_type != 'Emergency' THEN a.admission_id END) AS scheduled_admissions,
        
        -- Length of Stay
        AVG(
            CASE 
                WHEN a.discharge_time IS NOT NULL THEN
                    EXTRACT(EPOCH FROM (a.discharge_time - a.admission_time)) / 86400
            END
        ) AS avg_length_of_stay_days,
        
        -- Demographics
        COUNT(DISTINCT a.patient_id) AS unique_patients
        
    FROM hospital.admission a
    GROUP BY a.branch_id, a.department_id, DATE(a.admission_time)
),
procedure_metrics AS (
    SELECT
        a.branch_id,
        a.department_id,
        DATE(p.procedure_time) AS metric_date,
        
        -- Procedure Volumes
        COUNT(p.procedure_id) AS total_procedures,
        COUNT(CASE WHEN p.emergency_flag = TRUE THEN p.procedure_id END) AS emergency_procedures,
        COUNT(CASE WHEN p.emergency_flag = FALSE THEN p.procedure_id END) AS scheduled_procedures
        
    FROM hospital.procedure p
    INNER JOIN hospital.admission a ON p.admission_id = a.admission_id
    GROUP BY a.branch_id, a.department_id, DATE(p.procedure_time)
),
financial_metrics AS (
    SELECT
        a.branch_id,
        a.department_id,
        DATE(a.admission_time) AS metric_date,
        
        -- Cost Metrics
        AVG(b.total_cost) AS avg_cost_per_patient,
        SUM(b.total_cost) AS total_revenue,
        SUM(b.insurance_covered) AS total_insurance_covered,
        SUM(b.total_cost - b.insurance_covered) AS total_patient_payment,
        
        -- Cost per Discharge
        AVG(
            CASE 
                WHEN a.discharge_time IS NOT NULL THEN b.total_cost
            END
        ) AS avg_cost_per_discharge
        
    FROM hospital.billing b
    INNER JOIN hospital.admission a ON b.admission_id = a.admission_id
    GROUP BY a.branch_id, a.department_id, DATE(a.admission_time)
),
outcome_metrics AS (
    SELECT
        a.branch_id,
        a.department_id,
        DATE(a.admission_time) AS metric_date,
        
        -- Outcome Counts
        COUNT(o.admission_id) AS total_outcomes_recorded,
        COUNT(CASE WHEN o.readmitted_30d = TRUE THEN o.admission_id END) AS total_readmissions,
        
        -- Outcome Status
        COUNT(CASE WHEN o.outcome_status = 'Recovered' THEN o.admission_id END) AS recovered_count,
        COUNT(CASE WHEN o.outcome_status = 'Improved' THEN o.admission_id END) AS improved_count,
        COUNT(CASE WHEN o.outcome_status = 'Transferred' THEN o.admission_id END) AS transferred_count,
        COUNT(CASE WHEN o.outcome_status = 'Deceased' THEN o.admission_id END) AS deceased_count
        
    FROM hospital.outcome o
    INNER JOIN hospital.admission a ON o.admission_id = a.admission_id
    GROUP BY a.branch_id, a.department_id, DATE(a.admission_time)
),
doctor_metrics AS (
    SELECT
        dept.branch_id,
        dw.doctor_id,
        d.department_id,
        dw.work_date AS metric_date,
        
        -- Doctor Utilization
        AVG(dw.hours_booked / NULLIF(d.max_daily_hours, 0) * 100) AS avg_doctor_utilization_pct,
        SUM(dw.hours_booked) AS total_hours_booked,
        SUM(d.max_daily_hours) AS total_hours_available
        
    FROM hospital.doctor_workload dw
    INNER JOIN hospital.doctor d ON dw.doctor_id = d.doctor_id
    INNER JOIN hospital.department dept ON d.department_id = dept.department_id
    GROUP BY dept.branch_id, dw.doctor_id, d.department_id, dw.work_date
),
bed_metrics AS (
    SELECT
        bo.branch_id,
        bo.department_id,
        DATE(bo.snapshot_time) AS metric_date,
        
        -- Bed Occupancy (daily average)
        AVG(bo.occupied_beds) AS avg_occupied_beds,
        MAX(bo.occupied_beds) AS peak_occupied_beds,
        
        -- Assuming total_beds from branch/department join
        AVG(
            CASE 
                WHEN b.total_beds > 0 THEN
                    (bo.occupied_beds::NUMERIC / b.total_beds * 100)
            END
        ) AS avg_bed_occupancy_pct
        
    FROM hospital.bed_occupancy bo
    INNER JOIN hospital.branch b ON bo.branch_id = b.branch_id
    GROUP BY bo.branch_id, bo.department_id, DATE(bo.snapshot_time)
)

-- FINAL COMBINED KPI SUMMARY
SELECT
    -- Dimension Keys
    COALESCE(am.branch_id, pm.branch_id, fm.branch_id, om.branch_id, dm.branch_id, bm.branch_id) AS branch_id,
    COALESCE(am.department_id, pm.department_id, fm.department_id, om.department_id, dm.department_id, bm.department_id) AS department_id,
    COALESCE(am.metric_date, pm.metric_date, fm.metric_date, om.metric_date, dm.metric_date, bm.metric_date) AS metric_date,
    
    -- Date Components
    EXTRACT(YEAR FROM COALESCE(am.metric_date, pm.metric_date, fm.metric_date, om.metric_date, dm.metric_date, bm.metric_date)) AS year,
    EXTRACT(MONTH FROM COALESCE(am.metric_date, pm.metric_date, fm.metric_date, om.metric_date, dm.metric_date, bm.metric_date)) AS month,
    EXTRACT(QUARTER FROM COALESCE(am.metric_date, pm.metric_date, fm.metric_date, om.metric_date, dm.metric_date, bm.metric_date)) AS quarter,
    
    -- Branch & Department Names
    b.branch_name,
    d.department_name,
    
    -- === ADMISSION KPIs ===
    COALESCE(am.total_admissions, 0) AS total_admissions,
    COALESCE(am.total_discharges, 0) AS total_discharges,
    COALESCE(am.active_admissions, 0) AS active_admissions,
    COALESCE(am.emergency_admissions, 0) AS emergency_admissions,
    COALESCE(am.scheduled_admissions, 0) AS scheduled_admissions,
    COALESCE(am.unique_patients, 0) AS unique_patients,
    ROUND(COALESCE(am.avg_length_of_stay_days, 0), 2) AS avg_length_of_stay_days,
    
    -- === PROCEDURE KPIs ===
    COALESCE(pm.total_procedures, 0) AS total_procedures,
    COALESCE(pm.emergency_procedures, 0) AS emergency_procedures,
    COALESCE(pm.scheduled_procedures, 0) AS scheduled_procedures,
    
    -- Emergency vs Scheduled Ratio
    ROUND(
        CASE 
            WHEN COALESCE(pm.scheduled_procedures, 0) > 0 THEN
                COALESCE(pm.emergency_procedures, 0)::NUMERIC / pm.scheduled_procedures
            ELSE 0
        END, 
        2
    ) AS emergency_to_scheduled_ratio,
    
    -- === FINANCIAL KPIs ===
    ROUND(COALESCE(fm.avg_cost_per_patient, 0), 2) AS avg_cost_per_patient,
    ROUND(COALESCE(fm.avg_cost_per_discharge, 0), 2) AS avg_cost_per_discharge,
    ROUND(COALESCE(fm.total_revenue, 0), 2) AS total_revenue,
    ROUND(COALESCE(fm.total_insurance_covered, 0), 2) AS total_insurance_covered,
    ROUND(COALESCE(fm.total_patient_payment, 0), 2) AS total_patient_payment,
    
    -- === OUTCOME KPIs ===
    COALESCE(om.total_outcomes_recorded, 0) AS total_outcomes_recorded,
    COALESCE(om.total_readmissions, 0) AS total_readmissions,
    
    -- 30-Day Readmission Rate
    ROUND(
        CASE 
            WHEN COALESCE(om.total_outcomes_recorded, 0) > 0 THEN
                (COALESCE(om.total_readmissions, 0)::NUMERIC / om.total_outcomes_recorded * 100)
            ELSE 0
        END, 
        2
    ) AS readmission_rate_pct,
    
    COALESCE(om.recovered_count, 0) AS recovered_count,
    COALESCE(om.improved_count, 0) AS improved_count,
    COALESCE(om.transferred_count, 0) AS transferred_count,
    COALESCE(om.deceased_count, 0) AS deceased_count,
    
    -- === RESOURCE KPIs ===
    ROUND(COALESCE(dm.avg_doctor_utilization_pct, 0), 2) AS avg_doctor_utilization_pct,
    ROUND(COALESCE(dm.total_hours_booked, 0), 2) AS total_doctor_hours_booked,
    ROUND(COALESCE(dm.total_hours_available, 0), 2) AS total_doctor_hours_available,
    
    -- === BED OCCUPANCY KPIs ===
    ROUND(COALESCE(bm.avg_occupied_beds, 0), 2) AS avg_occupied_beds,
    COALESCE(bm.peak_occupied_beds, 0) AS peak_occupied_beds,
    ROUND(COALESCE(bm.avg_bed_occupancy_pct, 0), 2) AS avg_bed_occupancy_pct

FROM admission_metrics am
FULL OUTER JOIN procedure_metrics pm 
    ON am.branch_id = pm.branch_id 
    AND am.department_id = pm.department_id 
    AND am.metric_date = pm.metric_date
FULL OUTER JOIN financial_metrics fm 
    ON COALESCE(am.branch_id, pm.branch_id) = fm.branch_id 
    AND COALESCE(am.department_id, pm.department_id) = fm.department_id 
    AND COALESCE(am.metric_date, pm.metric_date) = fm.metric_date
FULL OUTER JOIN outcome_metrics om 
    ON COALESCE(am.branch_id, pm.branch_id, fm.branch_id) = om.branch_id 
    AND COALESCE(am.department_id, pm.department_id, fm.department_id) = om.department_id 
    AND COALESCE(am.metric_date, pm.metric_date, fm.metric_date) = om.metric_date
FULL OUTER JOIN doctor_metrics dm 
    ON COALESCE(am.branch_id, pm.branch_id, fm.branch_id, om.branch_id) = dm.branch_id 
    AND COALESCE(am.department_id, pm.department_id, fm.department_id, om.department_id) = dm.department_id 
    AND COALESCE(am.metric_date, pm.metric_date, fm.metric_date, om.metric_date) = dm.metric_date
FULL OUTER JOIN bed_metrics bm 
    ON COALESCE(am.branch_id, pm.branch_id, fm.branch_id, om.branch_id, dm.branch_id) = bm.branch_id 
    AND COALESCE(am.department_id, pm.department_id, fm.department_id, om.department_id, dm.department_id) = bm.department_id 
    AND COALESCE(am.metric_date, pm.metric_date, fm.metric_date, om.metric_date, dm.metric_date) = bm.metric_date
LEFT JOIN hospital.branch b 
    ON COALESCE(am.branch_id, pm.branch_id, fm.branch_id, om.branch_id, dm.branch_id, bm.branch_id) = b.branch_id
LEFT JOIN hospital.department d 
    ON COALESCE(am.department_id, pm.department_id, fm.department_id, om.department_id, dm.department_id, bm.department_id) = d.department_id

ORDER BY metric_date DESC, branch_name, department_name;