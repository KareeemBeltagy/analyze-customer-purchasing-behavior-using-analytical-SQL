
with detail as ( -- using CTE and calculate running total and number of days/transaction req.for later calculation
select CUST_ID
    ,count(CALENDAR_DT) over(partition by CUST_ID order by CALENDAR_DT rows between unbounded preceding and current row ) as days
    ,sum(AMT_LE) over(partition by CUST_ID order by CALENDAR_DT rows between unbounded preceding and current row) as running_amt
    from customer)
    -- getting average of days that reach the threshold of 250
    select  avg(days) as average_days
    from detail
    where running_amt >= 250;