--
SELECT distinct c.first_name,c.last_name,c.email from customer C 
join invoice i on i.customer_id = C.customer_id
join invoice_line il on il.invoice_id= i.invoice_id
join track t on t.track_id = il.track_id
join genre g on g.genre_id = t.genre_id
where g.name like 'Rock'

order by email;

--alternate 
SELECT distinct c.first_name,c.last_name,c.email from customer C 
join invoice i on i.customer_id = C.customer_id
join invoice_line il on il.invoice_id= i.invoice_id
where track_id  in(
       select t.track_id from track t
	   join genre g on g.genre_id = t.genre_id
	   where g.name like 'Rock'
	   ) 
order by email;	  

---
select ar.name,count(*) as track_count from artist ar 
join album al on al.artist_id = ar.artist_id
join track t on t.album_id = al.album_id
join genre g on g.genre_id = t.genre_id
where g.name like 'Rock'
group by ar.name
order by track_count desc 
limit 10;

--
select milliseconds from track 
where milliseconds > (
                   select avg(milliseconds) as avg_length 
	                 from track  ) 
order by milliseconds desc;

--
with money_by_artist as (
          select ar.name , ar.artist_id , sum(il.quantity*il.unit_price) as money_spent from artist ar
	     join album al on ar.artist_id = al.artist_id
	     join track t on t.album_id = al.album_id
	     join invoice_line il on il.track_id = t.track_id
	    group by ar.artist_id 
	    order by money_spent desc
	
)

select c.customer_id,c.first_name, c.last_name,mba.name,
sum(il.quantity*il.unit_price) as money_spent from customer c
join invoice i on i.customer_id = c.customer_id
join invoice_line il on il.invoice_id = i.invoice_id 
join track t on t.track_id = il.track_id
join album al on al.album_id = t.album_id
join artist a on a.artist_id= al.artist_id
join money_by_artist mba on mba.artist_id=a.artist_id
group by 1,2,3,4;

-----
with popular_genre as(
select c.country, g.name,g.genre_id,count(il.quantity) as purchases,
row_number() over (partition by c.country order by count(il.quantity) desc ) as popular_genres
from invoice i

join customer c on c.customer_id = i.customer_id
join invoice_line il on il.invoice_id = i.invoice_id
join track t on t.track_id = il.track_id
join genre g on g.genre_id = t.genre_id
group by 1,2,3)

select * from popular_genre 
where popular_genres = 1

---
with customer_by_country as(
select c.customer_id,c.first_name,c.last_name,c.country,sum(i.total),
rank() over(partition by c.country order by sum(i.total) desc ) as top_customer
from customer c
join invoice i on i.customer_id= c.customer_id
group by 1,2,3,4)

select * from customer_by_country
where top_customer =1





