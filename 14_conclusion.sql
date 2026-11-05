/*
===============================================================================
Script:         14_conclusion.sql
Project:        SQL Uber Rides Analytics Project (MySQL)
Author:         Sai Prithvi Sudhakar
Database:       uberridesanalyticsdatabase

Description:
	Lists down all the final insights and takeaways to keep in mind when considering
    future business decisions.

===============================================================================

CONCLUSION SUMMARY:

===============================================================================
# The primary concerns from this analysis would be to look into:
===============================================================================

-why the reviews have a mismatch in rating.

-understand the discrepancy between user account creation dates in the users table and date joined in their respective base tables 

-Investigated why trips have duration still mentioned in the column despite not having a completion time or status not set as completed. 
This is because the trip distance and completion time are the estimated figures by the app itself that are being established into the database 
rather than the actual accurate values themselves.

-The trips still marked “in_progress” also need to be looked into. 

===============================================================================
#The final takeaways from this analysis should be:
===============================================================================

-The cumulative revenue streamline is consistent with no major losses or profits despite having high month over month change percentages in some cases. 

-The drivers need to be informed to avoid accepting trip requests that are too far away to reduce potential cancellations due to long wait times. (10 min+)

-All the payments that “failed” need to be thoroughly investigated. 
Whether this was a database entry issue or if there really were 325 payments that did not take place. 
(Probably a customer could not pay and gave another form of collateral,  or maybe a malicious transaction took place where the driver took the money for themselves.)

-An investigation needs to be done on why the "wrong pickup" and "system error" count is so high.
(Perhaps an OTP system needs to be updated or location tracking needs to be improved.)

-Both Drivers and Riders need to get more incentives to conduct/book trips in LA.
With the total trip count in LA being the lowest and total unique driver count in LA also being low (Between 76 to 78 per zone in LA), 
It has much more potential to generate more revenue with the average base fare and the average distance covered for the city being the highest.

 -Overall bookings peak at 8AM-11AM,2PM-3PM and 6PM-2AM. These are the peak hours that should be prioritized especially the morning and evening-night hours with more driver availability.

-Similarly, It is better to have more drivers working during Wednesdays, Fridays and Tuesdays as the highest number of trips have taken place during these time periods.

-The average distance and base fare for each city plays a vital role in the total revenue generated more than the total trips conducted there
 (Example: Houston generating more revenue due to almost double the average distance covered to New York even though New York has more demand for trips). 



Future business decisions should be taken keeping these in mind. 

===============================================================================
END OF SUMMARY
===============================================================================
*/