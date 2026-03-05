use finance;

select * from financial;

# default rate

select count(*) as total_customers,
sum(defaults) as total_defaults,
round(avg(defaults) * 100, 2) as default_rate_percentage
from financial;


# risk segmentation query

select
case
when number_of_late_payments = 0 then '1-very low'
when number_of_late_payments between 1 and 3 then '2-low'
when number_of_late_payments between 4 and 6 then '3-medium'
else '4-high'
end as risk_segment,
count(*) as customer_count,
round(avg(defaults) * 100, 2) as default_rate
from financial
group by 1
order by 1;

# income vs default query


select case
when annual_income < 40000 then 'under $40k'
when annual_income between 40000 and 80000 then '$40k - $80k'
when annual_income between 80000 and 120000 then '$80k - $120k'
else 'over $120k'
end as income_bracket,
count(*) as total_customers,
round(avg(defaults) * 100, 2) as default_rate
from financial
group by 1
order by min(annual_income);

# high debt customers


select customer_id, annual_income, loan_amount, debt_ratio
  from financial
    where debt_ratio > 0.6
      order by debt_ratio desc;

# expected loss calculation

with segment_pd as (
select number_of_late_payments,
avg(defaults) over (partition by number_of_late_payments) as pd
from financial
)
select
r.customer_id,
r.loan_amount as ead,
s.pd as pd,
0.45 as lgd,
(r.loan_amount * s.pd * 0.45) as expected_loss
from financial r
join segment_pd s
on r.number_of_late_payments = s.number_of_late_payments
limit 10;
