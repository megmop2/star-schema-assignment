# Assignment 1: Star schema
use mmr143;

-- =====================================================
-- Part 1: Create Star Schema Tables
-- =====================================================

-- Create patient dimension table with demographic info
CREATE TABLE dim_patient (
	patient_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    gender VARCHAR(10),
    date_of_birth DATE
);

-- Create provider dimension table with specialty
CREATE TABLE dim_provider (
	provider_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    specialty VARCHAR(50)
);

-- Create procedure dimension table with ICD-10 codes
CREATE TABLE dim_procedure (
	procedure_id INT PRIMARY KEY,
    icd10_code VARCHAR(50),
    proc_name VARCHAR(100),
    proc_description VARCHAR(255)
);

-- Create lab dimension table with CPT codes
CREATE TABLE dim_lab (
	lab_id INT PRIMARY KEY,
    cpt_code VARCHAR(45),
    lab_name VARCHAR(255)
);

-- Create diagnosis dimension table with ICD-10 codes
CREATE TABLE dim_diagnosis (
	diagnosis_id INT PRIMARY KEY,
    diagnosis_name VARCHAR(250),
    icd10_code VARCHAR(45)
);


select visit_date from visit; # wanted to see the format date was in

-- Create time dimension table
CREATE TABLE dim_time (
    time_id INT PRIMARY KEY,
    date DATE
);

-- Create fact_visits table to record each clinical visit and measures
-- Includes foreign keys to all dimension tables and visit-based measures
CREATE TABLE fact_visits (
	visit_id INT PRIMARY KEY,
	patient_id INT,
    provider_id INT,
    procedure_id INT,
    lab_id INT,
    diagnosis_id INT,
    time_id INT,
    procedure_count INT,
    lab_test_count INT,
    diagnosis_count INT,
    visit_count INT,
    
	FOREIGN KEY (patient_id) REFERENCES dim_patient(patient_id),
    FOREIGN KEY (provider_id) REFERENCES dim_provider(provider_id),
    FOREIGN KEY (procedure_id) REFERENCES dim_procedure(procedure_id),
    FOREIGN KEY (lab_id) REFERENCES dim_lab(lab_id),
    FOREIGN KEY (diagnosis_id) REFERENCES dim_diagnosis(diagnosis_id),
    FOREIGN KEY (time_id) REFERENCES dim_time(time_id)
);

-- =====================================================
-- Part 2: ETL Script Development
-- =====================================================

-- Load patient dimension data from emr.patient into dim_patient
INSERT INTO dim_patient (
	patient_id,
    first_name,
    last_name,
    gender,
    date_of_birth)
SELECT
	patient_id,
    first_name,
    last_name,
    gender,
    dob
FROM emr.patient;

select * from dim_patient;

-- Load provider dimension data from emr.provider into dim_provider
INSERT INTO dim_provider (
	provider_id,
    first_name,
    last_name,
    specialty)
SELECT 
	provider_id,
    first_name,
    last_name,
    specialty
FROM emr.provider;

select * from dim_provider;

-- Load procedure dimension data from emr.procedure into dim_procedure
INSERT INTO dim_procedure (
	procedure_id,
    icd10_code,
    proc_name,
    proc_description)
SELECT
	procedure_id,
	icd10_code,
    proc_name,
    description
FROM emr.clinical_procedures;

-- Load lab dimension data from emr.lab into dim_lab
INSERT INTO dim_lab (
	lab_id,
    cpt_code,
    lab_name)
SELECT 
	lab_id,
    cpt_code,
    lab_name
FROM emr.lab;

select * from dim_lab;

-- Load diagnosis data from emr.diagnosis into dim_diagnosis
INSERT INTO dim_diagnosis (
	diagnosis_id,
    diagnosis_name,
    icd10_code)
SELECT 
	diagnosis_id,
    name,
    icd10_code
FROM emr.diagnosis;

select * from dim_diagnosis;

-- Generate time dimension from distinct visit_date in emr.visit
-- Only insert rows where visit_date is not null
INSERT INTO dim_time (
	time_id, 
    date)
SELECT DISTINCT
	DATE_FORMAT (visit_date, '%Y%m%d') + 0 AS time_id,
    visit_date
FROM emr.visit
WHERE visit_date IS NOT NULL;

select * from dim_time;


-- =====================================================
-- Part 3: Data Integrity Checks
-- Validate the accuracy and consistency of migrated data
-- =====================================================

-- 1. Row count comparison: EMR patient vs. dim_patient
-- Ensures that the number of patients loaded matches the source
SELECT
	(SELECT COUNT(*) FROM emr.patient) AS emr_patient_count,
    (SELECT COUNT(*) FROM dim_patient) AS dim_patient_count;

-- 2. Check for NULLs in surrogate keys in dim_time
-- Ensures that the primary key (time_id) is populated for all rows
SELECT *
FROM dim_time
WHERE time_id IS NULL;

-- 3. Check for NULLs in foreign key fields in fact_visits
-- Ensures all visits are linked to valid dimension records
SELECT *
FROM fact_visits
WHERE patient_id IS NULL
	OR provider_id IS NULL
    OR procedure_id IS NULL
    OR lab_id IS NULL
    OR diagnosis_id IS NULL
    OR time_id IS NULL;

-- 4. Validate that every time_id in fact_visits exists in dim_time
-- Ensures date-based keys in the fact table link correctly to the time dimension
SELECT fv.time_id
FROM fact_visits fv
LEFT JOIN dim_time dt ON
	fv.time_id = dt.time_id
WHERE dt.time_id IS NULL;
# empty result = every time_id in fact_visits exists in dim_time

-- 5. Confirm consistent date mappings by comparing visit_date and dim_time.date
-- Ensures that date conversions were correct during ETL
SELECT DISTINCT visit_date
FROM emr.visit
WHERE visit_date NOT IN (SELECT date from dim_time);
# empty result = every visit_date in emr.visit is in dim_time!
