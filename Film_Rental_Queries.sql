USE FILM_RENTAL;

# 1.	What is the total revenue generated from all rentals in the database? 

SELECT SUM(AMOUNT) FROM PAYMENT;

# 2.	How many rentals were made in each month_name?

SELECT DATE_FORMAT(RENTAL_DATE, "%b")AS Month_Name ,COUNT(*) AS Count 
FROM rental
GROUP BY Month_Name
ORDER BY Count DESC;

# 3.	What is the rental rate of the film with the longest title in the database?
SELECT title, rental_rate, length(title) AS title_len
FROM film
WHERE LENGTH(title)=(
						SELECT max(length(title)) 
                        FROM film
                        );
                                           
# 4.	What is the average rental rate for films that were taken from the last 30 days from the date("2005-05-05 22:04:30")?
 
SELECT AVG(RENTAL_RATE)
FROM FILM f
			JOIN rental r ON f.film_id = r.rental_id
WHERE r.rental_date >=date_sub(date("2005-05-05 22:04:30"), INTERVAL '30' DAY);

# 5.	What is the most popular category of films in terms of the number of rentals?

SELECT fc.category_id, c.name, count(*) as most_rental 
FROM FILM_CATEGORY fc
					JOIN category c ON fc.category_id = c.category_id
					JOIN film f ON fc.film_id = f.film_id
					JOIN inventory inv ON f.film_id = inv.film_id
					JOIN rental r ON inv.inventory_id = r.inventory_id
GROUP BY fc.category_id, c.name
ORDER BY most_rental DESC
LIMIT 1;

# 6.	Find the longest movie duration from the list of films that have not been rented by any customer?

SELECT MAX(f.LENGTH) AS longest_duration
FROM film f
WHERE f.film_id NOT IN (
						SELECT DISTINCT inv.film_id 
                        FROM rental r
                        JOIN inventory inv ON r.inventory_id = inv.inventory_id
                        );

# 7.	What is the average rental rate for films, broken down by category? 

SELECT c.name AS Category_name, AVG(f.rental_rate) AS Avg_rental_rate  
from film f
			JOIN film_category fc ON f.film_id = fc.film_id
			JOIN category c ON fc.category_id = c.category_id
GROUP BY c.category_id;

# 8.	What is the total revenue generated from rentals for each actor in the database? 

SELECT actor.Actor_id, actor.First_name, actor.Last_name, SUM(film.rental_rate) AS Total_revenue 
FROM actor
JOIN film_actor ON actor.actor_id = film_actor.actor_id 
JOIN film ON film_actor.film_id = film.film_id 
JOIN inventory ON film.film_id = inventory.film_id 
JOIN rental ON inventory.inventory_id = rental.inventory_id 
GROUP BY actor.actor_id 
ORDER BY total_revenue DESC;

# 9.	Show all the actresses who worked in a film having a "Wrestler" in the description?
SELECT DISTINCT actor.First_name, actor.Last_name 
FROM actor
			JOIN film_actor ON actor.actor_id = film_actor.actor_id 
			JOIN film ON film_actor.film_id = film.film_id
WHERE film.description LIKE '%Wrestler%';

# 10.	Which customers have rented the same film more than once?
SELECT r.customer_id, CONCAT(first_name," ",last_name) as Customer_Name, COUNT(*) AS rental_count
FROM rental r
			JOIN Customer c ON r.customer_id = c.customer_id
GROUP BY r.customer_id
HAVING Count(*) > 1;

# 11.	How many films in the comedy category have a rental rate higher than the average rental rate?
SELECT COUNT(c.name) AS Comedy_Movies
FROM category c
				JOIN film_category fc ON c.category_id = fc.category_id
				JOIN film f ON fc.film_id = f.film_id
				JOIN inventory inv ON f.film_id = inv.film_id
				JOIN rental r ON inv.inventory_id = r.inventory_id
where f.rental_rate > (SELECT AVG(rental_rate) FROM film) AND c.name = "Comedy"; 

# 12.	Which films have been rented the most by customers living in each city? 

SELECT f.Title,c.City,count(f.film_id) as Most_rental 
From city c  
			join address ad on c.city_id=ad.city_id 
			join customer cs on ad.address_id=cs.address_id 
			join rental r on cs.customer_id=r.customer_id 
			join inventory i on r.inventory_id=i.inventory_id 
			join film f on i.film_id=f.film_id
GROUP BY f.title,c.city 
HAVING count(f.film_id)=(
						  select max(Most_rental) as Most_rental 
						   FROM ( 
									Select count(*) as Most_rental 
                                    from city c 
												join address ad on c.city_id=ad.city_id 
												join customer cs on ad.address_id=cs.address_id 
												join rental r on cs.customer_id=r.customer_id 
												join inventory i on r.inventory_id=i.inventory_id 
												join film f on i.film_id=f.film_id 
												GROUP BY f.title,c.city) as Most_rental
                                                );

# 13.	What is the total amount spent by customers whose rental payments exceed $200? 

SELECT concat(first_name," ",last_name) as Customer_name,sum(amount) as Total_amount 
FROM customer c 
				JOIN payment p on c.customer_id=p.customer_id 
GROUP BY Customer_name
HAVING sum(amount)>200;

# 14.	Display the fields which are having foreign key constraints related to the "rental" table?

SELECT CONSTRAINT_NAME, TABLE_NAME, COLUMN_NAME, REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME 
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE  
WHERE REFERENCED_TABLE_NAME = 'rental';

# 15.	Create a View for the total revenue generated by each staff member, broken down by store city with the country name?

CREATE VIEW Staff_revenue AS
SELECT s.Staff_id, concat(s.first_name," ",s.last_name) AS Name, c.City, co.Country, SUM(p.amount) AS Total_revenue 
FROM staff s
			JOIN store st ON s.store_id = st.store_id 
			JOIN address AS a ON st.address_id = a.address_id
			JOIN city c ON a.city_id = c.city_id 
			JOIN country AS co ON c.country_id = co.country_id
			JOIN customer cust ON s.staff_id = cust.store_id 
			JOIN payment AS p ON cust.customer_id = p.customer_id
GROUP BY s.staff_id, c.city 
ORDER BY s.staff_id, total_revenue DESC;
SELECT * FROM Staff_revenue;









 

