/*
columns nedded for the analysis
CUSTOMER_ID
INVOICE
INVOICEDATE
PRICE,QUANTITY (sales)
*/
-- the following quey shows that the compination of customer ID and invoice 
--is repeated by the number of products in the invoice
/*
select 
        CUSTOMER_ID
        ,INVOICE
        ,INVOICEDATE
        ,count(INVOICE) over(partition by CUSTOMER_ID,INVOICE) count
 from retail 
 order by count desc
 */
 -- summarizing the data  
 with detail_retail as (  -- creating CTE with the requred columns & add (sales) column
    select  
        CUSTOMER_ID ,INVOICE
        ,to_char(to_date(INVOICEDATE,'MM/DD/YYYY HH24:mi'),'MM/DD/YYYY') as INVOICEDATE    -- get date column in required format
         , (QUANTITY*PRICE) as sales        -- get sales column
 from retail )
,sumr_retail as(    -- CTE  holding summarized data (remove any duplicate rows)  i.e one row for every customer and invoice
 select 
              CUSTOMER_ID ,INVOICE
        ,INVOICEDATE , sum(sales) as sales   -- calculate sales column
  from detail_retail 
  group by      CUSTOMER_ID ,INVOICE ,INVOICEDATE) -- grouping rows to remove duplicates 
  
  ,sumr_retail2 as ( --CTE to get most-recent-date , and last purchase date for each customer 
  select 
        CUSTOMER_ID, INVOICE , INVOICEDATE , sales
        , first_value(INVOICEDATE) -- most recent purchase date
                over(order by to_date(INVOICEDATE,'MM/DD/YYYY') desc ) last_purchase 
        , first_value(INVOICEDATE)  -- most recent purchase date for each customer
                over(partition by CUSTOMER_ID order by to_date(INVOICEDATE,'MM/DD/YYYY') desc ) cust_last_purchase 
   from sumr_retail
   order by CUSTOMER_ID)
  
   , retail_final as (  -- calculate recency , monetary and frequency 
   select distinct 
         CUSTOMER_ID
         --how far is the last purchase 
        , to_date(last_purchase ,'MM/DD/YYYY') - to_date(cust_last_purchase ,'MM/DD/YYYY') as  recency 
        -- number of orders for each customer
       , count(INVOICE) over(partition by CUSTOMER_ID order by CUSTOMER_ID  ) as frequency 
       ,sum(sales) over(partition by CUSTOMER_ID) as monetary     -- total sales for each customer 
   from sumr_retail2)
   
   ,final_data as ( -- allocating score based on RFM values 
   select  
        CUSTOMER_ID,recency,frequency,monetary
        ,ntile(5) over(order by recency desc) as r_score
        ,ntile(5) over(order by  ((frequency+monetary)/2))  fm_score
        
    from retail_final )
    
    select 
            CUSTOMER_ID,recency,frequency,monetary
            ,r_score,fm_score
            ,case  -- customer segment column based on r_score and fm_score
                    when r_score in (5,4) and fm_score in (5,4) then 'Champions'
                    when r_score in (5,4,3) and fm_score in (2,3) then 'Potential Loyalists'
                    when r_score in (5,4,3) and fm_score in (4,5,3) then ' Loyal Customers'
                    when r_score in (5) and fm_score in (1) then 'Recent Customers'
                    when r_score in (4,3) and fm_score in (1) then 'promising'
                    when r_score in (2,3) and fm_score in (2,3) then 'customers needing attention'
                    when r_score in (2,1) and fm_score in (5,3,4,1) then 'at risk'
                    when r_score in (1) and fm_score in (5,4) then 'can''t lose them'
                    when r_score in (1) and fm_score in (2) then 'hibernating'
                    when r_score in (1) and fm_score in (1) then 'lost'
             end as cust_segment
 from final_data;
  

 
