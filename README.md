# Monetary-and-Financial-Analysis
Monetary and Customer Segmentation Analysis
## Some Insights
### 1- 1st Query : Highest Invoices Rank
```
select distinct customer_id, count(invoice) Invoices_Count, rank() over (order by count(invoice) desc) as rank
from tableretail
group by customer_id;
 ```
 ![image](https://user-images.githubusercontent.com/76915795/222925534-bcd9bf6d-c9fb-4509-b7d6-a4658e250743.png)

There are 110 customers purchasing from our store, we can see the ranking of our customers by their number of invoices. The no. 1 customer has made 4596 invoices while the least invoices made by a customer is 2 
### 2- 2nd Query : Highest Money Spent Rank
```
select distinct customer_id, sum(price*quantity) Money_Spent, rank() over (order by sum(price*quantity) desc) as MoneySpent_Rank
from tableretail
group by customer_id;
 ```
 ![image](https://user-images.githubusercontent.com/76915795/222925549-9aa5992e-6aaf-4ac2-9fc6-5cde2219046f.png)

Here is the ranking of our customers by their money spending. The top customer in spending money has spent nearly 42 K 
```
select distinct customer_id, count(invoice) Invoices_Count, rank() over (order by count(invoice) desc) as Invoice_Rank,
sum(price*quantity) Money_Spent, rank() over (order by sum(price*quantity) desc) as MoneySpent_Rank
from tableretail
group by customer_id;
```
By combining the 2 queries we could see there is a difference between customers if we ranked them by their no. of invoices they made, or their money spent.
 ![image](https://user-images.githubusercontent.com/76915795/222925554-0d861d2c-ebe1-4eb2-990d-b9f3f5bdccfa.png)

### 3- 3rd Query Top Items Revenue and Purchased
```
select distinct stockcode, sum(quantity) Quantity_Purchased,
rank() over (order by sum(quantity) desc) as Item_Quantity_Rank,
sum(price*quantity) Item_Revenue, rank() over (order by sum(price*quantity) desc) as Item_Revenue_Rank
from tableretail
group by stockcode
order by Item_Revenue_Rank;
```
![image](https://user-images.githubusercontent.com/76915795/222925562-8977767d-93a2-4c1a-b51b-fe4b585ccbc3.png)

 
The rankings of top items by their no. of times purchased and the revenue of each item.

### 4- 4th Query Invoices & Revenue Per Month
In 2011
```
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
 ```
![image](https://user-images.githubusercontent.com/76915795/222925569-342d1147-d489-476b-8f1c-edfc0bab3826.png)

In 2011 the highest month by number of invoices and revenue is November while the least month by invoices and revenue is January. 
In 2010 there is only one month recorded which is December has 1138 invoices and 13.4 K Revenue.


### 5- 5th Query Difference in Revenue between each month and the previous month
```
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
```
 ![image](https://user-images.githubusercontent.com/76915795/222925575-88b67735-8123-4e92-80ad-8e5a95c77b32.png)

This query shows for each month the total revenue and compares it with the last month’s revenue, the -ve value in revenue difference means that this month’s revenue dropped compared the last month

