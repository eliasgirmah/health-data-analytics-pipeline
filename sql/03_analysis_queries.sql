-- ============================================================================
-- HEALTH DATA ANALYTICS PIPELINE
-- File: 03_analysis_queries.sql
-- Purpose: OLAP-style analytical queries for health clinic data
-- Based on: OLTP/OLAP Database Design Concepts (PDF Chapter 1)
-- ============================================================================

-- ============================================================================
-- SECTION 1: BASIC QUERIES (OLTP-style lookups)
-- Purpose: Support daily transactions & operational queries
-- PDF Concept: "OLTP Queries: simple transactions & frequent updates"
-- ============================================================================

-- Query 1.1: View all patients (Basic SELECT)
-- Business Question: Show all registered patients in the system
SELECT * FROM patients;

-- Query 1.2: Filter patients by country (WHERE clause)
-- Business Question: Find all patients from a specific country for regional reporting
SELECT first_name, last_name, country, registration_date
FROM patients
WHERE country = 'Kenya';

-- Query 1.3: Filter + Sort patients (WHERE + ORDER BY)
-- Business Question: Find male patients from Uganda, sorted by registration date
SELECT first_name, last_name, registration_date
FROM patients
WHERE gender = 'Male' AND country = 'Uganda'
ORDER BY registration_date DESC;

-- ============================================================================
-- SECTION 2: JOIN QUERIES (Connecting Normalized Tables)
-- Purpose: Retrieve related data across normalized schema
-- PDF Concept: "Logical data model: defines tables, columns, relationships"
-- PDF Concept: "Views: What joins will be done most often?"
-- ============================================================================

-- Query 2.1: Join patients with visits (2-table JOIN)
-- Business Question: Show patient names with their visit dates and locations
SELECT 
    p.first_name,
    p.last_name,
    v.visit_date,
    v.clinic_location,
    v.doctor_name
FROM patients p
JOIN visits v ON p.patient_id = v.patient_id
ORDER BY v.visit_date DESC;

-- Query 2.2: Join all three tables (3-table JOIN)
-- Business Question: Show patient names with their lab test results
SELECT 
    p.first_name,
    p.last_name,
    v.visit_date,
    l.test_type,
    l.test_value,
    l.test_date
FROM patients p
JOIN visits v ON p.patient_id = v.patient_id
JOIN lab_results l ON v.visit_id = l.visit_id
ORDER BY p.patient_id, l.test_date;

-- Query 2.3: Filter JOIN for specific test type
-- Business Question: Show all patients with their CD4 Count results
SELECT 
    p.first_name,
    p.last_name,
    l.test_value AS cd4_count
FROM patients p
JOIN visits v ON p.patient_id = v.patient_id
JOIN lab_results l ON v.visit_id = l.visit_id
WHERE l.test_type = 'CD4 Count'
ORDER BY cd4_count ASC;

-- ============================================================================
-- SECTION 3: AGGREGATION QUERIES (OLAP-style analysis)
-- Purpose: Report and analyze data across groups
-- PDF Concept: "OLAP Queries: complex, aggregate queries & limited updates"
-- PDF Concept: "OLAP Design: subject-oriented, consolidated, historical"
-- ============================================================================

-- Query 3.1: Count patients by country (GROUP BY)
-- Business Question: How many patients are registered per country?
SELECT 
    country,
    COUNT(*) AS patient_count
FROM patients
GROUP BY country
ORDER BY patient_count DESC;

-- Query 3.2: Average CD4 count by clinic (Aggregate + GROUP BY)
-- Business Question: What is the average CD4 count per clinic location?
SELECT 
    v.clinic_location,
    AVG(l.test_value) AS avg_cd4_count,
    COUNT(*) AS test_count
FROM visits v
JOIN lab_results l ON v.visit_id = l.visit_id
WHERE l.test_type = 'CD4 Count'
GROUP BY v.clinic_location
ORDER BY avg_cd4_count DESC;

-- Query 3.3: Filter aggregates with HAVING clause
-- Business Question: Which clinics have average CD4 count below 400? (At-risk clinics)
SELECT 
    v.clinic_location,
    AVG(l.test_value) AS avg_cd4_count,
    COUNT(*) AS test_count
FROM visits v
JOIN lab_results l ON v.visit_id = l.visit_id
WHERE l.test_type = 'CD4 Count'
GROUP BY v.clinic_location
HAVING AVG(l.test_value) < 400
ORDER BY avg_cd4_count ASC;

