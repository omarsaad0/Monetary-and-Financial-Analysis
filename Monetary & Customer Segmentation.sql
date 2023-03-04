-- Omar Mohammed Ahmed Saad (Data Analysis - Smart Village) 
-- All queries discription are in the attached word file
------------ Question 1 5 Analytical SQL Queries ------------
----------------------------------------------------------------------
-- 1st Query : Highest Invoices Rank
select distinct customer_id, count(invoice) Invoices_Count, rank() over (order by count(invoice) desc) as rank
from tableretail
group by customer_id;
----------------------------------------------------------------------
-- 2nd Query : Highest Money Spent Rank
select distinct customer_id, sum(price*quantity) Money_Spent, rank() over (order by sum(price*quantity) desc) as MoneySpent_Rank
from tableretail
group by customer_id;

-- Combining Them Together
select distinct customer_id, count(invoice) Invoices_Count, rank() over (order by count(invoice) desc) as Invoice_Rank,
sum(price*quantity) Money_Spent, rank() over (order by sum(price*quantity) desc) as MoneySpent_Rank
from tableretail
group by customer_id;
----------------------------------------------------------------------
-- 3rd Query : Top Items Revenue and Purchased
select distinct stockcode, sum(quantity) Quantity_Purchased,
rank() over (order by sum(quantity) desc) as Item_Quantity_Rank,
sum(price*quantity) Item_Revenue, rank() over (order by sum(price*quantity) desc) as Item_Revenue_Rank
from tableretail
group by stockcode
order by Item_Revenue_Rank;
----------------------------------------------------------------------
--4th Query : No. of Invoices & Revenue Per Month 
--in 2011
select Month, "Invoices_Per_Month(2011)",  rank() over(order by "Invoices_Per_Month(2011)" desc) Month_Invoices_Rank,
"Revenue_Per_Month(2011)",
rank() over(order by "Revenue_Per_Month(2011)" desc) Month_Revenue_Rank
from
(
select distinct Extract(Month from to_date(invoicedate,'MM/DD/YYYY hh24-mi')) Month, 
count(invoice) over(partition by Extract(Month from to_date(invoicedate,'MM/DD/YYYY hh24-mi')) ) "Invoices_Per_Month(2011)",
sum(price*quantity) over(partition by Extract(Month from to_date(invoicedate,'MM/DD/YYYY hh24-mi')) ) "Revenue_Per_Month(2011)"
from tableretail
where Extract(Year from to_date(invoicedate,'MM/DD/YYYY hh24-mi')) =2011
);

-- in 2010
select Month, "Invoices_Per_Month(2011)",  rank() over(order by "Invoices_Per_Month(2011)" desc) Month_Invoices_Rank,
"Revenue_Per_Month(2011)",
rank() over(order by "Revenue_Per_Month(2011)" desc) Month_Revenue_Rank
from
(
select distinct Extract(Month from to_date(invoicedate,'MM/DD/YYYY hh24-mi')) Month, 
count(invoice) over(partition by Extract(Month from to_date(invoicedate,'MM/DD/YYYY hh24-mi')) ) "Invoices_Per_Month(2011)",
sum(price*quantity) over(partition by Extract(Month from to_date(invoicedate,'MM/DD/YYYY hh24-mi')) ) "Revenue_Per_Month(2011)"
from tableretail
where Extract(Year from to_date(invoicedate,'MM/DD/YYYY hh24-mi')) =2010
);
----------------------------------------------------------------------
--5th Query : Difference  in Revenue between each month and the previous month
select Month_, Total_Revenue,
    lag(Total_Revenue) over (order by  Month_) previous_month_revenue,
    Total_Revenue - lag(Total_Revenue) over (order by  Month_) revenue_difference
from 
(
select
    distinct extract(Month from to_date(invoicedate,'MM/DD/YYYY hh24-mi')) Month_,
    sum(quantity*price) Total_Revenue
from tableretail
group by extract(Month from to_date(invoicedate,'MM/DD/YYYY hh24-mi'))
);
----------------------------------------------------------------------
----------------------------------------------------------------------
-----------------Question 2 Monetary Model --------------------

select customer_id, recency, frequency, monetary, R_score,  round((F_score + M_score)/2,0) fm_score,
        case when R_score=5 and round((F_score + M_score)/2,0) = 5 or R_score = 4 and round((F_score + M_score)/2,0) = 5 or R_score = 5 and round((F_score + M_score)/2,0) = 4 then 'Champion'
               when R_score=1 and round((F_score + M_score)/2,0) = 1 then 'Lost'
               when R_score=1 and round((F_score + M_score)/2,0) = 2 then 'Hibernating'
               when R_score=1 and round((F_score + M_score)/2,0) = 4 or R_score=1 and round((F_score + M_score)/2,0) = 5 then 'Cant Lose Them'
               when R_score=2 and (round((F_score + M_score)/2,0) = 5 or round((F_score + M_score)/2,0) = 4 or round((F_score + M_score)/2,0) = 1) or R_score=1 and round((F_score + M_score)/2,0) =3   then 'At Risk' 
               when R_score=2 and (round((F_score + M_score)/2,0) = 2 or round((F_score + M_score)/2,0) = 3) or R_score=3 and round((F_score + M_score)/2,0) =2 then 'Customers Needing Attention'
               when (R_score=4 or R_score=3) and round((F_score + M_score)/2,0) = 1 then 'Promising'
               when R_score=5 and  round((F_score + M_score)/2,0) = 1 then 'Recent Customer'
               when R_score=3 and (round((F_score + M_score)/2,0) = 5 or round((F_score + M_score)/2,0) = 4) or R_score=4 and round((F_score + M_score)/2,0) = 4 or R_score=5 and round((F_score + M_score)/2,0) = 3 then 'Loyal Customers'
               when (R_score=5 or R_score=4) and round((F_score + M_score)/2,0) = 2 or (R_score=3 or R_score=4) and round((F_score + M_score)/2,0) = 3 then 'Potential Loyalists'
