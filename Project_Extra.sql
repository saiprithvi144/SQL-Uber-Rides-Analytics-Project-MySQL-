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


SELECT MONTH(t.completed_at) AS mon,

round(SUM(CASE WHEN YEAR(t.completed_at)="2022" THEN p.amount
ELSE 0
END),2) AS "2022",

round(SUM(
CASE WHEN YEAR(t.completed_at)="2023" THEN p.amount
ELSE 0
END),2) AS "2023",

round(SUM(CASE WHEN YEAR(t.completed_at)="2024" THEN p.amount
ELSE 0
END),2) AS "2024",
round(SUM(p.amount),2) AS total
FROM trips t
LEFT JOIN payments p ON p.trip_id=t.trip_id
WHERE p.status="success"
GROUP BY mon
ORDER BY total DESC;

Select date_format(requested_at,"%H") AS Hours, count(trip_id) AS trip_bookings FROM trips
GROUP BY Hours
ORDER BY trip_bookings DESC;

Select date_format(requested_at,"%a") AS Day_of_week, count(trip_id) AS trip_bookings FROM trips
GROUP BY Day_of_week
ORDER BY trip_bookings DESC;
