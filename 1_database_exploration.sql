/*
===============================================================================
Script:         1_database_exploration.sql
Project:        SQL Uber Rides Analytics Project (MySQL)
Author:         Sai Prithvi Sudhakar
Database:       uberridesanalyticsdatabase
Description:
    This script explores the overall database structure and provides
    an initial understanding of the available tables and data.

Objectives:
    1. View all available tables.
    2. Count the number of records in each table.
    3. Preview sample records.
    4. Inspect table structures.
    5. Perform basic data quality checks.

===============================================================================
*/

USE uberridesanalyticsdatabase;

-- ===============================================================================
#1. Display list of tables
-- ===============================================================================

show tables;

-- ===============================================================================
#2. Count total records
-- ===============================================================================

SELECT count(*) AS total_cancellations FROM cancellations;

SELECT count(*) AS total_drivers FROM drivers;

SELECT count(*) AS total_locations FROM locations;

SELECT count(*) AS total_payments_count FROM payments;

SELECT count(*) AS total_reviews FROM reviews;

SELECT count(*) AS total_riders FROM uberridesanalyticsdatabase.riders;

SELECT count(*) AS total_trips FROM uberridesanalyticsdatabase.trips;

SELECT count(*) AS total_users FROM uberridesanalyticsdatabase.users;

-- ===============================================================================
#3. Preview table data
-- ===============================================================================

SELECT * FROM cancellations
LIMIT 10;

SELECT * FROM drivers
limit 10;

select * from locations
limit 10;

select * from payments
limit 10;

select * from reviews
limit 10;

select * from riders
limit 10;

select * from trips
limit 10;

select * from users
limit 10;

-- ===============================================================================
#4. Display table structures
-- ===============================================================================

DESCRIBE cancellations;

DESCRIBE drivers;

DESCRIBE locations;

DESCRIBE payments;

DESCRIBE reviews;

DESCRIBE riders;

DESCRIBE trips;

DESCRIBE users;

-- ============================================================================
#5. NULL value checks
-- ============================================================================

#Cancellations table

SELECT
    SUM(cancel_id IS NULL) AS cancel_id_nulls,
    SUM(trip_id IS NULL) AS trip_id_nulls,
    SUM(cancelled_by IS NULL) AS cancelled_by_nulls,
    SUM(reason IS NULL) AS reason_nulls,
    SUM(cancelled_at IS NULL) AS cancelled_at_nulls
FROM cancellations;

#Drivers table

SELECT
    SUM(driver_id IS NULL) AS driver_id_nulls,
    SUM(user_id IS NULL) AS user_id_nulls,
    SUM(vehicle_make IS NULL) AS vehicle_make_nulls,
    SUM(vehicle_model IS NULL) AS vehicle_model_nulls,
    SUM(vehicle_year IS NULL) AS vehicle_year_nulls,
	SUM(license_plate IS NULL) AS license_plate_nulls,
    SUM(rating IS NULL) AS rating_nulls,
    SUM(join_date IS NULL) AS join_date_nulls,
    SUM(is_active IS NULL) AS is_active_nulls
from drivers;

#Locations table

SELECT
    SUM(location_id IS NULL) AS location_id_nulls,
    SUM(zone_name IS NULL) AS zone_name_nulls,
    SUM(city IS NULL) AS city_nulls,
    SUM(latitude IS NULL) AS latitude_nulls,
    SUM(longitude IS NULL) AS longitude_nulls,
	SUM(zone_type IS NULL) AS zone_type_nulls
from locations;

#Payments table

SELECT
    SUM(payment_id IS NULL) AS payment_id_nulls,
    SUM(trip_id IS NULL) AS trip_id_nulls,
    SUM(amount IS NULL) AS amount_nulls,
    SUM(method IS NULL) AS method_nulls,
    SUM(status IS NULL) AS status_nulls,
	SUM(paid_at IS NULL) AS paid_at_nulls
from payments;

#Reviews table

SELECT
    SUM(review_id IS NULL) AS review_id_nulls,
    SUM(trip_id IS NULL) AS trip_id_nulls,
    SUM(reviewer_id IS NULL) AS reviewer_nulls,
    SUM(reviewee_id IS NULL) AS reviewee_nulls,
    SUM(rating IS NULL) AS rating_nulls,
	SUM(comment IS NULL) AS comment_nulls,
    SUM(reviewed_at IS NULL) AS reviewed_at_nulls
from reviews;

#Riders table

