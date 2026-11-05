/*
===============================================================================
Script:         13_report_location.sql
Project:        SQL Uber Rides Analytics Project (MySQL)
Author:         Sai Prithvi Sudhakar
Database:       uberridesanalyticsdatabase

Description:
	Creates a location analytics report that compiles location-wise
    demographics and identifies the best day of the week and time of day.

Highlights:
    -City
    -Location
    -Best day of the week
    -Best time of day
    -Total trip count
    
===============================================================================
*/

USE uberridesanalyticsdatabase;
-- ============================================================================
-- Drop Existing View
-- ============================================================================

DROP VIEW IF EXISTS report_location;

-- ============================================================================
-- Create Location Report View
-- ============================================================================

CREATE VIEW report_location AS
(
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
base_trips as(
SELECT l.zone_name,count(t.trip_id) AS trip_location_count, 
count(distinct t.driver_id) AS unique_drivers, 
count(distinct t.rider_id) AS unique_riders,
round(avg(t.surge_multiplier),2) AS avg_surge_multiplier,
round(avg(t.distance_km),2) AS avg_distance_covered
FROM trips t 
LEFT JOIN locations l ON l.location_id=t.pickup_location_id
GROUP BY l.zone_name),
base_revenue as(
SELECT l.zone_name,
round(SUM(p.amount*0.2),2) AS uber_revenue
FROM trips t 
LEFT JOIN locations l ON l.location_id=t.pickup_location_id
LEFT JOIN payments p ON t.trip_id=p.trip_id
WHERE p.status="success"
GROUP BY l.zone_name
),
ranked as(
SELECT cte.*, DENSE_RANK() OVER (PARTITION BY city,zone_name ORDER BY total_bookings,GREATEST(morning,afternoon,evening,night) DESC) AS rnk
FROM cte)
SELECT r.city,r.zone_name,r.day_of_week AS best_day,
    CONCAT_WS(', ', 
        CASE WHEN r.morning = GREATEST(r.morning,r.afternoon,r.evening,r.night) THEN 'Morning' END,
        CASE WHEN r.afternoon = GREATEST(r.morning,r.afternoon,r.evening,r.night) THEN 'Afternoon' END,
        CASE WHEN r.evening = GREATEST(r.morning,r.afternoon,r.evening,r.night) THEN 'Evening' END,
        CASE WHEN r.night = GREATEST(r.morning,r.afternoon,r.evening,r.night) THEN 'Night' END
    ) AS best_time_of_day,
    GREATEST(r.morning,r.afternoon,r.evening,r.night) AS bookings_for_combination,
    r.total_bookings AS total_bookings_that_day,
    t.trip_location_count AS total_bookings_for_location, t.unique_drivers, t.unique_riders, t.avg_distance_covered,t.avg_surge_multiplier, 
    s.uber_revenue
FROM ranked r
LEFT JOIN base_trips t ON r.zone_name=t.zone_name
LEFT JOIN base_revenue s ON r.zone_name=s.zone_name
WHERE rnk=1
ORDER BY city,zone_name
)

-- ============================================================================
#End of Script
-- ============================================================================

/*
===============================================================================
ANALYSIS SUMMARY: 
===============================================================================
	1. Each zone was analyzed and the best day of the week and the best time of day to get the maximum bookings for that location was identified. 
    The bookings for combination column displays how many bookings were done during that time of day on the best day of the week for that location over 2.5 years.
    The total bookings that day displays the total bookings for that day for that location over 2.5 years.
    The total bookings counts the total bookings done from that location.
    2. NY Flushing has the highest bookings in a single location (607) and the lowest being LA Burbank (397) but is only trailing by 300$ to Flushing 
    which confirms the previous hypothesis that LA has higher average trip distance as well as higher base fare compared to NY.
    3. Despite Wednesday having the most bookings overall, NY Flushing has the most bookings on a Saturday with 74 and LaGuardia Airport has the same on a Friday.
    Lowest bookings in a single day is Downtown LA with only 46 bookings.
    4. Houston Medical Center had the highest bookings on Tuesday Afternoons at 26 and had a total of 70 bookings for Tuesdays. 
    (Perhaps there was a big accident or epidemic on a singular day, biasing the total count to a higher amount)
    Downtown LA had the least bookings on Monday mornings at 15.
    5. The unique driver and rider count is much lower for LA and Chicago compared to NY and Houston.
    6. The highest revenue generated by a single location was by Houston IAH Airport with 5.69k$ and lowest being The Loop in Chicago at 1.53k$ 
    (Since the loop is actually a public metro transit in Chicago, People generally prefer walking to the station or a similar form of transport to get to the station.) 
    7. Grand Central NY has the highest average surge multiplier at 1.31 and the lowest is 1.23 for 6 locations. 
===============================================================================
*END OF SUMMARY*
===============================================================================
*/

