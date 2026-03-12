-- 1. Create the Database (The Container)
CREATE DATABASE IF NOT EXISTS health_clinic;
USE health_clinic;

-- 2. Create Table: patients (Stores demographic info)
CREATE TABLE patients (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    date_of_birth DATE,
    gender VARCHAR(10),
    country VARCHAR(50),
    registration_date DATE DEFAULT null 
);

-- 3. Create Table: visits (Stores transactional info - OLTP style)
CREATE TABLE visits (
    visit_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT,
    visit_date DATE,
    clinic_location VARCHAR(100),
    doctor_name VARCHAR(100),
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
);

-- 4. Create Table: lab_results (Stores measurements linked to visits)
CREATE TABLE lab_results (
    result_id INT AUTO_INCREMENT PRIMARY KEY,
    visit_id INT,
    test_type VARCHAR(50),
    test_value VARCHAR(50),
    test_date DATE,
    FOREIGN KEY (visit_id) REFERENCES visits(visit_id)
);

show tables;


USE health_clinic;