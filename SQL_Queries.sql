select customer_name, avg(billed_amount) from billing
group by customer_name;

select distinct(billing_creation_date) from billing;
with sales as
(select customer_id, customer_name 
,sum(case when to_char(billing_creation_date,'yyyy') = '2019' then billed_amount else 0 end)::decimal as sum_2019
,sum(case when to_char(billing_creation_date,'yyyy') = '2020' then billed_amount else 0 end) as sum_2020
,sum(case when to_char(billing_creation_date,'yyyy') = '2021' then billed_amount else 0 end) as sum_2021
,count(case when to_char(billing_creation_date,'yyyy') = '2019' then billed_amount else null end) as count_2019
,count(case when to_char(billing_creation_date,'yyyy') = '2020' then billed_amount else null end) as count_2020
,count(case when to_char(billing_creation_date,'yyyy') = '2021' then billed_amount else null end) as count_2021
from billing
group by customer_id, customer_name)
select customer_name, round((sum_2019+sum_2020+sum_2021)/(case when count_2019 = 0 then 1 else count_2019 end
													+ case when count_2020 = 0 then 1 else count_2020 end
													+case when count_2021 = 0 then 1 else count_2021 end),2)
													from sales;
	select * from billing;
	
	
	with cte as (
	select concat(customer_name,' ',billed_amount) as name
		, ntile(4) over(order by customer_name) as buckets
		from billing)
		select string_agg(name,', ') as final_result 
		from cte
		group by buckets
		order by 1;
		
select case when translation is null 
					then comment 
					else translation 
					end as output
					from comments_and_translations;
	
	select coalesce(translation, comment) as output 
	from comments_and_translations;
	

select s.id, 'Mismatch' as comment
from source s
join target t on t.id = s.id and s.name <> t.name
union
select s.id, ' New Source' as comment
from source s
left join target t on t.id = s.id 
where t.id is null
union
select t.id, ' New in Target' as comment
from source s
right join target t on t.id = s.id 
where s.id is null;

with matches as
(select row_number() over(order by team_code ) as id 
,team_code
,team_name
from teams)
select team.team_name, opponent.team_name
from matches team 
join matches opponent 
on team.id < opponent.id;


-- Write a SQL query to fetch all the duplicate records from a table.

--Tables Structure:

select user_id, user_name, email from(
	select *, 
			row_number() over(partition  by user_name order by user_id) as row
	from users ) x
	where x.row >1;
	
-- From the doctors table, fetch the details of doctors who work in the same hospital but in different speciality.

--Table Structure:


select d.* from doctors d
join doctors dd 
on d.id <> dd.id
where d.hospital = dd.hospital
and d.speciality <> dd.speciality;

-- From the login_details table, fetch the users who logged in consecutively 3 or more times.

--Table Structure:

select  distinct user_name as repeated_names from(
select *,
row_number() over(partition by user_name order by login_id) as row
from login_details) x
where x.row >= 3;
select distinct user_name from
(select *, 
case when user_name = lead(user_name) over(order by login_id)
	 and user_name = lead(user_name,2) over(order by login_id)
	 then user_name
	 else null
	 end
from login_details) x
where x.case is not null;

-- From the weather table, fetch all the records when London had extremely cold temperature for 3 consecutive days or more.

-- Note: Weather is considered to be extremely cold then its temperature is less than zero.

--Table Structure:
select distinct city from
(select city,temperature,
case when temperature < 0 
 and lead(temperature) over(order by id) < 0
 and lead(temperature,2) over(order by id) < 0
 then 'Yes'
 
	when temperature< 0
 		and lag(temperature) over(order by id) < 0
 		and lead(temperature) over(order by id) < 0
 	then 'Yes'
 	when temperature < 0
	and lag(temperature,2) over(order by id)<0 
 	and lag(temperature) over(order by id) < 0
 	then 'Yes'
	else null end 
from weather) x
where x.case = 'Yes';


-- Find the top 2 accounts with the maximum number of unique patients on a monthly basis.

-- Note: Prefer the account if with the least value in case of same number of unique patients

--Table Structure:
select * from 
(select *,
rank() over(partition by month order by no_of_patients desc, account_id) as rnk
from
(select month, account_id, count(1) as no_of_patients from
(select distinct to_char(date, 'month') as month, account_id, patient_id
from patient_logs) pl
group by month, account_id) x) temp
where temp.rnk in (1,2)

