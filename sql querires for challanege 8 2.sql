Select * 
from dbo.Spends

-- to verify if we have the same amount of unique customers so we can merge perfectly the tables.

select COUNT(DISTINCT(customer_id))

from dbo.Spends


--
select customer_id, spend

from dbo.Spends


select DISTINCT(month)
from dbo.Spends










