/*
===============================================================================
Script:         8_performance_analysis.sql
Project:        SQL Uber Rides Analytics Project (MySQL)
Author:         Sai Prithvi Sudhakar
Database:       uberridesanalyticsdatabase

Description:
    Analyze driver performance by comparing rating,revenue
    against historical average performance.

Objectives:
    1. Compare driver performance with the overall average driver revenue in that city.
    2. Identify the best performing driver each month per year.
    3. Identify the drivers who have an average rating higher than the overall average driver rating.
    4. Identify the hour for each of day of the week with the most bookings.
    5. Identify the best day of the week and time of day for bookings in each location.

===============================================================================
*/

USE uberridesanalyticsdatabase;

-- ============================================================================
#1: Compare driver performance with the overall average driver revenue in that city
-- ============================================================================

with base as(
Select l.city,t.driver_id,round(SUM(p.amount),2) as driver_total FROM trips t
LEFT JOIN payments p on p.trip_id=t.trip_id
LEFT JOIN locations l on l.location_id=t.pickup_location_id
WHERE p.status="success"
GROUP BY l.city,t.driver_id
ORDER BY l.city),
cte as(
SELECT b.*,round((AVG(driver_total) OVER(PARTITION BY b.city)),2) AS city_average_total 
FROM base b
)
SELECT cte.* FROM cte
WHERE cte.driver_total>cte.city_average_total;

-- ============================================================================
#2: Identify the best performing driver each month per year
-- ============================================================================

with base as(
SELECT date_format(t.completed_at,"%Y-%m") AS yrmon,
u.name as driver_name,
DENSE_RANK() OVER(PARTITION BY date_format(t.completed_at,"%Y-%m") ORDER BY round(sum(p.amount),2) DESC) AS rnk,
round(sum(p.amount),2) AS total_revenue
FROM trips t
LEFT JOIN payments p ON p.trip_id=t.trip_id
LEFT JOIN drivers d ON t.driver_id=d.driver_id
LEFT JOIN users u ON u.user_id=d.user_id
WHERE p.amount AND p.status="success"
GROUP BY yrmon, t.driver_id, u.name
ORDER BY yrmon
)
Select yrmon,driver_name,total_revenue from base where rnk=1;

-- ============================================================================
#3: Identify the drivers who have an average rating higher than the overall average driver rating
-- ============================================================================

with base as(
SELECT d.driver_id,u.name,round(avg(r.rating),2) AS avg_rating_received FROM drivers d
LEFT JOIN users u ON d.user_id=u.user_id
LEFT JOIN reviews r ON d.user_id=r.reviewee_id
GROUP BY d.driver_id)
SELECT b.driver_id,b.name AS driver_name,b.avg_rating_received 
FROM base b
WHERE b.avg_rating_received>(Select avg(avg_rating_received) from base);

-- ============================================================================
#4: Identify the hour for each of day of the week with the most bookings.
-- ============================================================================

with cte as(
SELECT date_format(requested_at, "%a") AS day_of_week,
date_format(requested_at, "%w") AS day_num, date_format(requested_at, "%H") AS hours,
count(trip_id) AS bookings,
DENSE_RANK() OVER(PARTITION BY date_format(requested_at, "%a") ORDER BY count(trip_id) DESC) AS rnk
FROM trips
GROUP BY day_of_week,day_num,hours)
SELECT cte.day_of_week,cte.hours,cte.bookings AS hourly_bookings FROM cte
WHERE rnk=1
ORDER BY cte.day_num;

-- ============================================================================
#5. Identify the best day of the week and time of day for bookings in each location.
-- ============================================================================

with cte as(
SELECT l.city,l.zone_name,date_format(t.requested_at,"%W") AS day_of_week,
SUM(CASE WHEN date_format(t.requested_at,"%H") BETWEEN 4 AND 10 THEN 1 ELSE 0 END) AS morning,
SUM(CASE WHEN date_format(t.requested_at,"%H") BETWEEN 11 AND 16 THEN 1 ELSE 0 END) AS afternoon,
SUM(CASE WHEN date_format(t.requested_at,"%H") BETWEEN 17 AND 22 THEN 1 ELSE 0 END) AS evening,
SUM(CASE WHEN date_format(t.requested_at,"%H") IN (23,0,1,2,3) THEN 1 ELSE 0 END) AS night,
count(t.trip_id) AS total_bookings
FROM locations l
LEFT JOIN trips t ON l.location_id=t.pickup_location_id
GROUP BY l.city,l.zone_name,day_of_week
ORDER BY total_bookings DESC),
ranked as(
SELECT cte.*, DENSE_RANK() OVER (PARTITION BY city,zone_name ORDER BY total_bookings DESC) AS rnk
FROM cte)
SELECT city,zone_name,day_of_week AS best_day,
    CONCAT_WS(', ', 
        CASE WHEN morning = GREATEST(morning,afternoon,evening,night) THEN 'Morning' END,
        CASE WHEN afternoon = GREATEST(morning,afternoon,evening,night) THEN 'Afternoon' END,
        CASE WHEN evening = GREATEST(morning,afternoon,evening,night) THEN 'Evening' END,
        CASE WHEN night = GREATEST(morning,afternoon,evening,night) THEN 'Night' END
    ) AS best_time_of_day,
GREATEST(morning,afternoon,evening,night) AS bookings_count
FROM ranked
WHERE rnk=1
ORDER BY city,zone_name;



-- ============================================================================
#End of Script
-- ============================================================================

/*
===============================================================================
ANALYSIS SUMMARY: 
===============================================================================

	1. There are 167 drivers who generated more revenue than the average for that city.
    2. The best driver was identified for each month per year. The total revenue they generated in that time period being between 240$ and 420$
    3. There are 179 drivers who have a average rating received higher than the overall average of 3.74.
    4. The hour with the most bookings for each day has been identified.
    5. The best day and the best time of day have been identified for each location.

===============================================================================
*END OF SUMMARY*
===============================================================================
*/