SELECT
    SUM(rider_id IS NULL) AS rider_id_nulls,
    SUM(user_id IS NULL) AS user_id_nulls,
    SUM(rating IS NULL) AS rating_nulls,
    SUM(total_trips IS NULL) AS total_trips_nulls,
    SUM(created_at IS NULL) AS created_at_nulls
from riders;

#Trips table

SELECT
    SUM(trip_id IS NULL) AS trip_id_nulls,
    SUM(rider_id IS NULL) AS rider_id_nulls,
    SUM(driver_id IS NULL) AS driver_id_nulls,
    SUM(pickup_location_id IS NULL) AS pickup_location_id_nulls,
    SUM(dropoff_location_id IS NULL) AS dropoff_location_id_nulls,
	SUM(requested_at IS NULL) AS requested_at_nulls,
    SUM(started_at IS NULL) AS started_at_nulls,
    SUM(completed_at IS NULL) AS completed_at_nulls,
    SUM(status IS NULL) AS status_nulls,
    SUM(distance_km IS NULL) AS distance_km_nulls,
    SUM(duration_mins IS NULL) AS duration_mins_nulls,
    SUM(base_fare IS NULL) AS base_fare_nulls,
    SUM(surge_multiplier IS NULL) AS surge_multiplier_nulls,
    SUM(total_fare IS NULL) AS total_fare_nulls,
    SUM(payment_method IS NULL) AS payment_method_nulls
from trips;

#Users table

SELECT
    SUM(user_id IS NULL) AS user_id_nulls,
    SUM(name IS NULL) AS name_nulls,
    SUM(email IS NULL) AS email_nulls,
    SUM(phone IS NULL) AS phone_nulls,
    SUM(city IS NULL) AS city_nulls,
    SUM(date_joined IS NULL) AS date_joined_nulls,
    SUM(is_driver IS NULL) AS is_driver
from users;

-- ============================================================================
#End of Script
-- ============================================================================
/*
===============================================================================
ANALYSIS SUMMARY: 
===============================================================================
1. There are 8 tables in the database.

2. Total row count for each table is as follows:
total_cancellations=2966
total_drivers=400
total_locations=40
total_payments_count=16827
total_reviews=15136
total_riders=1600
total_trips=20000
total_users=2000

3. After previewing all the tables, It is highly likely that the trips table 
acts as the base table for the whole database.

4. After reviewing the table structure for each table, The results are listed below:
cancellations:
	cancel_id= PRIMARY KEY
    trip_id=FOREIGN KEY for trips.trip_id and cannot be NULL
drivers:
	driver_id= PRIMARY KEY
    user_id= FOREIGN KEY for users.user_id and cannot be NULL
    license_plate= UNIQUE KEY
    is_active= Cannot be NULL and default value is 1
locations:
	location_id= PRIMARY KEY
payments:
	payment_id= PRIMARY KEY
    trip_id= FOREIGN KEY for trips.trip_id and cannot be NULL
reviews:
	review_id= PRIMARY KEY
    trip_id= FOREIGN KEY for trips.trip_id and cannot be NULL
    reviewer_id= FOREIGN KEY for users.user_id and cannot be NULL
    reviewee_id= FOREIGN KEY for users.user_id and cannot be NULL
riders:
    rider_id= PRIMARY KEY
    user_id= FOREIGN KEY for users.user_id and cannot be NULL
    total_trips= cannot be NULL and default value is 0
trips: 
	trip_id= PRIMARY KEY
    rider_id= FOREIGN KEY for riders.rider_id and cannot be NULL
    driver_id= FOREIGN KEY for drivers.driver_id and cannot be NULL
    pickup_location_id= FOREIGN KEY for locations.location_id and cannot be NULL
    dropoff_location_id= FOREIGN KEY for locations.location_id and cannot be NULL
users:
	user_id=PRIMARY KEY
    name= cannot be NULL
    email= UNIQUE KEY and cannot be NULL
    is_driver= cannot be NULL and default is 0

From the above information, we can conclude that reviews table has two columns (reviewer_id and reviewee_id)
referring to the same column in the users table (user_id) and the trips table has two columns(pickup_location_id and dropoff_location_id)
referring to the same column in the locations table (location_id).

5. After performing all the NULL value checks, the following information has been uncovered:
The reviews table has 5920 nulls in the comment column.
The trips table has 3173 nulls in the completed_at column.
===============================================================================
*END OF SUMMARY*
===============================================================================
*/



