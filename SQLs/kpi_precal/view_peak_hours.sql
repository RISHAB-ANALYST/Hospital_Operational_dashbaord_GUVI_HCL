-- =====================================================
-- SPECIALIZED VIEW: Peak Hours Analysis
-- Name: view_peak_hours
-- Description: Hourly patterns for admissions, procedures, and bed occupancy
--              to identify bottlenecks and optimize staffing
-- =====================================================
CREATE OR REPLACE VIEW view_peak_hours AS
WITH hourly_admissions AS (
    SELECT
        a.branch_id,
        a.department_id,
        DATE(a.admission_time) AS activity_date,
        EXTRACT(HOUR FROM a.admission_time) AS activity_hour,
        EXTRACT(DOW FROM a.admission_time) AS day_of_week,
        
        -- Admission Counts
        COUNT(a.admission_id) AS admission_count,
        COUNT(CASE WHEN a.admission_type = 'Emergency' THEN a.admission_id END) AS emergency_admission_count,
        COUNT(CASE WHEN a.admission_type != 'Emergency' THEN a.admission_id END) AS scheduled_admission_count
        
    FROM hospital.admission a
    GROUP BY a.branch_id, a.department_id, DATE(a.admission_time), EXTRACT(HOUR FROM a.admission_time), EXTRACT(DOW FROM a.admission_time)
),
hourly_procedures AS (
    SELECT
        a.branch_id,
        a.department_id,
        DATE(p.procedure_time) AS activity_date,
        EXTRACT(HOUR FROM p.procedure_time) AS activity_hour,
        
        -- Procedure Counts
        COUNT(p.procedure_id) AS procedure_count,
        COUNT(CASE WHEN p.emergency_flag = TRUE THEN p.procedure_id END) AS emergency_procedure_count
        
    FROM hospital.procedure p
    INNER JOIN hospital.admission a ON p.admission_id = a.admission_id
    GROUP BY a.branch_id, a.department_id, DATE(p.procedure_time), EXTRACT(HOUR FROM p.procedure_time)
),
hourly_bed_occupancy AS (
    SELECT
        bo.branch_id,
        bo.department_id,
        DATE(bo.snapshot_time) AS activity_date,
        EXTRACT(HOUR FROM bo.snapshot_time) AS activity_hour,
        
        -- Bed Metrics
        AVG(bo.occupied_beds) AS avg_occupied_beds,
        MAX(bo.occupied_beds) AS peak_occupied_beds,
        MIN(bo.occupied_beds) AS min_occupied_beds
        
    FROM hospital.bed_occupancy bo
    GROUP BY bo.branch_id, bo.department_id, DATE(bo.snapshot_time), EXTRACT(HOUR FROM bo.snapshot_time)
),
branch_capacity AS (
    SELECT
        d.branch_id,
        d.department_id,
        b.total_beds
    FROM hospital.department d
    INNER JOIN hospital.branch b ON d.branch_id = b.branch_id
)

