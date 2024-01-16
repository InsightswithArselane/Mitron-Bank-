select *
from dbo.Customers

select *
from dbo.Spends


-- to verify if the dataset has really 4000 different customers.
select COUNT(DISTINCT customer_id)
from dbo.Customers

-- get info on how much customers in each group age
select count(customer_id) as Customers_per_age , age_group 

from dbo.Customers

group by age_group

order by Customers_per_age DESC


-- per gender

select count(customer_id) as Customers_per_gender , gender

from dbo.Customers

group by gender

order by Customers_per_gender DESC

-- per occupation
select count(customer_id) as Customers_per_occupation , occupation

from dbo.Customers

group by occupation

order by Customers_per_occupation DESC


-- per marital status
select count(customer_id) as Customers_per_marital_status , [marital status]

from dbo.Customers

group by  [marital status]

order by Customers_per_marital_status DESC


-- per avg_income (useless data)
select count(customer_id) as Customers_per_avg_income , avg_income

from dbo.Customers

group by  avg_income

order by Customers_per_avg_income DESC

-- per city

select count(customer_id) as Customers_per_city , city

from dbo.Customers

group by  city

order by Customers_per_city DESC


--  try 

 
SELECT
	city,
	age_group,
	Count(customer_id) as number_of_costumers
from dbo.Customers
group by
city,
age_group
order by city DESC,
 age_group DESC;
 

 -- Query to verify wich number of customers in each city by age_group, need only to change the age rank to switch different variables

 WITH RankedCities AS (
    SELECT
        city,
        age_group,
        COUNT(customer_id) as number_of_customers,
        ROW_NUMBER() OVER (PARTITION BY city ORDER BY age_group ASC) AS AgeRank
    FROM dbo.Customers
    GROUP BY
        city,
        age_group
)

SELECT
    city,
    age_group,
    number_of_customers
FROM RankedCities
WHERE AgeRank = 3
order by number_of_customers DESC; 

-- same thing but for marital status / gender / 

WITH RankedCities AS (
    SELECT
        city,
        gender,
        COUNT(customer_id) as number_of_customers,
        ROW_NUMBER() OVER (PARTITION BY city ORDER BY gender ASC) AS GenderRank
    FROM dbo.Customers
    GROUP BY
        city,
        gender
)

SELECT
    city,
    gender,
    number_of_customers
FROM RankedCities
WHERE GenderRank = 1
order by number_of_customers DESC; 


-- the city of the highest avg_income customer

WITH RankedCities AS (
    SELECT
        city,
        AVG(avg_income) AS average_income,
        ROW_NUMBER() OVER (ORDER BY AVG(avg_income) DESC) AS IncomeRank
    FROM dbo.Customers
    GROUP BY
        city
)
SELECT
    city,
    average_income
FROM RankedCities
WHERE IncomeRank = 1;




---- PART II , avg income utilisation , Utilisation of joint function to use multiple tables


select * from dbo.Customers

select * from dbo.Spends


-- joining the two tables 

select users.customer_id,
	city,
	age_group,
	spend,
	payment_type,
	category,
	month

from dbo.Customers as users

left join dbo.Spends as money on users.customer_id=money.customer_id



-- total spend by customer and by payment_type
SELECT
    users.customer_id,
    payment_type,
  
    SUM(spend) AS total_spend
FROM
    dbo.Customers AS users
LEFT JOIN
    dbo.Spends AS money ON users.customer_id = money.customer_id
GROUP BY
    users.customer_id,
    payment_type
    
ORDER BY
    users.customer_id;


-- total spent by customer
SELECT
    users.customer_id,

    age_group,
    SUM(spend) AS total_spend
FROM
    dbo.Customers AS users
LEFT JOIN
    dbo.Spends AS money ON users.customer_id = money.customer_id
GROUP BY
    users.customer_id,

    age_group
ORDER BY

	total_spend DESC

-- total spend by customer per year

SELECT
    users.customer_id,	
    SUM(spend) AS total_spend
FROM
    dbo.Customers AS users
LEFT JOIN
    dbo.Spends AS money ON users.customer_id = money.customer_id
GROUP BY
    users.customer_id

ORDER BY
	total_spend DESC

-- avg spend of customer per month

SELECT
    users.customer_id,	
    SUM(spend)/12 AS total_spend
FROM
    dbo.Customers AS users
LEFT JOIN
    dbo.Spends AS money ON users.customer_id = money.customer_id
GROUP BY
    users.customer_id

ORDER BY
	total_spend DESC

-- total spend of customer per month 

SELECT
    users.customer_id,	
    SUM(spend) AS total_spend,
	month
FROM
    dbo.Customers AS users
LEFT JOIN
    dbo.Spends AS money ON users.customer_id = money.customer_id
GROUP BY
    users.customer_id,
	month
ORDER BY
	customer_id

-- avg spend / avg income % per month

SELECT
    users.customer_id,	
    SUM(spend) AS total_spend,
	avg_income,
	concat(
	ROUND((SUM(spend)/avg_income)*100,2),
	'%'
	)as avg_income_utilisation,
	month
FROM
    dbo.Customers AS users
LEFT JOIN
    dbo.Spends AS money ON users.customer_id = money.customer_id
GROUP BY
    users.customer_id,
	avg_income,
	month
ORDER BY
	SUM(spend)/avg_income DESC
	-- ordering by the original ratio, because the rounded one, puts the values >100 in the bottom.


---- PART III SPENDING INSIGHTS
-- total spend by category
-- total spend by payment_type


SELECT
    users.customer_id,
    payment_type,
    SUM(spend) AS total_spend
FROM
    dbo.Customers AS users
LEFT JOIN
    dbo.Spends AS money ON users.customer_id = money.customer_id
GROUP BY
    users.customer_id,
    payment_type
	Order by customer_id


-- total spend per customer all type of payment 
SELECT
    users.customer_id,

    
    SUM(spend) AS total_spend
FROM
    dbo.Customers AS users
LEFT JOIN
    dbo.Spends AS money ON users.customer_id = money.customer_id
GROUP BY
    users.customer_id

ORDER BY
 customer_id

-- amount spend by credit card per customer
SELECT
    users.customer_id,
    payment_type,
  
    SUM(spend) AS total_spend_credit_card
FROM
    dbo.Customers AS users
LEFT JOIN
    dbo.Spends AS money ON users.customer_id = money.customer_id

GROUP BY
    users.customer_id,
    payment_type
	having 
payment_type = 'Credit Card'
Order by customer_id

-- CTE of the above 

WITH CTE_total_spend_credit_card as

(SELECT
    users.customer_id,
    payment_type,
  
    SUM(spend) AS total_spend_credit_card
FROM
    dbo.Customers AS users
LEFT JOIN
    dbo.Spends AS money ON users.customer_id = money.customer_id

GROUP BY
    users.customer_id,
    payment_type
	having 
payment_type = 'Credit Card'
)

select  customer_id, total_spend_credit_card
from CTE_total_spend_credit_card

 
-- % of use of the credit card by customer

SELECT
    users.customer_id,
    payment_type,
    SUM(spend) AS total_spend,
    SUM(spend) / NULLIF(SUM(SUM(spend)) OVER (PARTITION BY users.customer_id), 0) * 100 AS spend_percentage
FROM
    dbo.Customers AS users
LEFT JOIN
    dbo.Spends AS money ON users.customer_id = money.customer_id
GROUP BY
    users.customer_id,
    payment_type
ORDER BY
    users.customer_id, payment_type;


-- 


--
--
--
--
--
--





