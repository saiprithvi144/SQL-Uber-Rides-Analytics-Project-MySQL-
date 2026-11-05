/*
===============================================================================
Script:         3_date_range_exploration.sql
Project:        SQL Uber Rides Analytics Project (MySQL)
Author:         Sai Prithvi Sudhakar
Database:       uberridesanalyticsdatabase

Description:
    This script explores the date columns in the trips table to
    understand the available historical data, identify date ranges,
    and analyze the distribution of trips over time.

Objectives:
    1. Preview date columns.
    2. Identify minimum and maximum dates.
    3. Calculate the duration of historical trips data.
    4. Explore trip activity by year.
    5. Explore trip activity by month.
    6. Analyze yearly and monthly trends of trips.
    7. Check if any reviews were given before a trip is completed.
    8. Check for any payments done before a trip is completed.
    9. Check if any driver join date is before their user account creation.
    10. Check if any rider creation date is before their user account creation.
    11. Check if the difference between started_at and completed_at is same as the duration_mins column.
    12. Find the average duration of a trip and also the maximum duration.
    13. Find the time of day with the most cancellations.
    14. Find the day of the week with the most cancellations.
    15. Find the time of day with the most bookings.
    16. Find the day of the week with the most bookings.
    17. Find the day of the week along with the bookings for each hour.

===============================================================================
*/

USE uberridesanalyticsdatabase;

-- ============================================================================
#1:Preview date columns
-- ============================================================================

SELECT trip_id,cast(requested_at as date) AS requested_at,cast(started_at as date) AS started_at,cast(completed_at as date) AS completed_at FROM trips;
SELECT payment_id,cast(paid_at as date) AS paid_at FROM payments;
SELECT review_id,cast(reviewed_at as date) AS reviewed_at FROM reviews;
SELECT cancel_id,cast(cancelled_at as date) AS cancelled_at FROM cancellations;
SELECT rider_id,user_id, created_at FROM riders;
SELECT driver_id,user_id,join_date FROM drivers;
SELECT user_id,date_joined FROM users;

-- ============================================================================
#2:Identify relevant minimum and maximum dates
-- ============================================================================

SELECT min(cast(requested_at as date)) AS first_requested_date,max(cast(requested_at as date)) AS most_recent_requested_date FROM trips;
SELECT min(cast(created_at as date)) AS first_rider_created_at,max(cast(created_at as date)) AS most_recent_rider_created_at FROM riders;
SELECT min(cast(join_date as date)) AS first_driver_join_date,max(cast(join_date as date)) AS most_recent_driver_join_date FROM drivers;
SELECT min(date_joined) AS first_user_creation_date, max(date_joined) AS last_user_creation_date FROM users;

-- ============================================================================
#3:Calculate the duration of historical trips data
-- ============================================================================

SELECT min(cast(requested_at as date)) AS first_requested_date,max(cast(completed_at as date)) AS most_recent_completed_date,
timestampdiff(month, min(cast(requested_at as date)),max(cast(completed_at as date))) as duration_month
FROM trips;

-- ============================================================================
#4:Explore trip activity by year
-- ============================================================================

SELECT YEAR(requested_at) AS trip_by_year, COUNT(trip_id) AS trip_count FROM trips
GROUP BY YEAR(requested_at)
ORDER BY trip_by_year;

-- ============================================================================
#5: Explore trip activity by month
-- ============================================================================

SELECT MONTH(requested_at) AS trip_by_month,MONTHNAME(requested_at) AS monthname, COUNT(trip_id) AS trip_count FROM trips
GROUP BY MONTH(requested_at),MONTHNAME(requested_at)
ORDER BY trip_by_month;

-- ============================================================================
#6: Analyze yearly and monthly trends of trips
-- ============================================================================

SELECT date_format(requested_at, "%Y-%m") AS yrmon,COUNT(trip_id) AS trip_count FROM trips
GROUP BY date_format(requested_at, "%Y-%m")
ORDER BY yrmon;

-- ============================================================================
#7: Check if any reviews were given before a trip is completed
-- ============================================================================

Select r.review_id FROM reviews r
WHERE EXISTS (SELECT 1 FROM trips t WHERE r.trip_id=t.trip_id AND r.reviewed_at<t.completed_at);

-- ============================================================================
#8: Check for any payments done before a trip is completed
-- ============================================================================

SELECT p.payment_id FROM payments p
WHERE EXISTS (SELECT 1 FROM trips t WHERE p.trip_id=t.trip_id AND p.paid_at<t.completed_at);

