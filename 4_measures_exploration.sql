/*
===============================================================================
Script:         4_measures_exploration.sql
Project:        SQL Uber Rides Analytics Project (MySQL)
Author:         Sai Prithvi Sudhakar
Database:       uberridesanalyticsdatabase

Description:
    This script explores key business measures primarily from the trips table.
    It provides high-level KPIs such as total revenue, total trips,
    average revenue and rider metrics.

Objectives:
    1. Calculate overall revenue KPIs.
    2. Measure rider activity.
    3. Measure geological location data.
    4. Calculate averages and totals.
    5. Build foundational business metrics.

===============================================================================
*/

USE uberridesanalyticsdatabase;

-- ============================================================================
#1: Calculate overall revenue KPIs
-- ============================================================================

#Total Revenue Generated
SELECT
    round(SUM(amount),2) AS total_revenue,
    (SELECT round(SUM(total_fare),2) FROM trips)  AS Hypothetical_total,
    round(SUM(amount)*0.2,2) AS uber_commission,
    (SELECT round(SUM(total_fare)*0.2,2) FROM trips) AS Hypothetical_uber_total
FROM payments WHERE status="success";

#Total Trips successfully completed
SELECT count(*) AS successful_trip_count,(SELECT count(*) FROM trips) AS total_trips FROM trips
WHERE status="completed";

#Total Drivers
SELECT count(*) AS active_drivers, (SELECT count(*) FROM drivers) AS total_drivers  FROM drivers
WHERE is_active=1;

#Total Riders
SELECT count(*) AS booked_riders,
(SELECT count(*) FROM riders) AS total_riders FROM riders r
WHERE EXISTS (SELECT 1 FROM trips t where r.rider_id=t.rider_id);

-- ============================================================================
#2: Measure rider activity
-- ============================================================================

SELECT * FROM riders ORDER BY total_trips DESC;

-- ============================================================================
#3: Measure geological location data with the highest activity
-- ============================================================================

#Location count
with cte as(
SELECT trip_id,pickup_location_id AS location_id FROM trips
)
SELECT l.location_id,l.zone_name,l.city,l.zone_type,count(cte.location_id) as location_count FROM locations l
LEFT JOIN cte ON l.location_id=cte.location_id 
GROUP BY l.location_id,l.zone_name,l.city,l.zone_type
ORDER BY location_count DESC;

#Drop Location count
with cte as(
SELECT trip_id,dropoff_location_id AS location_id FROM trips
)
SELECT l.location_id,l.zone_name,l.city,l.zone_type,count(cte.location_id) as location_count FROM locations l
LEFT JOIN cte ON l.location_id=cte.location_id 
GROUP BY l.location_id,l.zone_name,l.city,l.zone_type
ORDER BY location_count DESC;

#City count
with cte as(
SELECT trip_id,pickup_location_id AS location_id FROM trips
),
cte2 as(
SELECT l.location_id,l.zone_name,l.city,l.zone_type,count(cte.location_id) as location_count FROM locations l
LEFT JOIN cte ON l.location_id=cte.location_id 
GROUP BY l.location_id,l.zone_name,l.city,l.zone_type
ORDER BY location_count DESC)
SELECT city,sum(location_count) AS total_count FROM cte2
GROUP BY city
ORDER BY total_count DESC;

#total cancellations per city
Select l.city,count(c.trip_id) AS total_cancels_per_city from trips t
LEFT JOIN cancellations c ON t.trip_id=c.trip_id
LEFT JOIN locations l ON t.pickup_location_id=l.location_id
GROUP BY l.city
ORDER BY total_cancels_per_city DESC;

#total trips failed per city
Select l.city,round(count(t.trip_id),2) AS total_fails_per_city from trips t
LEFT JOIN payments p ON t.trip_id=p.trip_id
LEFT JOIN locations l ON t.pickup_location_id=l.location_id
WHERE p.status!="success" or p.status is null
GROUP BY l.city
ORDER BY total_fails_per_city DESC;

#total successful trips per city
Select l.city,round(count(t.trip_id),2) AS total_successful_trips_per_city from trips t
LEFT JOIN payments p ON t.trip_id=p.trip_id
LEFT JOIN locations l ON t.pickup_location_id=l.location_id
WHERE p.status="success"
GROUP BY l.city
ORDER BY total_successful_trips_per_city DESC;

#total fare per city
Select l.city,round(sum(t.total_fare),2) AS total_fare_per_city from trips t
LEFT JOIN locations l ON t.pickup_location_id=l.location_id
GROUP BY l.city
ORDER BY total_fare_per_city DESC;

