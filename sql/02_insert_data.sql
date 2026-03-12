USE health_clinic;

-- 1. Insert Patients (Demographics)
INSERT INTO patients (first_name, last_name, date_of_birth, gender, country, registration_date) VALUES
('Abebe', 'Lema', '1995-04-12', 'Male', 'Ethiopia', '2024-02-10'),
('Dechasa', 'Lemesa', '1989-04-12', 'Male', 'Ethiopia', '2025-01-10'),
('John', 'Doe', '1985-04-12', 'Male', 'Kenya', '2023-01-10'),
('Sarah', 'Smith', '1990-07-23', 'Female', 'Uganda', '2023-02-15'),
('Michael', 'Omondi', '1978-11-05', 'Male', 'Kenya', '2023-01-20'),
('Grace', 'Kamara', '1995-03-30', 'Female', 'Tanzania', '2023-03-01'),
('David', 'Nkosi', '1982-09-18', 'Male', 'Uganda', '2023-02-28');

-- 2. Insert Visits (Transactions linked to Patients)
-- Note: patient_id 1, 2, 3, 4, 5 correspond to the patients above
INSERT INTO visits (patient_id, visit_date, clinic_location, doctor_name) VALUES
(1, '2024-06-10', 'Fewis Clinic', 'Dr. Baba. Deresa'),
(1, '2025-06-10', 'Fewis Clinic', 'Dr. Baba. Deresa'),
(1, '2023-06-10', 'Nairobi Central Clinic', 'Dr. A. Patel'),
(1, '2023-09-15', 'Nairobi Central Clinic', 'Dr. A. Patel'),
(2, '2023-05-20', 'Kampala Health Center', 'Dr. B. Okello'),
(3, '2023-07-05', 'Nairobi Central Clinic', 'Dr. C. Wanjiru'),
(4, '2023-08-12', 'Dar es Salaam Clinic', 'Dr. D. Moyo'),
(5, '2023-06-30', 'Kampala Health Center', 'Dr. B. Okello');

-- 3. Insert Lab Results (Measurements linked to Visits)
-- Note: visit_id 1, 2, 3... correspond to the visits above
INSERT INTO lab_results (visit_id, test_type, test_value, test_date) VALUES
(1, 'CD4 Count', '250', '2025-06-10'),
(1, 'CD4 Count', '550', '2024-06-10'),
(1, 'CD4 Count', '450', '2023-06-10'),
(1, 'Viral Load', '12000', '2023-06-10'),
(2, 'CD4 Count', '520', '2023-09-15'),
(2, 'Viral Load', '<20', '2023-09-15'),
(3, 'CD4 Count', '310', '2023-05-20'),
(3, 'Viral Load', '5000', '2023-05-20'),
(4, 'CD4 Count', '280', '2023-07-05'),
(5, 'CD4 Count', '600', '2023-08-12'),
(5, 'Viral Load', '<20', '2023-08-12'),
(6, 'CD4 Count', '350', '2023-06-30');