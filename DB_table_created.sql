-- =====================
-- CREATE SCHEMA
-- =====================
CREATE SCHEMA IF NOT EXISTS hospital;

-- =====================
-- DIMENSION TABLES
-- =====================
CREATE TABLE IF NOT EXISTS hospital.branch (
    branch_id VARCHAR(10) PRIMARY KEY,
    branch_name VARCHAR(50),
    total_beds INT,
    icu_beds INT
);

CREATE TABLE IF NOT EXISTS hospital.department (
    department_id VARCHAR(10) PRIMARY KEY,
    department_name VARCHAR(40),
    branch_id VARCHAR(10),
    CONSTRAINT fk_dept_branch
        FOREIGN KEY (branch_id) REFERENCES hospital.branch(branch_id)
);

CREATE TABLE IF NOT EXISTS hospital.patient (
    patient_id VARCHAR(15) PRIMARY KEY,
    age INT,
    gender VARCHAR(10),
    insurance_type VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS hospital.doctor (
    doctor_id VARCHAR(15) PRIMARY KEY,
    department_id VARCHAR(10),
    max_daily_hours INT,
    CONSTRAINT fk_doctor_dept
        FOREIGN KEY (department_id) REFERENCES hospital.department(department_id)
);

-- =====================
-- FACT TABLES
-- =====================
CREATE TABLE IF NOT EXISTS hospital.admission (
    admission_id VARCHAR(20) PRIMARY KEY,
    patient_id VARCHAR(15),
    department_id VARCHAR(10),
    branch_id VARCHAR(10),
    admission_time TIMESTAMP,
    discharge_time TIMESTAMP,
    admission_type VARCHAR(15),
    bed_type VARCHAR(10),
    CONSTRAINT fk_adm_patient 
        FOREIGN KEY (patient_id) REFERENCES hospital.patient(patient_id),
    CONSTRAINT fk_adm_dept 
        FOREIGN KEY (department_id) REFERENCES hospital.department(department_id),
    CONSTRAINT fk_adm_branch 
        FOREIGN KEY (branch_id) REFERENCES hospital.branch(branch_id)
);

CREATE TABLE IF NOT EXISTS hospital.procedure (
    procedure_id VARCHAR(20) PRIMARY KEY,
    admission_id VARCHAR(20),
    procedure_type VARCHAR(30),
    procedure_time TIMESTAMP,
    emergency_flag BOOLEAN,
    CONSTRAINT fk_proc_adm 
        FOREIGN KEY (admission_id) REFERENCES hospital.admission(admission_id)
);

CREATE TABLE IF NOT EXISTS hospital.billing (
    admission_id VARCHAR(20) PRIMARY KEY,
    total_cost DECIMAL(10,2),
    insurance_covered DECIMAL(10,2),
    CONSTRAINT fk_bill_adm 
        FOREIGN KEY (admission_id) REFERENCES hospital.admission(admission_id)
);

CREATE TABLE IF NOT EXISTS hospital.outcome (
    admission_id VARCHAR(20) PRIMARY KEY,
    outcome_status VARCHAR(20),
    readmitted_30d BOOLEAN,
    CONSTRAINT fk_out_adm 
        FOREIGN KEY (admission_id) REFERENCES hospital.admission(admission_id)
);

CREATE TABLE IF NOT EXISTS hospital.doctor_workload (
    doctor_id VARCHAR(15),
    work_date DATE,
    hours_booked DECIMAL(4,2),
    CONSTRAINT fk_work_doc 
        FOREIGN KEY (doctor_id) REFERENCES hospital.doctor(doctor_id)
);

CREATE TABLE IF NOT EXISTS hospital.bed_occupancy (
    snapshot_time TIMESTAMP,
    department_id VARCHAR(10),
    branch_id VARCHAR(10),
    occupied_beds INT,
    CONSTRAINT fk_bed_dept 
        FOREIGN KEY (department_id) REFERENCES hospital.department(department_id),
    CONSTRAINT fk_bed_branch 
        FOREIGN KEY (branch_id) REFERENCES hospital.branch(branch_id)
);

-- =====================
-- DATA IMPORT
-- =====================

