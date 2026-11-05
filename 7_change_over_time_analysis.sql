/*
===============================================================================
Script:         7_change_over_time_analysis.sql
Project:        SQL Uber Rides Analytics Project (MySQL)
Author:         Sai Prithvi Sudhakar
Database:       uberridesanalyticsdatabase

Description:
    Analyze revenue performance over time to identify business trends,
    customer growth, and seasonality using MySQL date functions.

Objectives:
    1. Analyze yearly revenue performance.
    2. Analyze monthly trends.
    3. Track Monthly growth percentage.
    4. Calculate the monthly running total.
    5. Analyze trends by Quarter.
    6. Analyze quarterly revenue performance each year.
    7. Track the rolling total between each quarter per year.
    8. Cumulative revenue percentage.
    
===============================================================================
*/

USE uberridesanalyticsdatabase;

-- ============================================================================
#1: Analyze yearly revenue performance
-- ============================================================================

SELECT YEAR(t.completed_at) AS yr,count(t.trip_id) AS total_trips,
round(sum(p.amount),2) AS total_revenue, round(sum(p.amount)*0.2,2) AS total_uber_revenue
FROM trips t
LEFT JOIN payments p ON p.trip_id=t.trip_id
WHERE p.status="success"
GROUP BY yr
ORDER BY total_revenue DESC;

-- ============================================================================
#2: Analyze monthly trends (along with year split)
-- ============================================================================

SELECT MONTH(t.completed_at) AS mon,count(t.trip_id) AS total_trips,
round(sum(p.amount),2) AS total_revenue, round(sum(p.amount)*0.2,2) AS total_uber_revenue 
FROM trips t
LEFT JOIN payments p ON p.trip_id=t.trip_id
WHERE p.status="success"
GROUP BY mon
ORDER BY total_revenue DESC;

#Split by Year
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
round(SUM(p.amount),2) AS total,
round(sum(p.amount)*0.2,2) AS total_uber_revenue
FROM trips t
LEFT JOIN payments p ON p.trip_id=t.trip_id
WHERE p.status="success"
GROUP BY mon
ORDER BY total DESC;

-- ============================================================================
#3: Track monthly growth percentage
-- ============================================================================
with base as(
SELECT date_format(t.completed_at,"%Y-%m") AS yrmon,
round(sum(p.amount),2) AS total_revenue,
round(sum(p.amount)*0.2,2) AS total_uber_revenue
FROM trips t
LEFT JOIN payments p ON p.trip_id=t.trip_id
WHERE p.status="success"
GROUP BY yrmon
ORDER BY yrmon)
SELECT b.*,
LAG(yrmon) OVER(ORDER BY yrmon) as prev_yrmon,
LAG(total_revenue) OVER(ORDER BY yrmon) as prev_yrmon_revenue,
round((total_revenue-LAG(total_revenue) OVER(ORDER BY yrmon)),2) as mom_change,
LAG(total_uber_revenue) OVER(ORDER BY yrmon) as prev_uber_yrmon_revenue,
round((total_uber_revenue-LAG(total_uber_revenue) OVER(ORDER BY yrmon)),2) as uber_mom_change,
round((((total_revenue-LAG(total_revenue) OVER(ORDER BY yrmon))/(LAG(total_revenue) OVER(ORDER BY yrmon)))*100),2) as mom_change_pct
FROM base b;

-- ============================================================================
#4: Calculate the monthly running total
-- ============================================================================

with base as
(SELECT date_format(t.completed_at,"%Y-%m") AS yrmon,
count(t.trip_id) AS trips,
round(sum(p.amount),2) AS total_revenue,
round(sum(p.amount)*0.2,2) AS total_uber_revenue
FROM trips t
LEFT JOIN payments p ON p.trip_id=t.trip_id
WHERE p.status="success"
GROUP BY yrmon
ORDER BY yrmon)
SELECT b.*,
SUM(trips) OVER (ORDER BY yrmon) as trips_count_total,
round((SUM(total_revenue) OVER (ORDER BY yrmon)),2) as running_total,
round((SUM(total_uber_revenue) OVER (ORDER BY yrmon)),2) as uber_running_total,
round(((round((SUM(total_revenue) OVER (ORDER BY yrmon)),2))/(SUM(total_revenue) OVER())*100),2) as cumulative_pct
from base b;


-- ============================================================================
#5: Analyze trends by Quarter
-- ============================================================================

SELECT concat("Q",QUARTER(t.completed_at)) AS quarter,
round(SUM(p.amount),2) as total_revenue, 
round(SUM(p.amount)*0.2,2) as total_uber_revenue
FROM trips t
LEFT JOIN payments p on t.trip_id=p.trip_id
WHERE p.status="success"
GROUP BY quarter
ORDER BY total_revenue DESC;

