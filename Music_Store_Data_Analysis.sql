select billing_country, count(*) from invoice
group by billing_country
order by 1 desc
limit 1;

select * from employee
order by levels desc
limit 1;

select invoice_id,total from invoice
order by total desc
limit 3;

select c.city,sum(i.total) from customer c
Join invoice i
on i.invoice_id = c.customer_id
group by c.city
order by 2 desc;

select sum(total), billing_city from invoice
group by billing_city
order by 1 desc;

select customer_id, sum(total) from invoice
group by customer_id
order by 2 desc;

select email,first_name, last_name 
from customer c
join invoice i 
on c.customer_id = i.customer_id
join invoice_line il
on il.invoice_id = i.invoice_id
where track_id in(
	select track_id from track t
	join genre g
	on g.genre_id = t.genre_id
	where g.name like 'Rock'

)
order by email;


select a.artist_id, a.name,count(a.artist_id) as number_of_songs 
from track t 
join album al
on al.album_id = t.album_id
join artist a 
on a.artist_id = al.artist_id
join genre g
on g.genre_id = t.genre_id
where g.name like 'Rock'
group by a.artist_id 
order by number_of_songs desc
limit 10;

select name,composer, milliseconds from track
where milliseconds > (select avg(milliseconds) as average_track_length from track )
order by milliseconds desc;

with best_selling_artist as (
	select a.artist_id,a.name, sum(i.unit_price*i.quantity) as total_sales 
	from invoice_line i
	join track t on t.track_id =  i.track_id
	join album al on al.album_id = t.album_id
	join artist a on a.artist_id = al.artist_id
	group by 1
	order by 3 desc 
)
select c.customer_id, c.first_name, c.last_name, bsa.name,
sum(i.unit_price*i.quantity) as amount_spent 
from invoice ii 
join customer c on c.customer_id = ii.customer_id
join invoice_line i on i.invoice_id = ii.invoice_id
join track t on t.track_id =  i.track_id
join album al on al.album_id = t.album_id
join best_selling_artist bsa on bsa.artist_id = al.artist_id
group by 1,2,3,4
order by 5 desc;



with popular_genre as (
	select count(il.quantity) as purchases,c.country, g.name, g.genre_id,
	ROW_NUMBER() OVER(Partition by c.country order by count(il.quantity) desc ) as RowNo
	from invoice_line il
	join invoice i on i.invoice_id =  il.invoice_id
	join customer c on c.customer_id = i.customer_id
	join track t on t.track_id = il.track_id
	join genre g on g.genre_id = t.genre_id
	group by 2,3,4
	order by 2 asc, 1 desc 
)
select * from popular_genre where RowNo <= 1;


with recursive
sales_per_country as (
	select count(*) as purchases_per_genre,c.country, g.name, g.genre_id
	from invoice_line il
	join invoice i on i.invoice_id =  il.invoice_id
	join customer c on c.customer_id = i.customer_id
	join track t on t.track_id = il.track_id
	join genre g on g.genre_id = t.genre_id
	group by 2,3,4
	order by 2 asc, 1 desc 
),
	max_genre_per_country as (select max(purchases_per_genre) as max_genre_number,country
	from sales_per_country
	group by 2
	order by 2)

select sales_per_country.*
from sales_per_country
join max_genre_per_country on sales_per_country.country = max_genre_per_country.country
where sales_per_country.purchases_per_genre = max_genre_per_country.max_genre_number;


with customer_with_country as (
	select c.customer_id, first_name,last_name,billing_country,sum(total) as total_spending,
	ROW_NUMBER() OVER(Partition by billing_country order by sum(total)) as RowNo
	from invoice
	join customer c on
	c.customer_id = invoice.customer_id
	group by 1,2,3,4
	order by 4 asc,5 desc
)
select * from customer_with_country where RowNo<=1;

with recursive
customer_with_country as (
	select c.customer_id, first_name,last_name,billing_country,count(*) as total_spending
	from invoice
	join customer c on
	c.customer_id = invoice.customer_id
	group by 1,2,3,4
	order by 4 asc, 5 desc
),
	max_spending as (select(max(total_spending)) as maximum_spent,billing_country 
	from customer_with_country 
	group by 2
	order by 2)
	select customer_with_country.*
	from customer_with_country
	join max_spending on max_spending.billing_country = customer_with_country.billing_country
	where max_spending.maximum_spent = customer_with_country.total_spending;




















