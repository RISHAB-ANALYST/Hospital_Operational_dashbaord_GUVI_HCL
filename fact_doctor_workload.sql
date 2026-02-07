-- =====================================================
-- FACT TABLE: Doctor Workload
-- Name: fact_doctor_workload
-- Description: Daily doctor utilization metrics
-- =====================================================
CREATE OR REPLACE VIEW fact_doctor_workload AS
SELECT
    -- Primary Key
    CONCAT('DW_', dw.doctor_id, '_', dw.work_date) AS workload_id,
    
    -- Foreign Keys
    dw.doctor_id,
    d.department_id,
    dept.branch_id,
    
    -- Date Fields
    dw.work_date,
    EXTRACT(DOW FROM dw.work_date) AS day_of_week,
    EXTRACT(MONTH FROM dw.work_date) AS work_month,
    EXTRACT(YEAR FROM dw.work_date) AS work_year,
    TO_CHAR(dw.work_date, 'YYYY-MM') AS year_month,
    TO_CHAR(dw.work_date, 'Month') AS month_name,
    CASE 
        WHEN EXTRACT(DOW FROM dw.work_date) IN (0, 6) THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    
    -- Doctor Workload Metrics
    dw.hours_booked,
    d.max_daily_hours,
    ROUND(
        (dw.hours_booked / NULLIF(d.max_daily_hours, 0) * 100), 
        2
    ) AS utilization_percentage,
    
    -- Utilization Category
    CASE 
        WHEN (dw.hours_booked / NULLIF(d.max_daily_hours, 0) * 100) < 50 THEN 'Underutilized'
        WHEN (dw.hours_booked / NULLIF(d.max_daily_hours, 0) * 100) BETWEEN 50 AND 80 THEN 'Optimal'
        WHEN (dw.hours_booked / NULLIF(d.max_daily_hours, 0) * 100) BETWEEN 80 AND 100 THEN 'High'
        ELSE 'Over-capacity'
    END AS utilization_category,
    
    -- Available Hours
    (d.max_daily_hours - dw.hours_booked) AS available_hours,
    
    -- Location Details
    br.branch_name,
    dept.department_name

FROM hospital.doctor_workload dw
INNER JOIN hospital.doctor d ON dw.doctor_id = d.doctor_id
INNER JOIN hospital.department dept ON d.department_id = dept.department_id
INNER JOIN hospital.branch br ON dept.branch_id = br.branch_id;