-- ============================================================================
#6: Analyze quarterly revenue performance each year
-- ============================================================================
with base as(
SELECT date_format(t.completed_at,"%Y-%m") AS yrmon,
round(sum(p.amount),2) AS total_revenue,
concat("Q",QUARTER(t.completed_at)) AS quarter
FROM trips t
LEFT JOIN payments p ON p.trip_id=t.trip_id
WHERE p.status="success"
GROUP BY yrmon,quarter
ORDER BY yrmon
)
 SELECT LEFT(b.yrmon,4) AS year,b.quarter,
 round(sum(total_revenue),2) AS quarterly_revenue,
 round(sum(total_revenue)*0.2,2) AS uber_quarterly_revenue
 FROM base b
 GROUP BY year,b.quarter
 ORDER BY year ASC, quarterly_revenue DESC;
 
-- ============================================================================
#7: Track the rolling total between each quarter per year
-- ============================================================================

with base as(
SELECT date_format(t.completed_at,"%Y") AS yr,
concat("Q",QUARTER(t.completed_at)) AS quarter,
round(sum(p.amount),2) AS quarterly_revenue,
round(sum(p.amount)*0.2,2) AS uber_quarterly_revenue
FROM trips t
LEFT JOIN payments p ON p.trip_id=t.trip_id
WHERE p.status="success"
GROUP BY yr,quarter
ORDER BY yr),
base2 as(
SELECT b.*,
round((SUM(b.quarterly_revenue) OVER (partition by b.yr ORDER BY b.yr,b.quarter ROWS BETWEEN 3 PRECEDING AND CURRENT ROW)),2) AS yearly_rolling_total_by_quarter,
round((SUM(b.uber_quarterly_revenue) OVER (partition by b.yr ORDER BY b.yr,b.quarter ROWS BETWEEN 3 PRECEDING AND CURRENT ROW)),2) AS uber_yearly_rolling_total_by_quarter,
SUM(b.quarterly_revenue) OVER (partition by b.yr) as total_per_year,
SUM(b.uber_quarterly_revenue) OVER (partition by b.yr) as uber_total_per_year
FROM base b)
Select b2.yr,b2.quarter,b2.quarterly_revenue,b2.uber_quarterly_revenue,b2.yearly_rolling_total_by_quarter,b2.uber_yearly_rolling_total_by_quarter,
round(((b2.yearly_rolling_total_by_quarter)/(b2.total_per_year)*100),2) AS cumulative_pct_per_year 
FROM base2 b2;

-- ============================================================================
#8: Track Cumulative Revenue Percentage
-- ============================================================================

with base as
(SELECT date_format(t.completed_at,"%Y-%m") AS yrmon,
round(sum(p.amount),2) AS total_revenue,
round(sum(p.amount)*0.2,2) AS total_uber_revenue
FROM trips t
LEFT JOIN payments p ON p.trip_id=t.trip_id
WHERE p.status="success"
GROUP BY yrmon
ORDER BY yrmon)
SELECT b.*,round((SUM(total_revenue) OVER(ORDER BY yrmon)),2) AS cumulative_total,
b.*,round((SUM(total_uber_revenue) OVER(ORDER BY yrmon)),2) AS uber_cumulative_total,
round((round((SUM(total_revenue) OVER(ORDER BY yrmon)),2)/(SUM(total_revenue) OVER())*100),2) AS cumulative_pct
FROM base b

-- ============================================================================
#End of Script
-- ============================================================================
/*
===============================================================================
ANALYSIS SUMMARY: 
===============================================================================

    1. 2023 was the most successful year narrowly beating 2022 by $2.4k and 492 more trips. 2024 only has data for the first half of the year therefore showing almost half the values
    of the other two.
    2. March, January and June generated the highest revenue and had the most trips, 
    however these values are skewed for the first 6 months of the year as 2024 only has the first half of the year as data.
    3. Auguest of 2022 had the most profitable change over a month with an increase of 14% in revenue from the previous month.
    November of 2022 had the worst change over a month with a decrease of 20% in revenue from the previous month.
    4. The cumulative percentage of revenue is increasing consistently by month.
    5. Q1 and Q2 have their values skewed because of the same reason of 2024 having only half of the yearly data.
    6. 2022 had the most revenue during Q2, 2023 had the most revenue during Q1,narrowly beating Q4, 2024 had the most revenue during Q1
    7. The cumulative percentage is increasing consistently per quarter since the monthly increase in percentage was also consistent.
    8. The cumulative percentage is increasing consistently overtime.

===============================================================================
*END OF SUMMARY*
===============================================================================
*/