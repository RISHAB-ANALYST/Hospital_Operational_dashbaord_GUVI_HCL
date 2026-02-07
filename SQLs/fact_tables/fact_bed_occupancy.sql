-- =====================================================
-- FACT TABLE: Bed Occupancy
-- Name: fact_bed_occupancy
-- Description: Hourly bed occupancy snapshots
-- =====================================================
CREATE OR REPLACE VIEW fact_bed_occupancy AS
SELECT
    -- Primary Key
    CONCAT('BO_', bo.department_id, '_', bo.snapshot_time) AS occupancy_id,
    
    -- Foreign Keys
    bo.department_id,
    bo.branch_id,
    
    -- Date/Time Fields
    bo.snapshot_time,
    DATE(bo.snapshot_time) AS occupancy_date,
    EXTRACT(HOUR FROM bo.snapshot_time) AS occupancy_hour,
    EXTRACT(DOW FROM bo.snapshot_time) AS day_of_week,
    EXTRACT(MONTH FROM bo.snapshot_time) AS occupancy_month,
    EXTRACT(YEAR FROM bo.snapshot_time) AS occupancy_year,
    TO_CHAR(bo.snapshot_time, 'YYYY-MM') AS year_month,
    TO_CHAR(bo.snapshot_time, 'Month') AS month_name,
    
    -- Time Category
    CASE 
        WHEN EXTRACT(HOUR FROM bo.snapshot_time) BETWEEN 6 AND 11 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM bo.snapshot_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        WHEN EXTRACT(HOUR FROM bo.snapshot_time) BETWEEN 18 AND 23 THEN 'Evening'
        ELSE 'Night'
    END AS time_of_day,
    
    CASE 
        WHEN EXTRACT(DOW FROM bo.snapshot_time) IN (0, 6) THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    
    -- Bed Occupancy Metrics
    bo.occupied_beds,
    br.total_beds AS total_branch_beds,
    
    -- Calculate department beds (proportional allocation or actual if available)
    -- Assuming equal distribution across departments for now
    ROUND(br.total_beds::NUMERIC / dept_count.dept_per_branch) AS total_department_beds,
    
    -- Occupancy Percentage
    ROUND(
        (bo.occupied_beds::NUMERIC / NULLIF(
            ROUND(br.total_beds::NUMERIC / dept_count.dept_per_branch), 0
        ) * 100), 
        2
    ) AS bed_occupancy_percentage,
    
    -- Available Beds
    (ROUND(br.total_beds::NUMERIC / dept_count.dept_per_branch) - bo.occupied_beds) AS available_beds,
    
    -- Over Capacity
    CASE 
        WHEN bo.occupied_beds > ROUND(br.total_beds::NUMERIC / dept_count.dept_per_branch)
        THEN (bo.occupied_beds - ROUND(br.total_beds::NUMERIC / dept_count.dept_per_branch))
        ELSE 0 
    END AS over_capacity_beds,
    
    -- Occupancy Category
    CASE 
        WHEN (bo.occupied_beds::NUMERIC / NULLIF(
            ROUND(br.total_beds::NUMERIC / dept_count.dept_per_branch), 0
        ) * 100) < 60 THEN 'Low'
        WHEN (bo.occupied_beds::NUMERIC / NULLIF(
            ROUND(br.total_beds::NUMERIC / dept_count.dept_per_branch), 0
        ) * 100) BETWEEN 60 AND 85 THEN 'Optimal'
        WHEN (bo.occupied_beds::NUMERIC / NULLIF(
            ROUND(br.total_beds::NUMERIC / dept_count.dept_per_branch), 0
        ) * 100) BETWEEN 85 AND 100 THEN 'High'
        ELSE 'Over-capacity'
    END AS occupancy_category,
    
    -- Location Details
    br.branch_name,
    dept.department_name

FROM hospital.bed_occupancy bo
INNER JOIN hospital.branch br ON bo.branch_id = br.branch_id
INNER JOIN hospital.department dept ON bo.department_id = dept.department_id
-- Count departments per branch for bed allocation
LEFT JOIN (
    SELECT branch_id, COUNT(*) AS dept_per_branch
    FROM hospital.department
    GROUP BY branch_id
) dept_count ON br.branch_id = dept_count.branch_id;