-- FINAL COMBINED PEAK HOURS VIEW
SELECT
    -- Dimension Keys
    COALESCE(ha.branch_id, hp.branch_id, hb.branch_id) AS branch_id,
    COALESCE(ha.department_id, hp.department_id, hb.department_id) AS department_id,
    COALESCE(ha.activity_date, hp.activity_date, hb.activity_date) AS activity_date,
    COALESCE(ha.activity_hour, hp.activity_hour, hb.activity_hour) AS activity_hour,
    
    -- Day of Week
    COALESCE(ha.day_of_week, EXTRACT(DOW FROM COALESCE(hp.activity_date, hb.activity_date))) AS day_of_week,
    
    -- Day Type
    CASE 
        WHEN COALESCE(ha.day_of_week, EXTRACT(DOW FROM COALESCE(hp.activity_date, hb.activity_date))) IN (0, 6) 
        THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    
    -- Hour Category
    CASE 
        WHEN COALESCE(ha.activity_hour, hp.activity_hour, hb.activity_hour) BETWEEN 0 AND 5 THEN 'Night (12am-6am)'
        WHEN COALESCE(ha.activity_hour, hp.activity_hour, hb.activity_hour) BETWEEN 6 AND 11 THEN 'Morning (6am-12pm)'
        WHEN COALESCE(ha.activity_hour, hp.activity_hour, hb.activity_hour) BETWEEN 12 AND 17 THEN 'Afternoon (12pm-6pm)'
        ELSE 'Evening (6pm-12am)'
    END AS hour_category,
    
    -- Branch & Department Names
    b.branch_name,
    d.department_name,
    
    -- === ADMISSION METRICS ===
    COALESCE(ha.admission_count, 0) AS admission_count,
    COALESCE(ha.emergency_admission_count, 0) AS emergency_admission_count,
    COALESCE(ha.scheduled_admission_count, 0) AS scheduled_admission_count,
    
    -- === PROCEDURE METRICS ===
    COALESCE(hp.procedure_count, 0) AS procedure_count,
    COALESCE(hp.emergency_procedure_count, 0) AS emergency_procedure_count,
    
    -- === BED OCCUPANCY METRICS ===
    ROUND(COALESCE(hb.avg_occupied_beds, 0), 2) AS avg_occupied_beds,
    COALESCE(hb.peak_occupied_beds, 0) AS peak_occupied_beds,
    COALESCE(hb.min_occupied_beds, 0) AS min_occupied_beds,
    
    -- Bed Occupancy Percentage
    ROUND(
        CASE 
            WHEN bc.total_beds > 0 THEN
                (COALESCE(hb.avg_occupied_beds, 0) / bc.total_beds * 100)
            ELSE 0
        END, 
        2
    ) AS avg_bed_occupancy_pct,
    
    ROUND(
        CASE 
            WHEN bc.total_beds > 0 THEN
                (COALESCE(hb.peak_occupied_beds, 0) / bc.total_beds * 100)
            ELSE 0
        END, 
        2
    ) AS peak_bed_occupancy_pct,
    
    -- === BOTTLENECK INDICATORS ===
    
    -- Over Capacity Flag
    CASE 
        WHEN COALESCE(hb.peak_occupied_beds, 0) > bc.total_beds THEN TRUE
        ELSE FALSE
    END AS is_over_capacity,
    
    -- High Load Flag (>85% occupancy)
    CASE 
        WHEN bc.total_beds > 0 AND (COALESCE(hb.avg_occupied_beds, 0) / bc.total_beds * 100) > 85 THEN TRUE
        ELSE FALSE
    END AS is_high_load,
    
    -- Peak Hour Flag (top 10% of activity)
    CASE 
        WHEN (COALESCE(ha.admission_count, 0) + COALESCE(hp.procedure_count, 0)) >= (
            SELECT PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY (COALESCE(admission_count, 0) + COALESCE(procedure_count, 0)))
            FROM (
                SELECT 
                    ha2.admission_count,
                    hp2.procedure_count
                FROM hourly_admissions ha2
                FULL OUTER JOIN hourly_procedures hp2 
                    ON ha2.branch_id = hp2.branch_id 
                    AND ha2.department_id = hp2.department_id
                    AND ha2.activity_date = hp2.activity_date
                    AND ha2.activity_hour = hp2.activity_hour
            ) subq
        ) THEN TRUE
        ELSE FALSE
    END AS is_peak_hour,
    
    -- Total Activity Score (combined metric)
    (
        COALESCE(ha.admission_count, 0) * 2 +  -- Admissions weighted higher
        COALESCE(hp.procedure_count, 0) +
        COALESCE(ha.emergency_admission_count, 0) * 3  -- Emergencies weighted highest
    ) AS activity_score

FROM hourly_admissions ha
FULL OUTER JOIN hourly_procedures hp 
    ON ha.branch_id = hp.branch_id 
    AND ha.department_id = hp.department_id 
    AND ha.activity_date = hp.activity_date 
    AND ha.activity_hour = hp.activity_hour
FULL OUTER JOIN hourly_bed_occupancy hb 
    ON COALESCE(ha.branch_id, hp.branch_id) = hb.branch_id 
    AND COALESCE(ha.department_id, hp.department_id) = hb.department_id 
    AND COALESCE(ha.activity_date, hp.activity_date) = hb.activity_date 
    AND COALESCE(ha.activity_hour, hp.activity_hour) = hb.activity_hour
LEFT JOIN branch_capacity bc 
    ON COALESCE(ha.branch_id, hp.branch_id, hb.branch_id) = bc.branch_id 
    AND COALESCE(ha.department_id, hp.department_id, hb.department_id) = bc.department_id
LEFT JOIN hospital.branch b 
    ON COALESCE(ha.branch_id, hp.branch_id, hb.branch_id) = b.branch_id
LEFT JOIN hospital.department d 
    ON COALESCE(ha.department_id, hp.department_id, hb.department_id) = d.department_id

ORDER BY activity_date DESC, activity_hour, branch_name, department_name;