-- ============================================================================
-- SECTION 4: COMMON TABLE EXPRESSIONS (CTEs)
-- Purpose: Make complex queries readable and modular
-- PDF Concept: "Logical data model: defines tables, columns, relationships"
-- Engineering Best Practice: Modular, maintainable query design
-- ============================================================================

-- Query 4.1: CTE for clinic performance analysis
-- Business Question: Identify clinics needing additional resources (avg CD4 < 400)
WITH clinic_performance AS (
    SELECT 
        v.clinic_location,
        AVG(l.test_value) AS avg_cd4,
        COUNT(*) AS total_tests,
        MIN(l.test_value) AS min_cd4,
        MAX(l.test_value) AS max_cd4
    FROM visits v
    JOIN lab_results l ON v.visit_id = l.visit_id
    WHERE l.test_type = 'CD4 Count'
    GROUP BY v.clinic_location
)
SELECT 
    clinic_location,
    avg_cd4,
    total_tests,
    min_cd4,
    max_cd4,
    CASE 
        WHEN avg_cd4 < 350 THEN 'Critical - Immediate Support Needed'
        WHEN avg_cd4 < 400 THEN 'At Risk - Monitor Closely'
        ELSE 'Adequate'
    END AS resource_priority
FROM clinic_performance
ORDER BY avg_cd4 ASC;

-- Query 4.2: CTE for patient visit frequency
-- Business Question: Which patients have multiple visits? (Follow-up compliance)
WITH patient_visit_counts AS (
    SELECT 
        p.patient_id,
        p.first_name,
        p.last_name,
        p.country,
        COUNT(v.visit_id) AS visit_count
    FROM patients p
    LEFT JOIN visits v ON p.patient_id = v.patient_id
    GROUP BY p.patient_id, p.first_name, p.last_name, p.country
)
SELECT 
    patient_id,
    first_name,
    last_name,
    country,
    visit_count,
    CASE 
        WHEN visit_count >= 3 THEN 'High Compliance'
        WHEN visit_count = 2 THEN 'Moderate Compliance'
        WHEN visit_count = 1 THEN 'Low Compliance'
        ELSE 'No Visits Recorded'
    END AS compliance_level
FROM patient_visit_counts
ORDER BY visit_count DESC;

-- ============================================================================
-- SECTION 5: CASE STATEMENTS (Risk Categorization)
-- Purpose: Create custom categories for health indicators
-- PDF Concept: "OLAP Design: subject-oriented" (categorize by risk level)
-- Health Analytics: HIV Care Cascade & Risk Stratification
-- ============================================================================

-- Query 5.1: Patient risk categorization by CD4 count
-- Business Question: Categorize patients by risk level for prioritization
SELECT 
    p.first_name,
    p.last_name,
    p.country,
    l.test_value AS cd4_count,
    l.test_date,
    CASE 
        WHEN l.test_value < 200 THEN 'Critical - Immediate Intervention'
        WHEN l.test_value >= 200 AND l.test_value < 350 THEN 'High Risk - Priority Care'
        WHEN l.test_value >= 350 AND l.test_value < 500 THEN 'Moderate Risk - Regular Monitoring'
        ELSE 'Low Risk - Standard Care'
    END AS risk_level
FROM patients p
JOIN visits v ON p.patient_id = v.patient_id
JOIN lab_results l ON v.visit_id = l.visit_id
WHERE l.test_type = 'CD4 Count'
ORDER BY 
    CASE 
        WHEN l.test_value < 200 THEN 1
        WHEN l.test_value >= 200 AND l.test_value < 350 THEN 2
        WHEN l.test_value >= 350 AND l.test_value < 500 THEN 3
        ELSE 4
    END,
    p.last_name;

-- Query 5.2: Clinic risk summary with categorization
-- Business Question: Summarize clinic performance by risk category
WITH clinic_risk_summary AS (
    SELECT 
        v.clinic_location,
        COUNT(*) AS total_patients,
        SUM(CASE WHEN l.test_value < 200 THEN 1 ELSE 0 END) AS critical_count,
        SUM(CASE WHEN l.test_value >= 200 AND l.test_value < 350 THEN 1 ELSE 0 END) AS high_risk_count,
        SUM(CASE WHEN l.test_value >= 350 AND l.test_value < 500 THEN 1 ELSE 0 END) AS moderate_risk_count,
        SUM(CASE WHEN l.test_value >= 500 THEN 1 ELSE 0 END) AS low_risk_count,
        AVG(l.test_value) AS avg_cd4
    FROM visits v
    JOIN lab_results l ON v.visit_id = l.visit_id
    WHERE l.test_type = 'CD4 Count'
    GROUP BY v.clinic_location
)
SELECT 
    clinic_location,
    total_patients,
    critical_count,
    high_risk_count,
    moderate_risk_count,
    low_risk_count,
    avg_cd4,
    ROUND((critical_count + high_risk_count) * 100.0 / NULLIF(total_patients, 0), 1) AS pct_high_risk,
    CASE 
        WHEN (critical_count + high_risk_count) * 100.0 / NULLIF(total_patients, 0) > 50 THEN 'Critical - Resource Allocation Needed'
        WHEN (critical_count + high_risk_count) * 100.0 / NULLIF(total_patients, 0) > 30 THEN 'At Risk - Enhanced Monitoring'
        ELSE 'Stable'
    END AS clinic_status
