-- =====================================================
-- DIMENSION TABLE: Date
-- Name: dim_date
-- Description: Complete calendar dimension for time intelligence
--              Covers full date range of hospital data
-- =====================================================
CREATE OR REPLACE VIEW dim_date AS
WITH date_range AS (
    -- Generate dates from earliest admission to future (for forecasting)
    SELECT 
        MIN(DATE(admission_time)) AS min_date,
        MAX(DATE(admission_time)) + INTERVAL '365 days' AS max_date
    FROM hospital.admission
),
date_series AS (
    SELECT 
        generate_series(
            (SELECT min_date FROM date_range),
            (SELECT max_date FROM date_range),
            '1 day'::interval
        )::DATE AS date
)
SELECT
    -- Primary Key
    date AS date_key,
    
    -- Date Components
    EXTRACT(YEAR FROM date) AS year,
    EXTRACT(MONTH FROM date) AS month,
    EXTRACT(DAY FROM date) AS day,
    EXTRACT(QUARTER FROM date) AS quarter,
    EXTRACT(WEEK FROM date) AS week_of_year,
    EXTRACT(DOW FROM date) AS day_of_week,  -- 0=Sunday, 6=Saturday
    EXTRACT(DOY FROM date) AS day_of_year,
    
    -- Formatted Strings
    TO_CHAR(date, 'YYYY-MM-DD') AS date_iso,
    TO_CHAR(date, 'DD-Mon-YYYY') AS date_formatted,
    TO_CHAR(date, 'Month') AS month_name,
    TO_CHAR(date, 'Mon') AS month_short,
    TO_CHAR(date, 'Day') AS day_name,
    TO_CHAR(date, 'Dy') AS day_short,
    TO_CHAR(date, 'YYYY-MM') AS year_month,
    TO_CHAR(date, 'YYYY-Q') AS year_quarter,
    
    -- Business Logic
    CASE 
        WHEN EXTRACT(DOW FROM date) IN (0, 6) THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    
    CASE 
        WHEN EXTRACT(DOW FROM date) IN (0, 6) THEN TRUE
        ELSE FALSE
    END AS is_weekend,
    
    CASE 
        WHEN EXTRACT(DOW FROM date) BETWEEN 1 AND 5 THEN TRUE
        ELSE FALSE
    END AS is_weekday,
    
    -- Relative Date Flags
    CASE 
        WHEN date = CURRENT_DATE THEN TRUE 
        ELSE FALSE 
    END AS is_today,
    
    CASE 
        WHEN date = CURRENT_DATE - 1 THEN TRUE 
        ELSE FALSE 
    END AS is_yesterday,
    
    CASE 
        WHEN date >= DATE_TRUNC('month', CURRENT_DATE) 
         AND date < DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month'
        THEN TRUE 
        ELSE FALSE 
    END AS is_current_month,
    
    CASE 
        WHEN date >= DATE_TRUNC('year', CURRENT_DATE) 
         AND date < DATE_TRUNC('year', CURRENT_DATE) + INTERVAL '1 year'
        THEN TRUE 
        ELSE FALSE 
    END AS is_current_year,
    
    -- Month Start/End Flags
    CASE 
        WHEN date = DATE_TRUNC('month', date) THEN TRUE 
        ELSE FALSE 
    END AS is_month_start,
    
    CASE 
        WHEN date = (DATE_TRUNC('month', date) + INTERVAL '1 month' - INTERVAL '1 day')::DATE 
        THEN TRUE 
        ELSE FALSE 
    END AS is_month_end

FROM date_series
ORDER BY date;