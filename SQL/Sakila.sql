use sakila;
-- Make a copy of the structure and data of the table.
-- CREATE TABLE actor_backup AS SELECT * FROM actor;

-- 1a. Display the first and last names of all actors from the table actor.
SELECT DISTINCT first_name, last_name
FROM actor
ORDER BY first_name;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT DISTINCT first_name, last_name, CONCAT(UCASE(first_name), " ", UCASE(last_name)) AS `Actor Name`
FROM actor
ORDER BY first_name;

/* 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
 What is one query would you use to obtain this information? */
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = 'Joe'

-- 2b. Find all actors whose last name contain the letters GEN:
SELECT actor_id, first_name, last_name
FROM actor
WHERE last_name LIKE ('%Gen%');

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT actor_id, first_name, last_name
FROM actor
WHERE last_name LIKE ('%Li%')
ORDER BY last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China: 
SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

/* 3a. Add a middle_name column to the table actor. Position it between first_name and last_name. 
Hint: you will need to specify the data type. */
ALTER TABLE actor
ADD COLUMN middle_name VARCHAR(30) AFTER first_name;

/* 3b. You realize that some of these actors have tremendously long last names. 
Change the data type of the middle_name column to blobs. */
ALTER TABLE actor
MODIFY middle_name BLOB;

-- 3c. Now delete the middle_name column.
ALTER TABLE actor
DROP COLUMN middle_name;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name) AS 'Number of Actors'
FROM actor
GROUP BY last_name

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors 
SELECT last_name, COUNT(last_name) AS 'Number of Actors'
FROM actor
GROUP BY last_name
HAVING COUNT(last_name) > 1;

/* 4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, 
the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record. */

SELECT first_name, last_name, actor_id
FROM actor
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS'

UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS'

SELECT first_name, last_name, actor_id
FROM actor
WHERE first_name = 'HARPO' AND last_name = 'WILLIAMS'

/* 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! 
In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. 
Otherwise, change the first name to MUCHO GROUCHO, as that is exactly what the actor will be with the grievous error. 
BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! 
(Hint: update the record using a unique identifier.) */

UPDATE actor
SET first_name = 
	CASE 
		WHEN first_name = 'HARPO'
			THEN 'GROUCHO'
		ELSE 
        'MUCHO GROUCHO'
	END 
WHERE actor_id = 172;

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE sakila.address;
-- SHOW COLUMNS FROM sakila.address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT first_name, last_name, address.address
FROM staff INNER JOIN address ON staff.address_id = address.address_id

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT s.staff_id, CONCAT(s.first_name, " ", s.last_name) AS name, SUM(amount)
FROM staff s INNER JOIN payment p ON s.staff_id = p.staff_id
WHERE MONTH(payment_date) = 8 AND YEAR(payment_date) = 2005
GROUP BY s.staff_id

/* SELECT distinct payment_id, staff_id, payment_date, MONTH(payment_date), YEAR(payment_date)
FROM payment */

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT f.title, COUNT(fa.actor_id) AS 'Number of Actors'
FROM film f INNER JOIN film_actor fa ON f.film_id = fa.film_id
GROUP BY f.film_id
ORDER BY f.title

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT f.title, COUNT(inventory_id) AS 'Number of Copies'
FROM inventory i INNER JOIN film f ON i.film_id 
WHERE f.title = 'Hunchback Impossible'
GROUP BY f.film_id

/*SELECT distinct film_id, inventory_id
FROM inventory*/

/* SELECT title
FROM film
WHERE title = 'Hunchback Impossible' */

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT c.first_name AS 'First Name', c.last_name AS 'Last Name', SUM(amount) AS 'Total Amount Paid'
FROM customer c INNER JOIN payment p ON c.customer_id = p.payment_id
GROUP BY c.last_name, c.first_name
ORDER BY c.last_name

/* 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
Use subqueries to display the titles of movies starting with the letters K and Q whose language is English. */
SELECT title
FROM film where language_id IN
	(
	SELECT language_id
	FROM language 
	WHERE name = 'English'
	) 

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT CONCAT(a.first_name, " ", a.last_name) AS actor
FROM actor a 
WHERE actor_id IN
	(SELECT fa.actor_id
    FROM film f INNER JOIN film_actor fa ON f.film_id = fa.film_id
    WHERE f.title = 'Alone Trip'
    )

/* 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses 
of all Canadian customers. Use joins to retrieve this information. */
SELECT c.first_name, c.last_name, c.email, cy.country
FROM customer c LEFT JOIN address a ON c.address_id = a.address_id
LEFT JOIN city ci ON a.city_id = ci.city_id
LEFT JOIN country cy ON ci.country_id = cy.country_id
WHERE cy.country = 'Canada'

/*7d. Sales have been lagging among young families, 
and you wish to target all family movies for a promotion. 
Identify all movies categorized as family films.*/
SELECT f.title
FROM film f 
WHERE f.film_id IN
	(SELECT film_id FROM film_category fc
    WHERE fc.category_id IN
		(SELECT category_id
		FROM category
		WHERE name = 'Family'
		))
        
/* SELECT f.title
FROM film_category fc INNER JOIN film f ON fc.film_id = f.film_id
WHERE fc.category_id IN
	(SELECT category_id
    FROM category
    WHERE name = 'Family'
    ) */
    
/*SELECT DISTINCT name
FROM category */

-- 7e. Display the most frequently rented movies in descending order.
SELECT f.title, COUNT(r.rental_id) AS 'Number of Rentals'
FROM inventory i LEFT JOIN film f ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY f.title
ORDER BY COUNT(rental_id) DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT st.store_id, SUM(p.amount) AS 'Revenue'
FROM store s JOIN staff st ON s.store_id = st.store_id
JOIN payment p ON p.staff_id = st.staff_id
GROUP BY st.store_id;

/* SELECT store_id
FROM store */

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT st.store_id, ct.city, cy.country
FROM store st LEFT JOIN address a ON st.address_id = a.address_id
JOIN city ct ON a.city_id = ct.city_id
JOIN country cy ON ct.country_id = cy.country_id;

/* 7h. List the top five genres in gross revenue in descending order. 
(Hint: you may need to use the following tables: 
category, film_category, inventory, payment, and rental.) */
SELECT c.name AS 'Genre', SUM(p.amount) AS 'Revenue'
FROM category c JOIN film_category fc ON c.category_id = fc.category_id
JOIN inventory i ON fc.film_id = i.film_id 
JOIN rental r ON r.inventory_id = i.inventory_id 
JOIN payment p ON p.rental_id = r.rental_id
group by c.name
order by SUM(p.amount) DESC
LIMIT 5;

/* 8a. In your new role as an executive, 
you would like to have an easy way of viewing the Top five genres 
by gross revenue. Use the solution from the problem above to create a view. 
If you haven't solved 7h, you can substitute another query to create a view. */
CREATE VIEW top_5_revenue_by_genre AS
SELECT c.name AS 'Genre', SUM(p.amount) AS 'Revenue'
FROM category c JOIN film_category fc ON c.category_id = fc.category_id
JOIN inventory i ON fc.film_id = i.film_id 
JOIN rental r ON r.inventory_id = i.inventory_id 
JOIN payment p ON p.rental_id = r.rental_id
group by c.name
order by SUM(p.amount) DESC
LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
SELECT * 
FROM top_5_revenue_by_genre

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW IF EXISTS top_5_revenue_by_genre;