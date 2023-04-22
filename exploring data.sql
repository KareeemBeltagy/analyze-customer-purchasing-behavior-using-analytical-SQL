-- get nuber of rows
select count(*) from retail;

--  count number of orders
select count(INVOICE) from retail;
-- count distinct number of orders
select  count(distinct INVOICE)  from retail ;
-- count the occurence of orders and ,products  andcustomer id 
select  count(*) 
from (select  INVOICE, STOCKCODE,CUSTOMER_ID from retail group by   INVOICE, STOCKCODE,CUSTOMER_ID)  ;

-- using CTE to query last and first of invoice evermade 
with invoicedate as ( select  
            first_value(INVOICEDATE)
                over(order by to_date(INVOICEDATE,'MM/DD/YYYY HH24:mi')) first_purchase
           ,first_value(INVOICEDATE)
                over(order by to_date(INVOICEDATE,'MM/DD/YYYY HH24:mi') desc ) last_purchase                    
from retail)
-- query firist and last date and calculate the time sapn of the data provided
select first_purchase, last_purchase, 
 to_date( to_char(to_date(last_purchase,'MM/DD/YYYY HH24:mi'),'MM/DD/YYYY') ,'MM/DD/YYYY')
 -to_date( to_char(to_date(first_purchase,'MM/DD/YYYY HH24:mi'),'MM/DD/YYYY') ,'MM/DD/YYYY')as span
from invoicedate
group by first_purchase, last_purchase;


with product as(
select count(1) as product from retail group by STOCKCODE)
select count(product) as "count of products" 
from product ;



select STOCKCODE,sum(STOCKCODE) from retail group by STOCKCODE

-- ranking the most ordered product
select 
        STOCKCODE,sum(QUANTITY) quantity , rank()over(order by sum(QUANTITY) desc) as rank
from retail
group by STOCKCODE

-- ranking month based on number of roders
select 
        to_char(to_date(INVOICEDATE,'MM/DD/YYYY HH24:mi'),'MM/YYYY') order_date
        , count(INVOICE)  "number_of_orders"
        , rank() over(order by count(INVOICE) desc) as "Top_demand_month"
 from retail 
 group by to_char(to_date(INVOICEDATE,'MM/DD/YYYY HH24:mi'),'MM/YYYY')



-- ranking month based of revenue each month
SELECT
  TO_CHAR(TO_DATE(INVOICEDATE, 'MM/DD/YYYY HH24:MI'), 'MM/YYYY') AS order_date,
  SUM(quantity * price) AS total_revenue,
  RANK() OVER (ORDER BY SUM(quantity * price) DESC) AS top_revenue_month
FROM retail
GROUP BY TO_CHAR(TO_DATE(INVOICEDATE, 'MM/DD/YYYY HH24:MI'), 'MM/YYYY');
 
-- ranking top customers based on number of orders 
select 
    CUSTOMER_ID 
    , count(INVOICE) number_of_orders
    ,rank() over( order by count(INVOICE) desc ) top_customer
    from retail 
    group by CUSTOMER_ID


SELECT *
FROM retail
WHERE ROWNUM <= 5;




