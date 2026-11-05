/*
===============================================================================
Script:         12_report_driver.sql
Project:        SQL Uber Rides Analytics Project (MySQL)
Author:         Sai Prithvi Sudhakar
Database:       uberridesanalyticsdatabase

Description:
	Creates a driver analytics report that compiles driver
    demographics and key performance indicators.

Highlights:
    -Driver and their vehicle information.
    -First and Last trip
    -Total successful trips
    -Total failed trips (cancelled, refunded or payment failed)
    -Total revenue generated
    -Average review rating given
    -Driver segmentation
    
===============================================================================
*/

USE uberridesanalyticsdatabase;
-- ============================================================================
-- Drop Existing View
-- ============================================================================

DROP VIEW IF EXISTS report_driver;

-- ============================================================================
-- Create Customer Report View
-- ============================================================================

CREATE VIEW report_driver AS
(

with base as(
SELECT d.driver_id,u.name,u.city,d.rating,u.date_joined AS registered_at,d.is_active FROM drivers d
LEFT JOIN users u ON d.user_id=u.user_id
),
base_trip as(
SELECT d.driver_id,
min(cast(t.requested_at AS date)) AS first_trip,
max(cast(t.requested_at AS date)) AS last_trip,
count(t.trip_id) AS total_successful_trips,
round(SUM(p.amount),2) AS total_revenue,
round(SUM(p.amount)*0.2,2) AS total_uber_revenue
FROM drivers d
LEFT JOIN trips t ON d.driver_id=t.driver_id
LEFT JOIN payments p ON p.trip_id=t.trip_id
WHERE p.status="success"
GROUP BY d.driver_id
ORDER BY total_revenue DESC),
base_fail as(
SELECT d.driver_id,
count(t.trip_id) AS total_trips
FROM drivers d
LEFT JOIN trips t ON d.driver_id=t.driver_id
GROUP BY d.driver_id
ORDER BY total_trips DESC),
base_review_g as(
SELECT d.driver_id,d.user_id,
COUNT(re.review_id) AS review_count,
round(avg(re.rating),2) AS avg_review_rating_given 
FROM drivers d
LEFT JOIN reviews re ON d.user_id=re.reviewer_id 
GROUP BY d.driver_id,d.user_id
ORDER BY d.driver_id),
base_review_r as(
SELECT d.driver_id,d.user_id,
COUNT(re.review_id) AS review_count,
round(avg(re.rating),2) AS avg_rating_received 
FROM drivers d
LEFT JOIN reviews re ON d.user_id=re.reviewee_id 
GROUP BY d.driver_id,d.user_id
ORDER BY d.driver_id),
base_distance as(
SELECT d.driver_id,round(avg(t.distance_km),2) AS avg_distance_covered FROM drivers d
LEFT JOIN trips t ON t.driver_id=d.driver_id
GROUP BY d.driver_id
),
base_vehicle as(
SELECT d.*,v.vehicle_type,v.vehicle_cost,v.uber_category from drivers d
LEFT JOIN vehicles v ON d.vehicle_make=v.vehicle_make AND d.vehicle_model=v.vehicle_model AND d.vehicle_year=v.vehicle_year
ORDER BY d.vehicle_make
)

SELECT 
-- ==========================================================
#Basic driver information and vehicle category
-- ==========================================================

b.*,v.uber_category AS car_category,

-- ==========================================================
#Trip related information and total revenue
-- ==========================================================

f.total_trips,
t.first_trip,t.last_trip,t.total_successful_trips, 
f.total_trips-t.total_successful_trips AS total_failed_trips,
di.avg_distance_covered,
t.total_revenue,t.total_uber_revenue,

-- ==========================================================
#Review information and customer segmentation
-- ==========================================================
g.review_count,g.avg_review_rating_given,r.avg_rating_received,
CASE WHEN t.total_successful_trips>=30 AND t.total_revenue>=2000 THEN "Good"
WHEN t.total_revenue>=1000 THEN "Regular"
ELSE "Underperformer"
END AS Driver_Tag
FROM base b
LEFT JOIN base_trip t ON b.driver_id=t.driver_id
LEFT JOIN base_fail f ON b.driver_id=f.driver_id
LEFT JOIN base_review_g g ON b.driver_id=g.driver_id
LEFT JOIN base_review_r r ON b.driver_id=r.driver_id
LEFT JOIN base_distance di ON b.driver_id=di.driver_id
LEFT JOIN base_vehicle v ON b.driver_id=v.driver_id
ORDER BY t.total_revenue DESC
)

-- ============================================================================
#End of Script
-- ============================================================================

/*
===============================================================================
ANALYSIS SUMMARY: 
===============================================================================
	1. After analyzing the report, There was a huge mismatch discovered between the rating mentioned in the base driver table and the calculated average rating they received.
    2.The highest total trips conducted by a single driver was 90 by two drivers,  #234 George Gray and #208 Shirley Harris. Lowest being 0 as there are many drivers who 
    have not yet conducted a trip.
    3.The highest revenue generated by a single driver was 3.60k$ by #10 Andrew Morales and lowest being 0 for many drivers for the same reason above.
    The highest average distance covered by a single driver was 29.21km by #241 Nancy Price and lowest being 0 for drivers with no trips.
    4.The amount of trips that failed by either cancellations,refunds or payment failures the most for a single driver was 22 out of 78 trips for #298 Donna Morales (even though they are 
    tagged as a Regular and generated around 1.4k$, even with an average review rating of 4.49) and lowest being null for many drivers with no trips recorded at all.
	5. The highest review count is 28 out of 84 trips by #240 Carol Perez who gave an average rating of 3.11 and the lowest review count is 0.
    Highest average review rating received is 4.63 for #178 Patricia Bailey and Lowest average review rating received aside from null is 2.65 for #233 Richard Cooper.
    Highest average review rating given is 4.00 by #16 Jacob Jackson and lowest average review rating given aside from null is 2.70 by #191 Joshua Sanchez. 
	6. There are three tags for drivers:
    Good for drivers with more than 30 trips and generated a total of 2000$+ in revenue,
    Regular for drivers who generated a total of 1000$+ in revenue,
    New for customers who do not meet those conditions.
    
===============================================================================
*END OF SUMMARY*
===============================================================================
*/