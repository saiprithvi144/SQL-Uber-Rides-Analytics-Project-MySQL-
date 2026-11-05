/*
===============================================================================
Script:         9_data_segmentation_analysis.sql
Project:        SQL Uber Rides Analytics Project (MySQL)
Author:         Sai Prithvi Sudhakar
Database:       uberridesanalyticsdatabase

Description:
    - To group data into meaningful categories for targeted insights.
    - For customer segmentation, driver categorization, or regional analysis.
    
Objectives:
    1. Group customers into each segment based on their total spending.
    2. Group drivers into each segment based on their total revenue generated.
    3. Group zones into each segment based on their frequency.
===============================================================================
*/

USE uberridesanalyticsdatabase;

-- ============================================================================
#1: Group customers into each segment based on their total spending. (VIP,Regular & New)
-- ============================================================================

with base as(
SELECT t.rider_id,u.name,count(t.trip_id) as total_trips,
round(SUM(p.amount),2) AS total_amount, round(SUM(p.amount)*0.2,2) AS total_uber_amount
FROM trips t
LEFT JOIN payments p ON p.trip_id=t.trip_id
LEFT JOIN riders r ON r.rider_id=t.rider_id
LEFT JOIN users u ON u.user_id=r.user_id
WHERE p.status="success"
GROUP BY t.rider_id
ORDER BY total_amount DESC
)
SELECT b.*,
CASE WHEN b.total_trips>=30 AND b.total_amount>=2000 THEN "VIP"
WHEN b.total_trips>=30 AND b.total_amount>=1000 THEN "Regular"
ELSE "New"
END AS RIDER_TAG
FROM base b;
-- ============================================================================
#2: Group drivers into each segment based on their total revenue generated. (Good,Medium & Underperformer)
-- ============================================================================

with base as(
SELECT d.driver_id,u.user_id,u.name,count(t.trip_id) as total_trips,
round(SUM(p.amount),2) AS total_amount, round(SUM(p.amount)*0.2,2) AS total_uber_amount 
FROM drivers d
LEFT JOIN trips t ON d.driver_id=t.driver_id
LEFT JOIN payments p ON p.trip_id=t.trip_id
LEFT JOIN users u ON u.user_id=d.user_id
WHERE p.status="success"
GROUP BY d.driver_id
ORDER BY total_amount DESC
)
SELECT b.*,d.rating, round(avg(r.rating),2) AS average_rating_received,
CASE WHEN b.total_amount>=2000 THEN "Good"
WHEN b.total_amount>=1000 THEN "Medium"
ELSE "Underperformer"
END AS DRIVER_TAG
FROM base b
LEFT JOIN reviews r ON b.user_id=r.reviewee_id
LEFT JOIN drivers d ON b.driver_id=d.driver_id
GROUP BY b.driver_id,b.user_id,b.name,b.total_trips,b.total_amount,d.rating;

-- ============================================================================
#3: Group zones into each segment based on their frequency. (Hotspot, Moderate and Normal)
-- ============================================================================

with pickup as(
SELECT t.pickup_location_id,l.zone_name,count(trip_id) AS frequency FROM trips t
LEFT JOIN locations l ON l.location_id=t.pickup_location_id
GROUP BY t.pickup_location_id,l.zone_name
ORDER BY frequency DESC),
dropoff as(
SELECT t.dropoff_location_id,l.zone_name,count(trip_id) AS frequency FROM trips t
LEFT JOIN locations l ON l.location_id=t.dropoff_location_id
GROUP BY t.dropoff_location_id,l.zone_name
ORDER BY frequency DESC)
SELECT p.pickup_location_Id AS location_id,p.zone_name, p.frequency+d.frequency AS location_frequency,
CASE WHEN p.frequency+d.frequency>=1100 THEN "Hotspot"
WHEN p.frequency+d.frequency>=900 THEN "Moderate"
WHEN p.frequency+d.frequency>=600 THEN "Normal"
ELSE "Rare"
END AS LOCATION_TAG
FROM pickup p
JOIN dropoff d on p.pickup_location_id=d.dropoff_location_id
ORDER BY location_frequency DESC

-- ============================================================================
#End of Script
-- ============================================================================

/*
===============================================================================
ANALYSIS SUMMARY: 
===============================================================================

    1. After segmenting the data based on trip count and revenue generated, We can observe that there are many more "New" riders compared to regular and VIPs.
    2. After segmenting the data based on revenue generated, There were a lot fewer underperformers than Good or Medium drivers.
    3. After segmenting the data based on location count, All zones are relatively closer to each other in the total count with 20 zones having over 1000 frequency.

===============================================================================
*END OF SUMMARY*
===============================================================================
*/