end cust_segment
from
(
select distinct t1.customer_id,
                round((select max(to_date(invoicedate,'MM/DD/YYYY hh24-mi')) from tableretail) - (select max(to_date(invoicedate,'MM/DD/YYYY hh24-mi')) from tableretail where customer_id = t1.customer_id),0) recency,
                count(t1.invoice) frequency,
                round(sum(t1.price*t1.quantity),0) monetary,
                ntile(5) over( order by round((select max(to_date(invoicedate,'MM/DD/YYYY hh24-mi')) from tableretail) - (select max(to_date(invoicedate,'MM/DD/YYYY hh24-mi')) from tableretail where customer_id = t1.customer_id),1) desc) as R_score,
                ntile(5) over( order by count(t1.invoice) asc) F_score,
                ntile(5) over( order by sum(t1.price*t1.quantity) asc) M_score
from tableretail t1
group by t1.customer_id
order by customer_id desc
)
group by customer_id, recency, frequency, monetary, R_score,F_score, M_score;

-- saving this query as a view 

create or replace view RFM as 
(
select customer_id, recency, frequency, monetary, R_score,  round((F_score + M_score)/2,0) fm_score,
        case when R_score=5 and round((F_score + M_score)/2,0) = 5 or R_score = 4 and round((F_score + M_score)/2,0) = 5 or R_score = 5 and round((F_score + M_score)/2,0) = 4 then 'Champion'
               when R_score=1 and round((F_score + M_score)/2,0) = 1 then 'Lost'
               when R_score=1 and round((F_score + M_score)/2,0) = 2 then 'Hibernating'
               when R_score=1 and round((F_score + M_score)/2,0) = 4 or R_score=1 and round((F_score + M_score)/2,0) = 5 then 'Cant Lose Them'
               when R_score=2 and (round((F_score + M_score)/2,0) = 5 or round((F_score + M_score)/2,0) = 4 or round((F_score + M_score)/2,0) = 1) or R_score=1 and round((F_score + M_score)/2,0) =3   then 'At Risk' 
               when R_score=2 and (round((F_score + M_score)/2,0) = 2 or round((F_score + M_score)/2,0) = 3) or R_score=3 and round((F_score + M_score)/2,0) =2 then 'Customers Needing Attention'
               when (R_score=4 or R_score=3) and round((F_score + M_score)/2,0) = 1 then 'Promising'
               when R_score=5 and  round((F_score + M_score)/2,0) = 1 then 'Recent Customer'
               when R_score=3 and (round((F_score + M_score)/2,0) = 5 or round((F_score + M_score)/2,0) = 4) or R_score=4 and round((F_score + M_score)/2,0) = 4 or R_score=5 and round((F_score + M_score)/2,0) = 3 then 'Loyal Customers'
               when (R_score=5 or R_score=4) and round((F_score + M_score)/2,0) = 2 or (R_score=3 or R_score=4) and round((F_score + M_score)/2,0) = 3 then 'Potential Loyalists'
end cust_segment
from
(
select distinct t1.customer_id,
                round((select max(to_date(invoicedate,'MM/DD/YYYY hh24-mi')) from tableretail) - (select max(to_date(invoicedate,'MM/DD/YYYY hh24-mi')) from tableretail where customer_id = t1.customer_id),0) recency,
                count(t1.invoice) frequency,
                round(sum(t1.price*t1.quantity),0) monetary,
                ntile(5) over( order by round((select max(to_date(invoicedate,'MM/DD/YYYY hh24-mi')) from tableretail) - (select max(to_date(invoicedate,'MM/DD/YYYY hh24-mi')) from tableretail where customer_id = t1.customer_id),1) desc) as R_score,
                ntile(5) over( order by count(t1.invoice) asc) F_score,
                ntile(5) over( order by sum(t1.price*t1.quantity) asc) M_score
from tableretail t1
group by t1.customer_id
order by customer_id desc
)
group by customer_id, recency, frequency, monetary, R_score,F_score, M_score
);

-- Count of each segment 
select cust_segment, count(cust_segment) "No. of Customers" from RFM
group by cust_segment
order by "No. of Customers" desc;

-- More Interpertation 
select category, count(category) Category_Count from
(
select 
case when cust_segment in ('Champion', 'Loyal Customers', 'Potential Loyalists') then 'Top_Customers'
       when cust_segment in ('Lost', 'Hibernating', 'Cant Lose Them', 'At Risk') then 'Potential_Losing'
       else 'Neutral'
        end Category
        from RFM
)
group by category
order by Category_Count desc;

-- View created to see the top item purchased for each customer 
create or replace view topItemPerCust as
select customer_id, stockcode, max_quantity
from (
select customer_id, stockcode, count(stockcode)*max(quantity) as max_quantity, 
         rank() over (partition by customer_id order by count(stockcode)*max(quantity) desc, stockcode asc) as rnk
from tableretail
group by customer_id, stockcode
) t
where rnk = 1 
order by customer_id;

-- finding customers whose are potential losing with their most purchased item
select rfm.customer_id, rfm.cust_segment, rfm.R_score, top.stockcode TopItemPurchased, top.max_quantity quantity
from RFM , topitempercust top
where rfm.customer_id = top.customer_id and 
          rfm.cust_segment in ('Lost', 'Hibernating', 'Cant Lose Them', 'At Risk');
