CREATE DATABASE project_music_db;

USE PROJECT_MUSIC_DB;

-- IMPORTING TABLES THROUGH WIZARD FEATURE
SHOW TABLES;

-- Now making PRIMARY KEY and FOREIGN KEY to establish relation between these tables
ALTER TABLE artist
ADD CONSTRAINT PRIMARY KEY ( artist_id);

DESC album;

ALTER TABLE album
ADD CONSTRAINT PRIMARY KEY ( album_id);

ALTER TABLE employee
ADD CONSTRAINT PRIMARY KEY (employee_id);

ALTER TABLE customer
ADD CONSTRAINT PRIMARY KEY (customer_id);

ALTER TABLE invoice
ADD CONSTRAINT PRIMARY KEY (invoice_id);

ALTER TABLE invoice_line
ADD CONSTRAINT PRIMARY KEY (invoice_line_id);

ALTER TABLE track
ADD CONSTRAINT PRIMARY KEY (track_id);

ALTER TABLE playlist
ADD CONSTRAINT PRIMARY KEY (playlist_id);

ALTER TABLE playlist_track
ADD CONSTRAINT PRIMARY KEY (playlist_id,track_id);

ALTER TABLE genre
ADD CONSTRAINT PRIMARY KEY (genre_id);

ALTER TABLE media_type
ADD CONSTRAINT PRIMARY KEY (media_type_id);

ALTER TABLE album
ADD FOREIGN KEY (artist_id)
REFERENCES artist(artist_id) ON DELETE SET NULL;

ALTER TABLE track
ADD FOREIGN KEY (album_id)
REFERENCES album(album_id) ON DELETE SET NULL;
-- like this adding more foreign key in track table


ALTER TABLE playlist_track
ADD FOREIGN KEY (playlist_id)
REFERENCES playlist(playlist_id) ON DELETE CASCADE;

ALTER TABLE playlist_track
ADD FOREIGN KEY (track_id)
REFERENCES track(track_id) ON DELETE CASCADE;
-- this time we facing a error 1452 so for that you have to delete some row from `playlist_track` table because 
-- these records are no present in `track` table so its no use if you want to find that rows you have to delete use right join
SELECT *
FROM track
RIGHT JOIN playlist_track
 ON track.track_id = playlist_track.track_id
 WHERE track.track_id IS NULL;
DELETE FROM project_music_db.playlist_track 
WHERE track_id >362;
-- apply foreign key constraint now its work

ALTER TABLE invoice_line
ADD FOREIGN KEY (track_id)
REFERENCES track(track_id) ON DELETE SET NULL;

SELECT *
FROM track
RIGHT JOIN invoice_line
 ON track.track_id = invoice_line.track_id
WHERE track.track_id IS NULL;
 
DELETE FROM project_music_db.invoice_line 
WHERE track_id >362;

ALTER TABLE invoice_line
ADD FOREIGN KEY (invoice_id)
REFERENCES invoice(invoice_id) ON DELETE SET NULL;

ALTER TABLE invoice
ADD FOREIGN KEY (customer_id)
REFERENCES customer(customer_id) ON DELETE SET NULL;

ALTER TABLE customer
ADD FOREIGN KEY (support_rep_id)
REFERENCES 	employee(employee_id) ON DELETE SET NULL;

ALTER TABLE employee
ADD FOREIGN KEY (reports_to)
REFERENCES 	employee(employee_id) ON DELETE SET NULL;

-- lets fix employee table
 
SELECT * FROM employee;

UPDATE employee
SET phone = concat('+',phone)
where employee_id = 5;

-- FIXING BIRTHDATE AND HIREDATE 
UPDATE employee
SET fax = concat('+',fax)
where employee_id = 5;

SELECT birthdate FROM employee;
SELECT birthdate,DATE_FORMAT(STR_TO_DATE(birthdate, '%d-%m-%Y %H:%i'), '%Y-%m-%d') AS formatted_date
FROM employee
WHERE birthdate LIKE '__-%';

UPDATE employee
SET	birthdate = DATE_FORMAT(STR_TO_DATE(birthdate, '%d-%m-%Y %H:%i'), '%Y-%m-%d')
WHERE birthdate LIKE '__-%';

UPDATE employee
SET birthdate = DATE_FORMAT(STR_TO_DATE(birthdate, '%d/%m/%Y %H:%i'), '%Y-%m-%d')
WHERE birthdate LIKE '%/%';

