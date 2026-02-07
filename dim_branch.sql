-- =====================================================
-- DIMENSION TABLE: Branch
-- Name: dim_branch
-- Description: Hospital branch master data with capacity info
-- =====================================================
CREATE OR REPLACE VIEW dim_branch AS
SELECT
    -- Primary Key
    branch_id,
    
    -- Branch Details
    branch_name,
    total_beds,
    icu_beds,
    
    -- Calculated Fields
    (total_beds - icu_beds) AS general_beds,
    
    ROUND(
        (icu_beds::NUMERIC / NULLIF(total_beds, 0) * 100), 
        2
    ) AS icu_bed_percentage,
    
    -- Capacity Categories
    CASE 
        WHEN total_beds < 100 THEN 'Small'
        WHEN total_beds BETWEEN 100 AND 299 THEN 'Medium'
        WHEN total_beds BETWEEN 300 AND 499 THEN 'Large'
        ELSE 'Very Large'
    END AS branch_size_category,
    
    -- Active Flag (in case you want to mark inactive branches)
    TRUE AS is_active

FROM hospital.branch
ORDER BY branch_name;