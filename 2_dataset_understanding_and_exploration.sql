/*
===============================================================================
Script:         2_dataset_understanding_and_exploration.sql
Project:        SQL Uber Rides Analytics Project (MySQL)
Author:         Sai Prithvi Sudhakar
Database:       uberridesanalyticsdatabase

Description:
    This script explores the dimension tables 
    to understand their attributes, unique values, and distributions.
    It also performs basic data validation checks.

Objectives:
    1. Explore drivers information.
    2. Explore locations information.
    3. Explore riders information.
    4. Explore users information.
    5. Explore trips information.
    6. Identify unique cities and zone types.
    7. Explore vehicle makes of the drivers.
    8. Explore unique payment methods.
    9. Explore riders and drivers within the users table.
    10. Check payment status distribution in the payments table.
    11. Check cancellations distribution for driver vs rider cancellation.
    12. Check for riders who never took a trip.
    13. Check for drivers who never conducted a trip.
    14. Check trips distribution based on status.
    15. Check if the total fare in the trips table is equal to the payment total in the payments table.
    16. Check if there are any completed trips without a successful payment.

===============================================================================
*/

USE uberridesanalyticsdatabase;

-- ============================================================================
#1: Preview drivers Dimension
-- ============================================================================

SELECT * FROM drivers
LIMIT 10;

-- ============================================================================
#2: Preview locations Dimension
-- ============================================================================

SELECT * FROM locations
LIMIT 10;

-- ============================================================================
#3: Preview riders Dimension
-- ============================================================================

SELECT * FROM riders
LIMIT 10;

-- ============================================================================
#4: Preview users Dimension
-- ============================================================================

SELECT * FROM users
LIMIT 10;

-- ============================================================================
#5: Preview trip information
-- ============================================================================

SELECT * FROM trips
LIMIT 10;

-- ============================================================================
#6: Identify unique cities and zone types
-- ============================================================================

SELECT distinct city from locations;

SELECT distinct zone_type from locations;

SELECT
    city,
    COUNT(*) AS location_count
FROM locations
GROUP BY city
ORDER BY location_count DESC;

SELECT
    zone_type,
    COUNT(*) AS location_count
FROM locations
GROUP BY zone_type
ORDER BY location_count DESC;

-- ============================================================================
#7: Explore vehicle makes of the drivers
-- ============================================================================

SELECT DISTINCT vehicle_make FROM drivers;

SELECT
    vehicle_make,
    COUNT(*) AS vehicle_make_count
FROM drivers
GROUP BY vehicle_make
ORDER BY vehicle_make_count DESC;

-- ============================================================================
#8: Explore unique payment methods
-- ============================================================================

SELECT DISTINCT method from payments;

SELECT
    method as payment_method,
    COUNT(*) AS method_count
FROM payments
GROUP BY method
ORDER BY method_count DESC;

-- ============================================================================
#9: Explore riders and drivers distribution within the users table
-- ============================================================================

WITH cte AS(
SELECT user_id,name,
CASE WHEN is_driver=0 THEN "RIDER"
WHEN is_driver=1 THEN "DRIVER"
END AS TAG
FROM users)
SELECT cte.TAG, COUNT(cte.TAG) AS user_count FROM cte
GROUP BY cte.TAG;

-- ============================================================================
#10: Check payment status distribution in the payments table
-- ============================================================================

SELECT status,count(*) AS status_count FROM payments
GROUP BY status
ORDER BY status_count DESC;

-- ============================================================================
#11: Check cancellations distribution for driver vs rider cancellation
-- ============================================================================

SELECT cancelled_by,count(*) AS cancel_count FROM cancellations
GROUP BY cancelled_by
ORDER BY cancel_count DESC;

-- ============================================================================
#12: Check for riders who never took a trip
-- ============================================================================

SELECT r.rider_id, r.user_id, u.name FROM riders r
JOIN users u ON r.user_id=u.user_id
WHERE NOT EXISTS (SELECT 1 FROM trips t WHERE t.rider_id=r.rider_id);

-- ============================================================================
#13: Check for drivers who never conducted a trip
-- ============================================================================

SELECT d.driver_id, d.user_id, u.name FROM drivers d
JOIN users u ON d.user_id=u.user_id
WHERE NOT EXISTS (SELECT 1 FROM trips t WHERE t.driver_id=d.driver_id);

-- ============================================================================
#14: Check trips distribution based on status
-- ============================================================================

SELECT status,count(*) AS status_count FROM trips
GROUP BY status
ORDER BY status_count DESC;

-- ============================================================================
#15: Check if the total fare in the trips table is equal to the payment total in the payments table
-- ============================================================================

SELECT round(sum(total_fare),2) AS fare_total, (SELECT round(sum(amount),2) FROM payments WHERE status="success") AS payment_total 
FROM trips
WHERE status="completed";

-- ============================================================================
#16. Check if there are any completed trips without a successful payment
-- ============================================================================

SELECT t.trip_id,t.driver_id,t.rider_id FROM trips t
WHERE NOT EXISTS (SELECT 1 FROM payments p WHERE t.trip_id=p.trip_id AND p.status="success")
AND t.status="completed";

-- ============================================================================
#End of Script
-- ============================================================================
/*
===============================================================================
ANALYSIS SUMMARY: 
===============================================================================

1. Displays the driver information for each driver_id.
2. Displays the location information for each location_id.
3. Displays the rider information for each rider_id.
4. Displays the user information for each user_id.
5. Displays the trip information for each trip_id.
6. There are 4 unique cities and zone types in total. The location is equal for each city with a location count of 10. There are many more residential and commerical
	zone types than airports or transit hubs.
7. There are 10 car companies that are in use by the drivers. The most common company in use is Nissan, followed closely by Chevrolet and Mazda.
8. There are 3 payment methods that were used to complete a payment for a trip. The methods are somewhat evenly distributed with card being the most common form of payment.
9. We can see that there are 1600 riders and 400 drivers in the users database.
10. Most of the payments successfully went through but a small percentage of payments either failed or were refunded.
11. The rider is primarily responsible for cancellations taking place with 2069 cancellations, but there were also 897 cancellations by the drivers themselves.
12. There are 29 riders who have never taken a trip with Uber.
13. There are 49 drivers who have never conducted a trip through Uber.
14. There are 2966 trips that were cancelled and 207 trips that are still "in_progress".
15. The fare_total is higher than the payment_total for all completed trips and successful payments which makes sense as the fare_total considers all payments regardless of
	whether it was successful or not.
16. There are 468 trips that successfully completed but the payment did not go through. This is an error with the database because if a certain payment fails, 
there must be a follow up payment method for that same trip.
===============================================================================
*END OF SUMMARY*
===============================================================================
*/