#average total fare per city
Select l.city,round(avg(t.total_fare),2) AS total_fare_avg_per_city from trips t
LEFT JOIN locations l ON t.pickup_location_id=l.location_id
GROUP BY l.city
ORDER BY total_fare_avg_per_city DESC;

#average distance covered per city
Select l.city,round(avg(t.distance_km),2) AS Distance_avg_per_city from trips t
LEFT JOIN locations l ON t.pickup_location_id=l.location_id
GROUP BY l.city
ORDER BY Distance_avg_per_city DESC;

#average total fare per km per city
Select l.city,round(avg(t.total_fare/t.distance_km),2) AS avg_total_fare_per_km_per_city from trips t
LEFT JOIN locations l ON t.pickup_location_id=l.location_id
GROUP BY l.city
ORDER BY avg_total_fare_per_km_per_city DESC;

#average total fare per minute per city
Select l.city,round(avg(t.total_fare/t.duration_mins),2) AS avg_total_fare_per_min_per_city from trips t
LEFT JOIN locations l ON t.pickup_location_id=l.location_id
GROUP BY l.city
ORDER BY avg_total_fare_per_min_per_city DESC;

#Zone type count
with cte as(
SELECT trip_id,pickup_location_id AS location_id FROM trips
),
cte2 as(
SELECT l.location_id,l.zone_name,l.city,l.zone_type,count(cte.location_id) as location_count FROM locations l
LEFT JOIN cte ON l.location_id=cte.location_id 
GROUP BY l.location_id,l.zone_name,l.city,l.zone_type
ORDER BY location_count DESC)
SELECT zone_type,sum(location_count) AS total_count FROM cte2
GROUP BY zone_type
ORDER BY total_count DESC;

-- ============================================================================
#4: Calculate Average and Totals
-- ============================================================================

#Average Trip Duration,Fare,distance
SELECT round(avg(duration_mins),2) AS Avg_trip_duration, round(avg(total_fare),2) AS Avg_trip_fare, round(avg(distance_km),2) AS Avg_distance_km FROM trips;

#Minimum and Maximum Fare,distance
SELECT min(total_fare) as Minimum_Fare, max(total_fare) AS Maximum_Fare FROM trips;
SELECT min(distance_km) AS Minimum_distance_km, max(distance_km) AS Maximum_distance_km FROM trips;

#Average surge multiplier applied
Select round(avg(surge_multiplier),2) AS avg_surge_multiplier from trips;

#Total Revenue generated per Rider along with total trips taken
SELECT t.rider_id,u.user_id,u.name,count(t.trip_id) as trips_taken,
round(SUM(t.total_fare),2) AS total_revenue_per_customer,
round(SUM(t.total_fare)*0.2,2) AS total_revenue_for_Uber FROM trips t
LEFT JOIN payments p ON t.trip_id=p.trip_id
LEFT JOIN riders r ON r.rider_id=t.rider_id
LEFT JOIN users u ON u.user_id=r.user_id
WHERE p.status="success"
GROUP BY t.rider_id,u.user_id,u.name
ORDER BY total_revenue_per_customer DESC;

#Average bookings per day
Select round(avg(coun)) AS avg_bookings_per_day from (Select cast(requested_at as date) as days,count(trip_id) as coun from trips group by days)t;

#Total trips taken per Rider regardless of payment status
SELECT t.rider_id,u.user_id,u.name,count(t.trip_id) as trips_taken FROM trips t
LEFT JOIN payments p ON t.trip_id=p.trip_id
LEFT JOIN riders r ON r.rider_id=t.rider_id
LEFT JOIN users u ON u.user_id=r.user_id
where t.status="completed"
GROUP BY t.rider_id,u.user_id,u.name
ORDER BY trips_taken DESC;

#Analyze the distribution of car types belonging to drivers per uber category.
SELECT v.uber_category,v.vehicle_type,count(driver_id) AS vehicle_count FROM drivers d
LEFT JOIN vehicles v ON v.vehicle_make=d.vehicle_make AND v.vehicle_model=d.vehicle_model AND v.vehicle_year=d.vehicle_year
GROUP BY v.uber_category,v.vehicle_type
ORDER BY v.uber_category;

