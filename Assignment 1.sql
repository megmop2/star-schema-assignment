# Assignment 1: Star schema
use mmr143;

## Part 1
# create fact and dimension tables

# patient dimension
CREATE TABLE dim_patient (
	patient_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    gender VARCHAR(10),
    date_of_birth DATE
);

# provider dimension
CREATE TABLE dim_provider (
	provider_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    specialty VARCHAR(50)
);

# procedure dimension
CREATE TABLE dim_procedure (
	procedure_id INT PRIMARY KEY,
    icd10_code VARCHAR(50),
    proc_name VARCHAR(100),
    proc_description VARCHAR(255)
);

# lab dimension
CREATE TABLE dim_lab (
	lab_id INT PRIMARY KEY,
    cpt_code VARCHAR(45),
    lab_name VARCHAR(255)
);

# diagnosis dimension
CREATE TABLE dim_diagnosis (
	diagnosis_id INT PRIMARY KEY,
    diagnosis_name VARCHAR(250),
    icd10_code VARCHAR(45)
);


select visit_date from visit;

# time dimension
CREATE TABLE dim_time (
	time_id INT PRIMARY KEY,
    date DATE,
    year INT,
    month INT,
    day INT
);

# create fact table
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


