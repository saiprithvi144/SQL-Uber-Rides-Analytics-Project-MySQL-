# SQL-Uber-Rides-Analytics-Project-MySQL-

# SQL Data Analytics Project using MySQL

![MySQL](https://img.shields.io/badge/MySQL-8.0-blue)
![SQL](https://img.shields.io/badge/SQL-Analytics-green)
![Data Analytics](https://img.shields.io/badge/Data-Analytics-orange)

## Overview

This project showcases a complete exploratory data analysis (EDA) on the Uber Rides Analytics SQL Database using **MySQL 8.0 Workbench**. It focuses on exploring the business data, analyzing rider and driver performance, identifying trends over time, and generating business reports using advanced SQL techniques.

The project follows a structured analytics workflow—from understanding the business and database exploration to building reusable reporting views—and showcases how SQL can be used to answer real-world business questions and support data-driven decision-making via the insights gathered.

---

# Project Objectives

The main objectives of this project are to:

* Explore and understand the business and the given database.
* Perform Exploratory Data Analysis (EDA) and data validation.
* Identify the timeline and understand the date & time related data.
* Measure key business KPIs.
* Analyze the magnitude of dimensions across various business measures.
* Perform ranking analysis of key business factors.
* Identify business trends over time.
* Analyze performance of drivers against historical data and perform time based analysis.
* Perform geological,rider and driver segmentation.
* Add helper tables to supplement missing data.
* Generate reusable analytical reports.
* Compile the insights discovered relevant to stakeholders.

---

# Technologies Used

* **Database:** MySQL 8.0
* **Language:** SQL
* **IDE:** MySQL Workbench
* **Version Control:** Git & GitHub

---

# Project Structure

```text
SQL-Data-Analytics-Project-MySQL/
│
├
│
├── scripts/
│   ├── 1_database_exploration.sql
│   ├── 2_dimensions_exploration.sql
│   ├── 3_date_range_exploration.sql
│   ├── 4_measures_exploration.sql
│   ├── 5_magnitude_exploration.sql
│   ├── 6_ranking_analysis.sql
│   ├── 7_change_over_time_analysis.sql
│   ├── 8_performance_analysis.sql
│   ├── 9_data_segmentation_analysis.sql
│   ├── 10_report_yrmon.sql
│   ├── 11_report_customer.sql
│   └── 12_report_driver.sql
│   └── 12_report_driver.sql
│   └── 13_report_location.sql
│   └── 14_conclusion.sql
│
│
└── helper_tables.sql
└── README.md
```

---

# Schema Map

<img width="874" height="802" alt="Schema_Map" src="https://github.com/user-attachments/assets/b8bb428f-dbb4-4b29-b11c-4091cb6ab5fe" />


# Project Workflow

## Database Initialization

* Create the schema
* Execute the schema SQL file
* Import datasets

---

## Database Exploration

* Explore database structure
* Preview datasets
* Understand the grain of each table
* Perform data quality checks

---

## Dataset Understand And Exploration

Analyze:

* Rider demographics
* Location information
* Driver demographics
* User data
* Trips and payments information
* Identify unique parameters for relevant data
* Explore the distribution of parameters in a table
* Perform basic data validation checks
  
---

## Date Range Analysis

Analyze:

* Understand date and time related information
* Identify the trips timeline
* Yearly & Monthly trends
* Date related data validation checks
* Analyze and derive basic date relevant insights for bookings and cancellations

---

## Measures Exploration

Calculate:

* Calculate overall revenue KPI
* Analyze rider behaviour
* Measure geological data
* Calculate averages and totals for business metrics
* Build foundational business metrics

---

## Magnitude Analysis

Compare business performance across:

* Analyze total revenue, riders & drivers per city
* Analyze driver performance
* Identify primary reasons for cancellations
* Analyze distribution of trips and revenue for each uber category
* Identify peak times for each zone according to the day of the week
* Analyze surge multiplier to check if it is higher during holidays

---

## Ranking Analysis

* Identify low performing drivers
* Rank riders by revenue generated
* Identify lowest ranking zones, cities and zone types
* Rank zones with the lowest driver count
* Rank the drivers with the highest car breakdowns or vehicle issues

---

## Change Over Time Analysis

* Analyze Yearly & Monthly trends
* Track monthly growth percentage and running total
* Anaylze quarterly trends
* Analyze quarterly revenue performance each year
* Track the rolling total between each quarter per year
* Track Cumulative revenue percentage

---

## Performance Analysis

* Evaluate driver performance against the average for that city
* Identify the best driver for the month (yrmon)
* Identify drivers with above overall average rating
* Identify the hour for each of day of the week with the most bookings
* Identify the best day of the week and time of day for bookings in each location

---

## Data Segmentation

Segment riders,drivers and locations based on business metrics to support targeted analysis.


---

## Year Month Analytics Report

Create a reusable year month report including:

* Total trips per month
* Total revenue per month
* Month over Month change
* Cumulative revenue percentage
* Best performing driver and the city each month with their details

---


---

## Customer Analytics Report

Create a reusable customer report including:

* Customer Profile
* Customer trips
* Customer Lifetime
* Customer average distance covered and total revenue for Uber
* Customer total review count, average review rating given and received.
* Customer segment based on rider tag
  
---

## Driver Analytics Report

Create a reusable driver report including:

* Driver Profile
* Driver category and trips
* Driver Lifetime
* Driver average distance covered and total revenue for Uber
* Driver total review count, average review rating given and received.
* Driver segment based on driver tag

---

---

## Location Analytics Report

Create a reusable location report including:

* Location details
* Best day of the week and time of day for bookings in that location
* Bookings for that day of week and time, Bookings for that day, Total bookings, for each location
* Unique drivers and riders in each location
* Average distance covered from that pickup point and average surge multiplier for each location
* Revenue generated by each location for Uber

---

# SQL Concepts Demonstrated

### Joins

* INNER JOIN
* LEFT JOIN
* ANTI-JOIN

### Aggregate Functions

* SUM()
* COUNT()
* AVG()
* MIN()
* MAX()

### Window Functions

* RANK()
* DENSE_RANK()
* ROW_NUMBER()
* LAG()
* SUM() OVER()
* AVG() OVER()
* COUNT() OVER()

### Date Functions

* YEAR()
* MONTH()
* MONTHNAME()
* DATE_FORMAT()
* TIMESTAMPDIFF()

### Advanced SQL

* Common Table Expressions (CTEs)
* Subqueries
* Derived tables
* Views
* CASE Expressions
* Running Totals
* Rolling Totals
* Cumulative Totals
* Ranking
* Customer Segmentation
* Driver Segmentation
* Time-Series Analysis

---

# Skills Demonstrated

* SQL Programming
* MySQL
* Data Cleaning
* Data Exploration
* Data Validation
* Exploratory Data Analysis (EDA)
* Data Aggregation
* Business Intelligence
* Window Functions
* Time-Series Analysis
* Customer Analytics
* Geological Analytics
* Reporting
* DDL concepts

---

# Sample Output

Yrmon Report
<img width="1348" height="229" alt="Yrmon_report" src="https://github.com/user-attachments/assets/258dfaf3-db94-4cab-a49b-0a317abf05d8" />

Customer Report
<img width="1348" height="222" alt="report_customer" src="https://github.com/user-attachments/assets/1f4d4746-5c2e-4c17-8497-e338654f4de4" />

Driver Report
<img width="1357" height="220" alt="report_driver" src="https://github.com/user-attachments/assets/1139dba8-51c2-4b27-83cd-a4f1d613f2ec" />

Location Report
<img width="1244" height="235" alt="report_location" src="https://github.com/user-attachments/assets/456c225b-4fd7-4f8a-89e2-bef01c96b633" />




# Conclusion



## The primary concerns from this analysis would be to look into:


-why the reviews have a mismatch in rating.

-understand the discrepancy between user account creation dates in the users table and date joined in their respective base tables 

-Investigated why trips have duration still mentioned in the column despite not having a completion time or status not set as completed. 
This is because the trip distance and completion time are the estimated figures by the app itself that are being established into the database 
rather than the actual accurate values themselves.

-The trips still marked “in_progress” also need to be looked into. 

## The final takeaways from this analysis should be:


-The cumulative revenue streamline is consistent with no major losses or profits despite having high month over month change percentages in some cases. 

-The drivers need to be informed to avoid accepting trip requests that are too far away to reduce potential cancellations due to long wait times. (10 min+)

-All the payments that “failed” need to be thoroughly investigated. 
Whether this was a database entry issue or if there really were 325 payments that did not take place. 
(Probably a customer could not pay and gave another form of collateral,  or maybe a malicious transaction took place where the driver took the money for themselves.)

-An investigation needs to be done on why the "wrong pickup" and "system error" count is so high.
(Perhaps an OTP system needs to be updated or location tracking needs to be improved.)

-Both Drivers and Riders need to get more incentives to conduct/book trips in LA.
With the total trip count in LA being the lowest and total unique driver count in LA also being low (Between 76 to 78 per zone in LA), 
It has much more potential to generate more revenue with the average base fare and the average distance covered for the city being the highest.

 -Overall bookings peak at 8AM-11AM,2PM-3PM and 6PM-2AM. These are the peak hours that should be prioritized especially the morning and evening-night hours with more driver availability.

-Similarly, It is better to have more drivers working during Wednesdays, Fridays and Tuesdays as the highest number of trips have taken place during these time periods.

-The average distance and base fare for each city plays a vital role in the total revenue generated more than the total trips conducted there
 (Example: Houston generating more revenue due to almost double the average distance covered to New York even though New York has more demand for trips). 


##Future business decisions should be taken keeping these in mind. 

#Acknowledgements

Uber Rides Analytics Database by: Arjun-times 
https://www.kaggle.com/datasets/arjuntimes/uber-sql-database