ALTER TABLE employee
MODIFY birthdate DATE;

UPDATE employee
SET	hire_date = DATE_FORMAT(STR_TO_DATE(hire_date, '%d-%m-%Y %H:%i'), '%Y-%m-%d')
WHERE hire_date LIKE '%-%';

UPDATE employee
SET hire_date = DATE_FORMAT(STR_TO_DATE(hire_date, '%d/%m/%Y %H:%i'), '%Y-%m-%d')
WHERE hire_date LIKE '%/%';

ALTER TABLE employee
MODIFY hire_date DATE;

-- Now do some QUESTION regarding this database, which will assist in uncovering valuable insights

-- Q Who is the senior most employee based on job title?
SELECT * FROM employee
ORDER BY levels DESC
LIMIT 1;

-- Q. Which countries have the most Invoices?
SELECT billing_country, ROUND(SUM(total)) AS `Total`
FROM invoice
GROUP BY billing_country
ORDER BY `Total` DESC;

-- Q. What are top 3 values of total invoice?
SELECT *
FROM invoice
ORDER BY total DESC
LIMIT 3;

-- Q. Which city has the best customers? We would like to throw a promotional Music
-- Festival in the city we made the most money. Write a query that returns one city that
-- has the highest sum of invoice totals. Return both the city name & sum of all invoice
-- totals
SELECT billing_city,ROUND(SUM(total)) AS InvoiceTotal
FROM invoice
GROUP BY billing_city
ORDER BY InvoiceTotal DESC
LIMIT 1;

-- Q. Who is the best customer? The customer who has spent the most money will be
-- declared the best customer. Write a query that returns the person who has spent the
-- most money
SELECT customer.customer_id,first_name, last_name, SUM(total) AS `purchase`
FROM customer
JOIN invoice
ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY `purchase` DESC
LIMIT 1;

-- Q. Write query to return the email, first name, last name, & Genre of all Rock Music
-- listeners. Return your list ordered alphabetically by email starting with A
SELECT DISTINCT email, first_name, last_name, genre.name AS `Genre Name`
FROM customer
JOIN invoice
	ON customer.customer_id = invoice.customer_id
JOIN invoice_line
	ON invoice.invoice_id = invoice_line.invoice_id
JOIN track
	ON invoice_line.track_id = track.track_id
JOIN genre
	ON track.genre_id = genre.genre_id
WHERE genre.name ='Rock'
ORDER BY 1;




-- Q. Let's invite the artists who have written the most rock music in our dataset. Write a
-- query that returns the Artist name and total track count of the top 10 rock bands
SELECT artist.name, COUNT(track_id) AS `Track Count`
FROM artist
JOIN album
	ON artist.artist_id = album.album_id
JOIN track
	ON album.album_id = track.album_id
JOIN genre
	ON track.genre_id = genre.genre_id
WHERE genre.name = 'Rock'
GROUP BY artist.name
ORDER BY 2 DESC
LIMIT 10;

-- Q. Return all the track names that have a song length longer than the average song length.
-- Return the Name and Milliseconds for each track. Order by the song length with the
-- longest songs listed first
SELECT track.name, track.milliseconds
FROM track
WHERE track.milliseconds >( SELECT AVG(milliseconds)
							FROM track )
ORDER BY 2 DESC;

-- Q. Find how much amount spent by each customer on artists? Write a query to return
-- customer name, artist name and total spent
SELECT customer.customer_id, customer.first_name, customer.last_name, artist.name, ROUND(SUM(total)) AS Spent
	FROM artist
	JOIN album ON album.album_id = artist.artist_id
	JOIN track ON track.album_id = album.album_id
    JOIN invoice_line ON invoice_line.track_id = track.track_id
    JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
    JOIN customer ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id, customer.first_name, customer.last_name, artist.name
ORDER BY 1 ASC, 5 DESC
;

-- Q. We want to find out the most popular music Genre for each country. We determine the
-- most popular genre as the genre with the highest amount of purchases. Write a query
-- that returns each country along with the top Genre. For countries where the maximum
-- number of purchases is shared return all Genres
WITH popular_genre AS 
(
    SELECT ROUND(SUM(invoice.total)) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY ROUND(SUM(invoice.total)) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1;


-- Q. Write a query that determines the customer that has spent the most on music for each
-- country. Write a query that returns the country along with the top customer and how
-- much they spent. For countries where the top amount spent is shared, provide all
-- customers who spent this amount
WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1;





