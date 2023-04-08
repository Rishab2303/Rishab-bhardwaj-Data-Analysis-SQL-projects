/*	Question Set 1 - Easy */

/* Q1: Who is the senior most employee based on job title? */

SELECT title, last_name, first_name 
FROM employee
ORDER BY levels DESC
LIMIT 1

/* Q2: Which countries have the most Invoices? */

SELECT COUNT(*) AS c, billing_country 
FROM invoice
GROUP BY billing_country
ORDER BY c DESC

/* Q3: What are top 3 values of total invoice? */

SELECT total 
FROM invoice
ORDER BY total DESC
LIMIT 3

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

SELECT billing_city,SUM(total) AS InvoiceTotal
FROM invoice
GROUP BY billing_city
ORDER BY InvoiceTotal DESC
LIMIT 1;

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

SELECT customer.customer_id, first_name, last_name, SUM(total) AS total_spending
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total_spending DESC
LIMIT 1;


/* Question Set 2 - Moderate */

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

SELECT distinct c.first_name,c.last_name,c.email from customer C 
join invoice i on i.customer_id = C.customer_id
join invoice_line il on il.invoice_id= i.invoice_id
join track t on t.track_id = il.track_id
join genre g on g.genre_id = t.genre_id
where g.name like 'Rock'

order by email;

--Alternate Method
SELECT distinct c.first_name,c.last_name,c.email from customer C 
join invoice i on i.customer_id = C.customer_id
join invoice_line il on il.invoice_id= i.invoice_id
where track_id  in(
       select t.track_id from track t
	   join genre g on g.genre_id = t.genre_id
	   where g.name like 'Rock'
	   ) 
order by email;

/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

select ar.name,count(*) as track_count from artist ar 
join album al on al.artist_id = ar.artist_id
join track t on t.album_id = al.album_id
join genre g on g.genre_id = t.genre_id
where g.name like 'Rock'
group by ar.name
order by track_count desc 
limit 10;

/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

select milliseconds from track 
where milliseconds > (
                   select avg(milliseconds) as avg_length 
	                 from track  ) 
order by milliseconds desc;

/* Question Set 3 - Advance */

/* Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */
--USING CTE 

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

/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

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

/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

with customer_by_country as(
select c.customer_id,c.first_name,c.last_name,c.country,sum(i.total),
rank() over(partition by c.country order by sum(i.total) desc ) as top_customer
from customer c
join invoice i on i.customer_id= c.customer_id
group by 1,2,3,4)

select * from customer_by_country
where top_customer =1





