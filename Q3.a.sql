


-- CTE  that calculates the row number for each customer's calendar dates
WITH consecutive_dates AS (
  SELECT cust_id, CALENDAR_DT, ROW_NUMBER() OVER (PARTITION BY cust_id ORDER BY CALENDAR_DT) AS rn
  FROM customer
), 
consecutive_days (cust_id, CALENDAR_DT, rn, days) AS (
  -- Select the first row for each customer, setting the number of consecutive days to 1
  SELECT cust_id, CALENDAR_DT, rn, 1 AS days
  FROM consecutive_dates
  WHERE rn = 1
  UNION ALL
  -- For subsequent rows, compare the current row's calendar date to the previous one to determine if the dates are consecutive
  SELECT cd.cust_id, cd.CALENDAR_DT, cd.rn, 
    CASE 
      WHEN cd.CALENDAR_DT = cd2.CALENDAR_DT + 1 THEN cd2.days + 1 -- If the dates are consecutive, set the number of consecutive days to the previous row's number of consecutive days plus 1
      ELSE 1 -- else, reset the number of consecutive days to 1, indicating the start of a new range of consecutive days
    END
  FROM consecutive_dates cd
  INNER JOIN consecutive_days cd2 ON cd.cust_id = cd2.cust_id AND cd.rn = cd2.rn + 1 -- Join the current row to the previous row based on the customer ID and the row number
)
-- Select the customer ID and the maximum number of consecutive days for each customer
SELECT cust_id, MAX(days) AS max_consecutive_days
FROM consecutive_days
GROUP BY cust_id;