#Analyze the average surge multiplier for each time of the day
with cte as(
SELECT t.trip_id, t.surge_multiplier, date_format(t.requested_at,"%H") AS hours,
CASE WHEN date_format(t.requested_at,"%H") BETWEEN 4 AND 10 THEN "Morning"
WHEN date_format(t.requested_at,"%H") BETWEEN 11 AND 16 THEN "Afternooon"
WHEN date_format(t.requested_at,"%H") BETWEEN 17 AND 22 THEN "Evening"
WHEN date_format(t.requested_at,"%H") IN (23,0,1,2,3) THEN "Night"
END AS time_of_day  
FROM trips t)
Select time_of_day,round(avg(surge_multiplier),2) AS average_surge_multiplier FROM cte
GROUP BY time_of_day;

#Analyze the average surge multiplier for each day of the week
SELECT date_format(t.requested_at, "%W") AS days, round(avg(t.surge_multiplier),2) AS average_surge_multiplier 
FROM trips t
GROUP BY days
ORDER BY average_surge_multiplier DESC;

-- ============================================================================
#5: Build foundational business metrics
-- ============================================================================
SELECT
    COUNT(trip_id) AS total_trips,
    COUNT(DISTINCT rider_id) AS unique_riders,
    COUNT(DISTINCT driver_id) AS unique_drivers,
    COUNT(DISTINCT pickup_location_id) AS unique_pickup_locations,
    COUNT(DISTINCT dropoff_location_id) AS unique_drop_locations,
    round(avg(duration_mins),2) AS Avg_trip_duration, 
    round(avg(total_fare),2) AS Avg_trip_fare, 
    round(avg(distance_km),2) AS Avg_distance_km,
    round(avg(surge_multiplier),2) AS Avg_surge_multiplier,
    (SELECT
    round(SUM(amount),2) AS total_revenue
	FROM payments WHERE status="success") AS total_revenue,
    round(SUM(total_fare),2) AS total_hypothetical_fare,
	(SELECT
    round(SUM(amount)*0.2,2)
	FROM payments WHERE status="success")  AS total_uber_revenue,
    (SELECT round(SUM(total_fare)*0.2,2) FROM trips) AS Hypothetical_uber_total,
    (Select round(avg(coun)) AS avg_bookings_per_day from (Select cast(requested_at as date) as days,count(trip_id) as coun from trips group by days)t) AS avg_bookings_per_day
FROM trips;


-- ============================================================================
#End of Script
-- ============================================================================
/*
===============================================================================
ANALYSIS SUMMARY: 
===============================================================================
1. The total revenue generated was $586k but the hypothetical total if all trips were completed and all payments were a success would be $720k.
	Uber's commission generally ranges from 20%-30%. So for this scenario, Only 20% is considered for all trips for consistency.
	A total of 16827 trips were successfully completed out of a total of 20000 trips.
    There are a total of 351 active drivers out of 400 drivers.
    There are 1571 riders who took a trip out of a grand total of 1600 riders registered.
2. The highest trips taken was by user 945 (Janet Hill found in section 4) at a total of 94 trips.
3. Most common locations are Flushing for pickup and Brooklyn Heights for drop.
	Most common city is New York with 5694 trips.
    Houston has the most cancellations with 830.
    Houston has the most failed trips with 1008.
    New York has the most successful trips with 4701.
    Houston charged the highest total fare with 224k$.
    LA has the highest average total fare with 44.2$
    LA has the highest average distance covered with 22.67km.
    New York has the highest fare per km average with 2.59$ per km.
    Chicago has the highest fare per minute average with 1.37$ per minute.
    Most common zone type is Residential with 7837 trips.
4. The average trip duration is 31 minutes,
	The average trip fare is 36$ and the average distance in kilometres is 18km.
    The lowest fare charged was 3.6$ and the highest fare was 224.2$.
    The lowest distance covered in a trip is 0.5km and the longest distance covered in a trip is 60km.
    The average surge multiplier is 1.26.
	The highest total revenue generated by a single customer (Linda Gonzalez) is 3380$ with a total of 87 trips taken.
    The average bookings per day is 22.
	The highest number of trips taken by a single customer is Janet Hill. This query also verifies if the total trips column correctly 
    calculated the total trips a customer has taken.
    Comfort SUVs are the most common at 95, followed by UberX Sedans at 91.
    The average surge multiplier is highest during the evenings at 1.51.
    The average surge multiplier is highest during Fridays at 1.48.
5. A summary containing the total trips, unique riders, unique drivers, unique locations, average trip duration, average trip fare, average distance covered, revenue generated and 
the total hypothetical fare was created successfully.

===============================================================================
*END OF SUMMARY*
===============================================================================
*/

    
	