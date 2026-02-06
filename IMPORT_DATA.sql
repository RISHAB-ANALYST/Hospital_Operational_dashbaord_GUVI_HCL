


copy hospital.branch FROM 'C:\Users\RISHAB\Desktop\Hospital_Operational_dashboard_project\hospital_data\branch.csv' DELIMITER ',' CSV HEADER;

\copy hospital.department FROM 'C:\Users\RISHAB\Desktop\Hospital_Operational_dashboard_project\hospital_data\department.csv' DELIMITER ',' CSV HEADER;

\copy hospital.patient FROM 'C:\Users\RISHAB\Desktop\Hospital_Operational_dashboard_project\hospital_data\patient.csv' DELIMITER ',' CSV HEADER;

\copy hospital.doctor FROM 'C:\Users\RISHAB\Desktop\Hospital_Operational_dashboard_project\hospital_data\doctor.csv' DELIMITER ',' CSV HEADER;

\copy hospital.admission FROM 'C:\Users\RISHAB\Desktop\Hospital_Operational_dashboard_project\hospital_data\admission.csv' DELIMITER ',' CSV HEADER;

\copy hospital.procedure FROM 'C:\Users\RISHAB\Desktop\Hospital_Operational_dashboard_project\hospital_data\procedure.csv' DELIMITER ',' CSV HEADER;

\copy hospital.billing FROM 'C:\Users\RISHAB\Desktop\Hospital_Operational_dashboard_project\hospital_data\billing.csv' DELIMITER ',' CSV HEADER;

\copy hospital.outcome FROM 'C:\Users\RISHAB\Desktop\Hospital_Operational_dashboard_project\hospital_data\outcome.csv' DELIMITER ',' CSV HEADER;

\copy hospital.doctor_workload FROM 'C:\Users\RISHAB\Desktop\Hospital_Operational_dashboard_project\hospital_data\doctor_workload.csv' DELIMITER ',' CSV HEADER;

\copy hospital.bed_occupancy FROM 'C:\Users\RISHAB\Desktop\Hospital_Operational_dashboard_project\hospital_data\bed_occupancy.csv' DELIMITER ',' CSV HEADER;