-- ============================================================================
#9: Check if any driver join date is before their user account creation
-- ============================================================================

SELECT d.driver_id FROM drivers d
WHERE EXISTS (SELECT 1 FROM users u WHERE d.user_id=u.user_id AND d.join_date<u.date_joined);

-- ============================================================================
#10: Check if any rider creation date is before their user account creation
-- ============================================================================

SELECT r.rider_id FROM riders r
WHERE EXISTS (SELECT 1 FROM users u WHERE r.user_id=u.user_id AND r.created_at<u.date_joined);

-- ============================================================================
#11: Check if the difference between started_at and completed_at is same as the duration_mins column
-- ============================================================================

SELECT trip_id,timestampdiff(minute,started_at,completed_at) AS duration, duration_mins FROM trips
WHERE status="completed" and timestampdiff(minute,started_at,completed_at)!=duration_mins;

-- ============================================================================
#12: Find the average duration of a trip and also the longest and shortest trip
-- ============================================================================

SELECT round(avg(duration_mins),2) as average_trip_duration_mins,min(duration_mins) as shortest_trip_duration_mins, max(duration_mins) as longest_trip_duration_mins from trips;

-- ============================================================================
#13: Find the time of day with the most cancellations
-- ============================================================================

SELECT date_format(cancelled_at,"%H") AS hours,count(cancel_id) AS cancellations FROM cancellations
GROUP BY hours
ORDER BY cancellations DESC;

-- ============================================================================
#14: Find the day of the week with the most cancellations
-- ============================================================================

SELECT date_format(cancelled_at,"%a") AS day_of_week,count(cancel_id) AS cancellations FROM cancellations
GROUP BY day_of_week
ORDER BY cancellations DESC;

-- ============================================================================
#15: Find the time of day with the most bookings
-- ============================================================================

SELECT date_format(requested_at,"%H") AS hours,count(trip_id) AS total_bookings FROM trips
GROUP BY hours
ORDER BY total_bookings DESC;

-- ============================================================================
#16: Find the day of the week with the most bookings
-- ============================================================================

SELECT date_format(requested_at,"%a") AS day_of_week,count(trip_id) AS total_bookings FROM trips
GROUP BY day_of_week
ORDER BY total_bookings DESC;

-- ============================================================================
#17: Find the day of the week along with the bookings for each hour
-- ============================================================================

with cte as(
SELECT date_format(requested_at,"%a") AS day_of_week,
SUM(CASE WHEN date_format(requested_at,"%H")=00 THEN 1 ELSE 0 END) AS "00",
SUM(CASE WHEN date_format(requested_at,"%H")=01 THEN 1 ELSE 0 END) AS "01",
SUM(CASE WHEN date_format(requested_at,"%H")=02 THEN 1 ELSE 0 END) AS "02",
SUM(CASE WHEN date_format(requested_at,"%H")=03 THEN 1 ELSE 0 END) AS "03",
SUM(CASE WHEN date_format(requested_at,"%H")=04 THEN 1 ELSE 0 END) AS "04",
SUM(CASE WHEN date_format(requested_at,"%H")=05 THEN 1 ELSE 0 END) AS "05",
SUM(CASE WHEN date_format(requested_at,"%H")=06 THEN 1 ELSE 0 END) AS "06",
SUM(CASE WHEN date_format(requested_at,"%H")=07 THEN 1 ELSE 0 END) AS "07",
SUM(CASE WHEN date_format(requested_at,"%H")=08 THEN 1 ELSE 0 END) AS "08",
SUM(CASE WHEN date_format(requested_at,"%H")=09 THEN 1 ELSE 0 END) AS "09",
SUM(CASE WHEN date_format(requested_at,"%H")=10 THEN 1 ELSE 0 END) AS "10",
SUM(CASE WHEN date_format(requested_at,"%H")=11 THEN 1 ELSE 0 END) AS "11",
SUM(CASE WHEN date_format(requested_at,"%H")=12 THEN 1 ELSE 0 END) AS "12",
SUM(CASE WHEN date_format(requested_at,"%H")=13 THEN 1 ELSE 0 END) AS "13",
SUM(CASE WHEN date_format(requested_at,"%H")=14 THEN 1 ELSE 0 END) AS "14",
SUM(CASE WHEN date_format(requested_at,"%H")=15 THEN 1 ELSE 0 END) AS "15",
SUM(CASE WHEN date_format(requested_at,"%H")=16 THEN 1 ELSE 0 END) AS "16",
SUM(CASE WHEN date_format(requested_at,"%H")=17 THEN 1 ELSE 0 END) AS "17",
SUM(CASE WHEN date_format(requested_at,"%H")=18 THEN 1 ELSE 0 END) AS "18",
SUM(CASE WHEN date_format(requested_at,"%H")=19 THEN 1 ELSE 0 END) AS "19",
SUM(CASE WHEN date_format(requested_at,"%H")=20 THEN 1 ELSE 0 END) AS "20",
SUM(CASE WHEN date_format(requested_at,"%H")=21 THEN 1 ELSE 0 END) AS "21",
SUM(CASE WHEN date_format(requested_at,"%H")=22 THEN 1 ELSE 0 END) AS "22",
SUM(CASE WHEN date_format(requested_at,"%H")=23 THEN 1 ELSE 0 END) AS "23",
count(trip_id) AS total_bookings
FROM trips
GROUP BY day_of_week
ORDER BY total_bookings DESC),
cte2 as(
SELECT "SubTotal",
SUM(cte.`00`),
SUM(cte.`01`),
SUM(cte.`02`),
SUM(cte.`03`),
SUM(cte.`04`),
SUM(cte.`05`),
SUM(cte.`06`),
SUM(cte.`07`),
SUM(cte.`08`),
SUM(cte.`09`),
SUM(cte.`10`),
SUM(cte.`11`),
SUM(cte.`12`),
SUM(cte.`13`),
SUM(cte.`14`),
SUM(cte.`15`),
SUM(cte.`16`),
SUM(cte.`17`),
SUM(cte.`18`),
SUM(cte.`19`),
SUM(cte.`20`),
SUM(cte.`21`),
SUM(cte.`22`),
SUM(cte.`23`),
SUM(total_bookings)
FROM cte)

