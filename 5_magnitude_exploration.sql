/*
===============================================================================
Script:         5_magnitude_analysis.sql
Project:        SQL Uber Rides Analytics Project (MySQL)
Author:         Sai Prithvi Sudhakar
Database:       uberridesanalyticsdatabase

Description:
    Analyze the magnitude of business measures across different
    dimensions such as city, vehicle,cancellations,drivers and riders.

Objectives:
    1. Analyze revenue by city.
    2. Total riders per city.
    3. Total drivers per city.
    4. Total revenue generated per driver.
    5. Analyze frequency of each vehicle company.
    6. Analyze primary reasons for cancellations by riders.
    7. Analyze primary reasons for cancellations by drivers.
    8. Analyze which payment method failed the most.
    9. Total bookings per holiday.
    10. Analyze total trips and total revenue generated for each uber_category.
    11. Analyze peak times for each zone according to day of the week.
    12. Analyze average surge multiplier for holidays.

===============================================================================
*/

USE uberridesanalyticsdatabase;

-- ============================================================================
#1: Analyze revenue by city
-- ============================================================================

WITH cte AS(
SELECT t.trip_id,t.pickup_location_id,l.city,p.amount,p.status AS payment_status FROM trips t
LEFT JOIN locations l ON  t.pickup_location_id=l.location_id
LEFT JOIN payments p ON t.trip_id=p.trip_id
ORDER BY t.trip_id)
SELECT cte.city,round(SUM(cte.amount),2) AS total_revenue,
round(SUM(cte.amount)*0.2,2) AS total_uber_revenue
FROM cte
WHERE payment_status="success"
GROUP BY cte.city
ORDER BY total_revenue DESC;

-- ============================================================================
#2: Total riders per city
-- ============================================================================
SELECT city,count(user_id) AS total_riders FROM users
WHERE is_driver=0
GROUP BY city
ORDER BY count(user_id) DESC;

-- ============================================================================
#3: Total drivers per city
-- ============================================================================

SELECT city,count(user_id) AS total_drivers FROM users
WHERE is_driver=1
GROUP BY city
ORDER BY count(user_id) DESC;

-- ============================================================================
#4: Total revenue generated per driver
-- ============================================================================
with cte as(
SELECT t.trip_id,t.driver_id,u.name,p.amount FROM trips t
LEFT JOIN payments p ON p.trip_id=t.trip_id
LEFT JOIN drivers d ON d.driver_id=t.driver_id
LEFT JOIN users u ON d.user_id=u.user_id
WHERE p.status="success")
SELECT driver_id,name,round(sum(amount),2) AS total_revenue,
round(sum(amount)*0.2,2) AS total_uber_revenue
FROM cte
GROUP BY driver_id,name
ORDER BY total_revenue DESC;

-- ============================================================================
#5. Analyze frequency of each vehicle company
-- ============================================================================
with cte as(
SELECT t.trip_id,t.driver_id,d.vehicle_make FROM trips t
LEFT JOIN drivers d ON t.driver_id=d.driver_id)
SELECT vehicle_make,count(trip_id) AS vehicle_count FROM cte
GROUP BY vehicle_make
ORDER BY vehicle_count DESC;

-- ============================================================================
#6. Analyze primary reasons for cancellations by riders
-- ============================================================================

SELECT reason AS rider_reason,count(cancel_id) AS count FROM cancellations
WHERE cancelled_by="rider"
GROUP BY reason
ORDER BY count DESC;

-- ============================================================================
#7. Analyze primary reasons for cancellations by drivers
-- ============================================================================
SELECT reason AS driver_reason,count(cancel_id) as count FROM cancellations
WHERE cancelled_by!="rider"
GROUP BY reason
ORDER BY count DESC;

-- ============================================================================
#8. Analyze which payment method failed the most
-- ============================================================================

SELECT method, count(payment_id) AS failed_count FROM payments
WHERE status<>"success"
GROUP BY method
ORDER BY failed_count DESC;

#Analyze what status is the main reason behind cash payments failing
SELECT status,count(payment_id) AS fail_count 
FROM payments 
WHERE status<>"success" and method="cash" 
GROUP BY status 
ORDER BY fail_count DESC;

-- ============================================================================
#9. Total bookings per holiday
-- ============================================================================

with cte as(
    SELECT trip_id, CAST(requested_at AS DATE) AS requested_at 
    FROM trips 
    WHERE CAST(requested_at AS DATE) IN (SELECT `2022` FROM holidays)
       OR CAST(requested_at AS DATE) IN (SELECT `2023` FROM holidays)
       OR CAST(requested_at AS DATE) IN (SELECT `2024` FROM holidays)
),
cte2 AS(SELECT h.holiday_name, YEAR(cte.requested_at) AS year,
COUNT(cte.trip_id) AS bookings
FROM cte
JOIN holidays h ON 
    (YEAR(cte.requested_at) = 2022 AND h.`2022` = cte.requested_at)
    OR (YEAR(cte.requested_at) = 2023 AND h.`2023` = cte.requested_at)
    OR (YEAR(cte.requested_at) = 2024 AND h.`2024` = cte.requested_at)
GROUP BY h.holiday_name,YEAR(cte.requested_at)
ORDER BY bookings DESC)
SELECT holiday_name, 
SUM(CASE WHEN year=2022 THEN bookings ELSE 0 END) AS "2022",
SUM(CASE WHEN year=2023 THEN bookings ELSE 0 END) AS "2023",
SUM(CASE WHEN year=2024 THEN bookings ELSE 0 END) AS "2024",
SUM(bookings) AS total_bookings
FROM cte2
GROUP BY holiday_name
ORDER BY total_bookings DESC;

