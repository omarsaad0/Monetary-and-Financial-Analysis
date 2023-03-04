# RFM Analysis for Customer Segmentation
Monetary and Customer Segmentation Analysis
In this case study using the OnlineRetail dataset, I explored the dataset and summarized the dataset using different analytical SQL these summarization are:
*	Highest Invoices Rank
*	Highest Money Spent Rank
*	Top Items Revenue and Purchased
*	No. of Invoices & Revenue Per Month
*	Difference in Revenue between each month and the previous month

Then an RFM model is created to understand customer behavior to improve customer retention and decrease churn.

The model is based on the scores of Recency, Frequency and Monetary then label each customer based on his score. 
With our dataset I tried to give a suggestion on how to avoid of churn of some customers and improve their retention by getting each customer highest purchasable item then I can give the potentially losing customers a promotion. Also, a reward to our most loyal customers with a promotion of a discount. 

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

## Monetary Model & Customer Segmentation
The code block can be found in the .sql script

![image](https://user-images.githubusercontent.com/76915795/222925719-3aeb2526-7a18-4c13-9ffa-73af7a9ddf05.png)

For the 110 customers in the dataset.
*	Recency : The difference between the most recent invoice date and the recent invoice date for each customer 
*	Frequency : The count of invoices for each customer
*	Monetary : Total payment the customer made 
*	R_Score : NTILE(5), grouping the recency by 5 groups 1,2,3,4,5
*	FM_Score : Average of NTILE(5) for each F_Score and M_Score NTILE(5), grouping the average by 5 groups 1,2,3,4,5
*	Cust_Segment : Based on the given table each customer is labeled with the calculated segment

We can save this query as a view and execute this query
```
select cust_segment, count(cust_segment) "No. of Customers" from RFM
group by cust_segment
order by "No. of Customers" desc;
```
![image](https://user-images.githubusercontent.com/76915795/222925843-5bd6e4bb-3231-46db-be84-caedc818bab4.png)

 
we can see the distribution of the customers in each segment. The dataset shows 23 customers are champions which means they have high recency score and high purchasing with volume score. 
Also, to get a better interpretation we can group some labels together as shown below 
```
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
 ```
![image](https://user-images.githubusercontent.com/76915795/222925840-efafa8c3-ad6e-4d06-a3be-85fa9212b3ff.png)


We can see that half of the customers are top customers but around a third of the customers have the potential to lose them, so I suggest to the store to deal with those customers. 

## Recommendations
If we investigate more into this category we can see that they were buying with high amount and they paid high amounts, but heir recency score is too low, so we can try to reach them by an SMS or a phone call and give them a promotion or a discount on selected items. 
```
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
```

In this query we can get the highest purchased item per each customer 

 ![image](https://user-images.githubusercontent.com/76915795/222925858-cd1cfd2b-a681-4446-904a-bad912549d5f.png)

So, we can join with the RFM model to get the stock codes of the customers that are potentially losing and we can do a promotion on these items.
```
select rfm.customer_id, rfm.cust_segment, rfm.R_score, top.stockcode TopItemPurchased, top.max_quantity quantity
from RFM , topitempercust top
where rfm.customer_id = top.customer_id and 
          rfm.cust_segment in ('Lost', 'Hibernating', 'Cant Lose Them', 'At Risk');
 ```
 ![image](https://user-images.githubusercontent.com/76915795/222925867-235c08a6-648e-4f8d-8968-1bdb7f2eaced.png)

Now we have the most purchased item for the customers who are potentially lost. And we can give these customers a promotion on their most purchasable item. 
Also, we can investigate more on these items there might be out of stock and that’s why these customers stopped buying from the store or its quality gone bad or the competitor has higher deal for them.