FROM clinic_risk_summary
ORDER BY pct_high_risk DESC;

-- ============================================================================
-- SECTION 6: ADVANCED ANALYTICS (Preparing for OLAP Dashboard)
-- Purpose: Build queries ready for Superset visualization
-- PDF Concept: "Data warehouses: Optimized for analytics - OLAP"
-- Future: These queries can be saved as Views for BI tools
-- ============================================================================

-- Query 6.1: Regional summary for dashboard KPIs
-- Business Question: What are the key metrics per country? (Dashboard Header)
SELECT 
    p.country,
    COUNT(DISTINCT p.patient_id) AS total_patients,
    COUNT(DISTINCT v.visit_id) AS total_visits,
    COUNT(DISTINCT l.result_id) AS total_tests,
    ROUND(AVG(CASE WHEN l.test_type = 'CD4 Count' THEN l.test_value END), 1) AS avg_cd4,
    MIN(CASE WHEN l.test_type = 'CD4 Count' THEN l.test_value END) AS min_cd4,
    MAX(CASE WHEN l.test_type = 'CD4 Count' THEN l.test_value END) AS max_cd4
FROM patients p
LEFT JOIN visits v ON p.patient_id = v.patient_id
LEFT JOIN lab_results l ON v.visit_id = l.visit_id
GROUP BY p.country
ORDER BY total_patients DESC;

-- Query 6.2: Time-series data for trend analysis
-- Business Question: How do CD4 counts trend over time? (Line Chart)
SELECT 
    DATE_FORMAT(l.test_date, '%Y-%m') AS test_month,
    v.clinic_location,
    COUNT(*) AS test_count,
    ROUND(AVG(l.test_value), 1) AS avg_cd4,
    ROUND(MIN(l.test_value), 1) AS min_cd4,
    ROUND(MAX(l.test_value), 1) AS max_cd4
FROM lab_results l
JOIN visits v ON l.visit_id = v.visit_id
WHERE l.test_type = 'CD4 Count'
GROUP BY DATE_FORMAT(l.test_date, '%Y-%m'), v.clinic_location
ORDER BY test_month, v.clinic_location;

-- ============================================================================
-- SECTION 7: DATA QUALITY CHECKS
-- Purpose: Ensure data integrity before analysis
-- PDF Concept: "When inserting data in relational databases, schemas must be respected"
-- Engineering Best Practice: Always validate data quality
-- ============================================================================

-- Query 7.1: Check for orphaned records (data integrity)
-- Business Question: Are there any visits without patients?
SELECT 
    'Orphaned Visits' AS check_type,
    COUNT(*) AS issue_count
FROM visits v
LEFT JOIN patients p ON v.patient_id = p.patient_id
WHERE p.patient_id IS NULL

UNION ALL

SELECT 
    'Orphaned Lab Results' AS check_type,
    COUNT(*) AS issue_count
FROM lab_results l
LEFT JOIN visits v ON l.visit_id = v.visit_id
WHERE v.visit_id IS NULL;

-- Query 7.2: Check for missing or null values
-- Business Question: Are there any critical fields with missing data?
SELECT 
    'Patients without DOB' AS check_type,
    COUNT(*) AS issue_count
FROM patients
WHERE date_of_birth IS NULL

UNION ALL

SELECT 
    'Lab Results without Value' AS check_type,
    COUNT(*) AS issue_count
FROM lab_results
WHERE test_value IS NULL OR test_value = '';

-- ============================================================================
-- END OF ANALYSIS QUERIES
-- Next Steps: 
-- 1. Save frequently used queries as Views for BI tools (Superset)
-- 2. Consider Dimensional Modeling (Star Schema) for faster OLAP queries
-- 3. Build Apache Superset dashboard using these query patterns
-- ============================================================================