SELECT cte.*
FROM cte
UNION ALL
SELECT cte2.*
FROM cte2;



-- ============================================================================
#End of Script
-- ============================================================================
/*
===============================================================================
ANALYSIS SUMMARY: 
===============================================================================
1. The completed_at date column in trip_id has null values but still contains "duration_mins" column data.
2. The trips table contains data from 2022 to 2024, but the first rider and driver joined as early as 2019. The first rider was created before
the first driver joined. The first user account was created on the same day as the first rider.
3. The trips table contains data from 2022 to 2024, a total of 29 months (or around 2.4 years).
4. The trip data per year shows higher trip counts for 2022 and 2023 than 2024, 
but this can be explained by the dataset trip data ending at June of 2024, which is still in the middle of the year.
5. March and January have higher trip counts of over 2000.
6. Analyzing by year-month, 2024 January, 2022 March and 2023 November have trip counts higher than 700.
7. No reviews were given before a trip was completed.
8. No payments were done before a trip was completed.
9. 202 drivers have their join date before their user account creation.
10. 806 riders have their creation date before their user account creation.
11. All completed trips share the exact same duration.
12. An average trip lasted around 31 minutes, the shortest trip only took 3 minuntes and the longest trip took around 153 mins (or 2.5 hours).
13. There seems to be more cancellations during the evening and night hours between 5PM to 1AM.
14. The cancellations are almost evenly distributed except for Monday and Sunday having significantly lower cancellations than the rest.
15. The highest number of bookings happened at 6PM (891) and 2PM (889), followed by 8AM (870). 
16. Wednesday (2919),Friday (2900) and Tuesday (2893) have slightly higher total bookings than the rest of the other days, with Monday being the least (2783).
17. Wednesday bookings peak during night hours from 6PM to 2AM.
	Friday bookings peak during morning hours from 8AM to 11AM. 
    Tuesday bookings peak at seemingly random times. There is a big dip in bookings between 2AM to 8AM.
    Saturday bookings peak at 12AM and then pick up again only at 12PM-3PM and finally at 5PM to 7PM.
    Thursday bookings peak at 1AM-3AM and then at 6PM-7PM.
    Sunday bookings peak at seemingly random times like Tuesday. Only peaks at 2AM ,1PM	and 11PM.
    Monday bookings peak at morning hours between 8AM-10AM.
    Overall bookings peak at 8AM-11AM,2PM-3PM and 6PM-2AM. These are the peak hours that should be prioritized especially the evening-night hours with more driver availability.

===============================================================================
*END OF SUMMARY*
===============================================================================
*/