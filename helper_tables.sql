/*
===============================================================================
Script:         helper_tables.sql
Project:        SQL Uber Rides Analytics Project (MySQL)
Author:         Sai Prithvi Sudhakar
Database:       uberridesanalyticsdatabase

Description:
    - To add new helper tables to create better targeted insights relevant to the business needs.
    
Objectives:
    1. To create a new vehicles table that categorizes the vehicle into a type, their median price and what uber category they fall under.
    2. To create a new holidays table that can help with day based analysis and discover business trends in relation with holidays.
===============================================================================
*/

USE uberridesanalyticsdatabase;

-- ============================================================================
#1: To create a new vehicles table that categorizes the vehicle into a type, their median price and what uber category they fall under.
-- ============================================================================


#Step 1: To create a temporory view that includes the vehicle make, model and year, extracted from the drivers table.

DROP VIEW IF EXISTS tmp;
CREATE VIEW tmp AS(
SELECT DISTINCT vehicle_make, vehicle_model,vehicle_year FROM drivers ORDER BY vehicle_make);

DROP TABLE IF EXISTS holidays;
CREATE TABLE holidays (
holiday_id INT PRIMARY KEY,
holiday_name VARCHAR(80) NOT NULL,
holiday_date date NOT NULL
);
/*
Step 2: Export the view using the table data export wizard to create a new csv file.
Step 3: Add new columns vehicle_type, vehicle_cost and uber_category to the csv file and fill in the required values 
from the uber source website: https://www.uber.com/us/en/eligible-vehicles/?city=new-york.
Step 4: Import the resulting csv file to the database using table data import wizard.
*/

SELECT * FROM uberridesanalyticsdatabase.vehicles;

-- ============================================================================
#2: To create a new holidays table that can help with day based analysis and discover business trends in relation with holidays.
#from the sources: https://www.nycourts.gov/about-us/terms-court-calendar-holidays, https://houstontx.gov/hr/holidays.html, 
#https://www.commerce.gov/hr/employees/leave/holidays, https://www.timeanddate.com/holidays/us/2024
-- ============================================================================
DROP TABLE IF EXISTS holidays;
CREATE TABLE holidays( holiday_id INT PRIMARY KEY NOT NULL, holiday_name varchar(80) NOT NULL, location varchar(60) NOT NULL DEFAULT "New York", `2022` date, `2023` date, `2024` date);
INSERT INTO holidays VALUES (1, 'New Year''s Day', 'All', '2022-01-03', '2023-01-02', '2024-01-01');
INSERT INTO holidays VALUES (2, 'Martin Luther King Jr. Day', 'All', '2022-01-17', '2023-01-16', '2024-01-15');
INSERT INTO holidays VALUES (3, 'Lincoln''s Birthday', 'New York,Chicago', '2022-02-11', '2023-02-13', '2024-02-12');
INSERT INTO holidays VALUES (4, 'Confederate Heroes Day', 'Houston', '2022-01-19', '2023-01-19', '2024-01-19');
INSERT INTO holidays VALUES (5, 'Washington''s Birthday / Presidents'' Day', 'All', '2022-02-21', '2023-02-20', '2024-02-19');
INSERT INTO holidays VALUES (6, 'Texas Independence Day', 'Houston', '2022-03-02', '2023-03-02', '2024-03-02');
INSERT INTO holidays VALUES (7, 'San Jacinto Day', 'Houston', '2022-04-21', '2023-04-21', '2024-04-21');
INSERT INTO holidays VALUES (8, 'Memorial Day', 'All', '2022-05-30', '2023-05-29', '2024-05-27');
INSERT INTO holidays VALUES (9, 'Juneteenth', 'All', '2022-06-20', '2023-06-19', '2024-06-19');
INSERT INTO holidays VALUES (10, 'Independence Day', 'All', '2022-07-04', '2023-07-04', '2024-07-04');
INSERT INTO holidays VALUES (11, 'Lyndon B. Johnson Day', 'Houston', '2022-08-27', '2023-08-28', '2024-08-27');
INSERT INTO holidays VALUES (12, 'Labor Day', 'All', '2022-09-05', '2023-09-04', '2024-09-02');
INSERT INTO holidays VALUES (13, 'Columbus Day / Indigenous Peoples'' Day', 'New York,Chicago', '2022-10-10', '2023-10-09', '2024-10-14');
INSERT INTO holidays VALUES (14, 'Nevada Day', 'Las Vegas', '2022-10-28', '2023-10-27', '2024-10-25');
INSERT INTO holidays VALUES (15, 'Election Day', 'New York,Chicago', '2022-11-08', NULL, '2024-11-05');
INSERT INTO holidays VALUES (16, 'Veterans Day', 'All', '2022-11-11', '2023-11-10', '2024-11-11');
INSERT INTO holidays VALUES (17, 'Thanksgiving Day', 'All', '2022-11-24', '2023-11-23', '2024-11-28');
INSERT INTO holidays VALUES (18, 'Day after Thanksgiving / Family Day', 'Houston,Las Vegas,Chicago', '2022-11-25', '2023-11-24', '2024-11-29');
INSERT INTO holidays VALUES (19, 'Christmas Day', 'All', '2022-12-26', '2023-12-25', '2024-12-25');
INSERT INTO holidays VALUES (20, 'Day after Christmas', 'Houston', '2022-12-26', '2023-12-26', '2024-12-26');

Select * from uberridesanalyticsdatabase.holidays;