-- ============================================================================
#10: Analyze total trips and total revenue generated for each uber_category
-- ============================================================================

SELECT v.uber_category, count(t.trip_id) AS total_trips, round(sum(p.amount),2) AS total_revenue, round((sum(p.amount)*0.2),2) AS total_uber_revenue FROM trips t
LEFT JOIN drivers d ON t.driver_id=d.driver_id
LEFT JOIN payments p ON p.trip_id=t.trip_id
LEFT JOIN vehicles v ON d.vehicle_make=v.vehicle_make AND d.vehicle_model=v.vehicle_model AND d.vehicle_year=v.vehicle_year
WHERE p.status="success"
GROUP BY v.uber_category;


-- ============================================================================
#11: Analyze peak times for each zone according to day of the week.
-- ============================================================================

with cte as(
SELECT l.city,l.zone_name,date_format(t.requested_at,"%a") AS day_of_week,
SUM(CASE WHEN date_format(t.requested_at,"%H") BETWEEN 4 AND 10 THEN 1 ELSE 0 END) AS morning,
SUM(CASE WHEN date_format(t.requested_at,"%H") BETWEEN 11 AND 16 THEN 1 ELSE 0 END) AS afternoon,
SUM(CASE WHEN date_format(t.requested_at,"%H") BETWEEN 17 AND 22 THEN 1 ELSE 0 END) AS evening,
SUM(CASE WHEN date_format(t.requested_at,"%H") IN (23,0,1,2,3) THEN 1 ELSE 0 END) AS night,
count(t.trip_id) AS total_bookings
FROM locations l
LEFT JOIN trips t ON l.location_id=t.pickup_location_id
GROUP BY l.city,l.zone_name,day_of_week
ORDER BY total_bookings DESC),
cte2 as(
SELECT "SubTotal","-","--",
SUM(cte.morning),
SUM(cte.afternoon),
SUM(cte.evening),
SUM(cte.night),
SUM(total_bookings)
FROM cte)

SELECT cte.*
FROM cte
UNION ALL
SELECT cte2.*
FROM cte2;

-- ============================================================================
#12: Analyze average surge multiplier for holidays
-- ============================================================================
with cte as(
    SELECT trip_id,surge_multiplier,CAST(requested_at AS DATE) AS requested_at 
    FROM trips 
    WHERE CAST(requested_at AS DATE) IN (SELECT `2022` FROM holidays)
       OR CAST(requested_at AS DATE) IN (SELECT `2023` FROM holidays)
       OR CAST(requested_at AS DATE) IN (SELECT `2024` FROM holidays)
),
cte2 AS(SELECT h.holiday_name, YEAR(cte.requested_at) AS year,
COUNT(cte.trip_id) AS bookings,
round(avg(cte.surge_multiplier),2) AS surge_multi
FROM cte
JOIN holidays h ON 
    (YEAR(cte.requested_at) = 2022 AND h.`2022` = cte.requested_at)
    OR (YEAR(cte.requested_at) = 2023 AND h.`2023` = cte.requested_at)
    OR (YEAR(cte.requested_at) = 2024 AND h.`2024` = cte.requested_at)
GROUP BY h.holiday_name,YEAR(cte.requested_at)
ORDER BY bookings DESC)
SELECT holiday_name,
SUM(CASE WHEN year=2022 THEN bookings ELSE 0 END) AS "2022",
SUM(CASE WHEN year=2023 THEN bookings ELSE 0 END) AS "2023",
SUM(CASE WHEN year=2024 THEN bookings ELSE 0 END) AS "2024",
round(avg(surge_multi),2) AS avg_surge_multiplier,
SUM(bookings) AS total_bookings
FROM cte2
GROUP BY holiday_name
ORDER BY total_bookings DESC;

-- ============================================================================
#End of Script
-- ============================================================================
/*
===============================================================================
ANALYSIS SUMMARY: 
===============================================================================
    1. The total revenue generated was highest in Houston with a total revenue of $183k, with LA $30k behind. 
    2. The highest amount of riders were in Houston at 442 riders, followed by LA at 407.
    3. The highest number of drivers were in Houston at 110 drivers, with New York close behind at 109.
    4. The driver Andrew Morales has generated the highest total revenue for the company at $3.68k followed by George Gray at $3.48k.
    5. Nissan is the most commonly used company for transport at 2388, followed by Ford at 2359.
    6. The primary reasons for cancellations by riders was "too long wait" for the driver to arrive at a count of 284 along with an additional 262 in different wording
		"waited too long"and then followed by rider changing their mind at 283.
    7. The primary reasons for cancellations by drivers is somewhat evenly distributed with "wrong pickup" being the highest. 
		An investigation needs to be done on why the "wrong pickup" and "system error" count is so high (Perhaps an OTP system needs to be updated or location tracking needs to be improved.)
    8. Wallet has the highest number of failed payments at 171.
    9. The number of bookings does not seem to change during holidays significantly (i.e, It is not much higher than the average bookings per day(22) )
    except for Nevada Day (37) and Thanksgiving Day (30) in 2022. Election Day did not have any bookings in 2023 due to there being no holiday declared that day in 2023.
    10. UberX generated the most revenue for Uber with 69.4k$, followed by Comfort at 42.2k$.
    11. The distribution of bookings for each time of day on each day of the week for each location was done. 
    The highest bookings were done during the morning hours(5752) followed by evening hours(5070).
    Further analysis is continued in section 8_performance_analysis.
    12. The average surge multiplier is highest for Veterans' Day at 1.46 and lowest for Thanksgiving Day at 1.13.
===============================================================================
*END OF SUMMARY*
===============================================================================
*/