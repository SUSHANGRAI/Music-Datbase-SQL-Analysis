SET 1 QUESTIONS (LEVEL EASY)

question 1: who is the senior most employee based on job title ?

select * from employee
order by levels desc 
limit 1

question 2: which countries has the most invoices?
select * from invoice
select count (*) as c , billing_country 
from invoice 
group by billing_country
order by c desc

question 3: what are top 3 values of total invoice ?

select total from invoice 
order by total desc 
limit 3

question 4: which city has the best customers ? we would like to throw a promotional music festival in the city we made the most money. 
            Write a query that return one city that has the highest sum of invoice totals. 
			Return both the city name and sum of all invoice totals.
			
select * from invoice 
select sum(total) as total_billing, billing_city 
from invoice 
group by billing_city 
order by total_billing desc 

question 5: Who is the best customer ? The customer who has spent the most money will be declared the best customer. 
            Write a query that returns the person who has spent the most money.
			
select customer.customer_id, customer.first_name, customer.last_name, SUM(invoice.total) AS TOTAL
from customer
join invoice on customer.customer_id = invoice.customer_id 
group by customer.customer_id 
order by TOTAL desc
limit 1

QUESTIONS SET 2 (MODERATE LEVEL)

question 1: write a query to return the email, first_name, last_name and Genre of all the rock music listeners. Return your list 
            ordered alphabetically by email starting with A. 
			
SELECT DISTINCT email, first_name, last_name
FROM customer 
JOIN invoice on customer.customer_id = invoice.customer_id
JOIN invoice_line on invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN (
        SELECT track_id from track
	    JOIN genre on track.genre_id = genre.genre_id
	    WHERE genre.name like 'Rock'
)
ORDER BY email;


question 2: lets invite the artist who has written the most rock music in our dataset. write a query that returns the artist name
            and total track count of the top 10 rock bands.
			
			
select artist.artist_id, artist.name, count(artist.aritst_id) as number_of_songs
from track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY number_of_songs DESC
LIMIT 10

question 3: return all the track names that have a song length longer than the average song length. Return the name and millisecond 
            for each track. Order by the song length with the longest songs listed first 
			
select name, milliseconds
from track
where milliseconds > (
    select avg(milliseconds) as avg_track_length
	from track
)
order by milliseconds desc

QUESTION SET-3 (ADVANCE)

question 1: find how much amount spent by each customer on artist? Write a query to return customer_name, artist_name and total_spent
           
WITH best_selling_artist AS (
       SELECT artist.artist_id AS artist_unique, artist.name AS artist_naam,
	   SUM (invoice_line.unit_price*invoice_line.quantity) AS total_sales
	   FROM invoice_line 
	  JOIN track ON track.track_id= invoice_line.track_id
	  JOIN album ON album.album_id=track.album_id
	  JOIN artist ON artist.artist_id= album.artist_id
	  GROUP BY 1
	  ORDER BY 3 DESC 
	  LIMIT 1
)

SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_naam, SUM (il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id= i.customer_id
JOIN invoice_line il ON il.invoice_id= i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

question 2: we want to find out the most popular music genre for each country. we determine the most popular genre with the highest 
            amount of purchases. write a query that returns each country along with the top genre. for countries where the maximum number 
			of purshases is shared return all genres. 
			
WITH popular_genre AS
(
SELECT COUNT ( invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
ROW NUMBER ()-OVER ( PARTITION BY customer.country ORDER BY COUNT ( invoice_line.quantity) DESC ) AS RowNUMBER
FROM invoice_line
JOIN invoice ON invoice.invoice_id= invoice_line.invoice_id
JOIN customer ON customer.customer_id= invoice.customer_id 
JOIN track ON track.track_id= invoice_line.track_id
JOIN genre ON genre.genre.id= track.genre_id 
GROUP BY 2,3,4
ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNUMBER <=1;

--question 3: write a query that determines the custome that spent the most on music for each country. 
--write a query that returns the country along with top customer and how much they spent. for countries where the top amount spent is 
--showed, provide all customers who spent this amount--

WITH RECURSIVE customer_with_country AS (
   SELECT customer.customer_id, customer.first_name, customer.last_name, invoice.billing_country, SUM (total) AS total_spending
	FROM invoice
	JOIN customer ON customer.customer_id = invoice.customer_id
	GROUP BY 1,2,3,4 
	ORDER BY 1,5 DESC)
	
      country_max_spending AS (
	  SELECT invoice.billing_country, MAX ( total_spending) AS max_spending 
	  FROM customer_with_country
	  GROUP BY billing_country)
	  
  SELECT cc.billing_country, cc.total_spending, cc.first_name, cc.last_name, cc.customer_id
  FROM customer_with_country AS cc
  JOIN country_max_spending AS ms
  ON cc.billing_country= ms.billing_country
  WHERE cc.total_spending= ms.max_spending 
  ORDER BY 1;
  
  WITH customer_with_country AS (
  SELECT customer.customer_id, customer.first_name, customer.last_name, invoice.billing_country, SUM (invoice.total) AS total_spending
  ROW NUMBER () OVER ( PARTITION BY billing_country ORDER BY SUM ( total) DESC ) AS ROWNUMBER 
  FROM invoice
  JOIN customer ON customer.customer_id= invoice.customer_id 
  GROUP BY 1, 2, 3, 4
  ORDER BY 4 ASC, 5 DESC)
  SELECT * FROM customer_with_country WHERE ROWNUMBER <=1