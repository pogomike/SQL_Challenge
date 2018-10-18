-- 1a. Display the first and last names of all actors from the table actor.

SELECT first_name, last_name
FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.

SELECT CONCAT(first_name, " ", last_name) AS Actor_Name
FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?

SELECT actor_id, first_name, last_name FROM actor 
WHERE first_name = "Joe" ;

-- 2b. Find all actors whose last name contain the letters GEN:

SELECT * FROM actor 
WHERE last_name LIKE "%GEN%";

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:

SELECT * FROM actor 
WHERE last_name LIKE "%LI%" 
ORDER BY last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:

SELECT country_id, country FROM country 
WHERE country IN ("Afghanistan", "Bangladesh", "China");

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).


-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.


-- 4a. List the last names of actors, as well as how many actors have that last name.

SELECT last_name,
	COUNT(last_name) AS number_of_actors 
	FROM actor 
	GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors

SELECT last_name, count(last_name) AS number_of_actors 
	FROM actor 
	GROUP BY last_name HAVING COUNT(last_name) >= 2;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.

UPDATE actor SET first_name = "HARPO" 
WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS";

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.



-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?

SHOW CREATE TABLE address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:

SELECT s.first_name, s.last_name, a.address 
	FROM staff s
	JOIN address a USING (address_id);

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.

SELECT s.first_name, s.last_name, SUM(amount) 
	FROM payment p
	JOIN staff s
	ON s.staff_id = p.staff_id
	WHERE p.payment_date LIKE  "2005-08%"
	GROUP BY s.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.

SELECT f.title, COUNT(a.actor_id) AS number_of_actors 
	FROM film_actor a
	INNER JOIN film f
	ON a.film_id = f.film_id
	GROUP BY f.film_id;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?

SELECT COUNT(i.inventory_id) AS copies_of_film 
	FROM inventory i
	JOIN film f
	ON i.film_id = f.film_id
	WHERE f.title = "Hunchback Impossible";

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:

SELECT c.first_name, c.last_name, SUM(p.amount) AS total_payment 
	FROM customer c
	JOIN payment p
	ON c.customer_id = p.customer_id
	GROUP BY c.customer_id
	ORDER BY c.last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.

SELECT f.title 
FROM film f
WHERE f.language_id IN
(
SELECT language_id FROM language
WHERE name = "English"
)
AND f.title LIKE "K%" OR f.title LIKE "Q%";

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.

SELECT a.first_name, a.last_name 
	FROM actor a
	WHERE actor_id IN
(
SELECT fa.actor_id 
	FROM film_actor fa
	WHERE fa.film_id IN
(
SELECT f.film_id 
	FROM film f
	WHERE f.title = "Alone Trip"
));

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.

SELECT m.first_name, m.last_name, m.email 
	FROM customer m
	JOIN address a USING (address_id)
	JOIN city c ON a.city_id = c.city_id
	JOIN country y ON y.country_id = c.country_id
	WHERE country = "Canada";

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.

SELECT title 
	FROM film f, category c, film_category fc
	WHERE  f.film_id = fc.film_id
	AND fc.category_id = c.category_id
	AND c.NAME = "Family";

-- 7e. Display the most frequently rented movies in descending order.

SELECT f.title, COUNT(f.title) AS rented_times 
	FROM rental r
	JOIN inventory i USING (inventory_id)
	JOIN film f USING (film_id)
	GROUP BY f.title
	ORDER BY COUNT(f.title) DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.

SELECT s.store_id, CONCAT("$", FORMAT(SUM(amount), 2)) AS revenue 
	FROM payment p
	JOIN staff s USING (staff_id)
	GROUP BY s.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.

SELECT s.store_id, c.city, y.country 
	FROM store s, city c, country y, address a
	WHERE s.address_id = a.address_id
	AND a.city_id = c.city_id
	AND c.country_id = y.country_id;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

SELECT c.NAME, SUM(p.amount) AS gross_revenue 
	FROM payment p 
	JOIN rental r USING (rental_id)
	JOIN inventory i USING (inventory_id)
	JOIN film_category fc USING (film_id)
	JOIN category c USING (category_id)
	GROUP BY c.NAME
	ORDER BY SUM(p.amount) DESC LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

CREATE VIEW top_5_genres AS 
	SELECT c.NAME, SUM(p.amount) AS gross_revenue 
	FROM payment p 
	JOIN rental r USING (rental_id)
	JOIN inventory i USING (inventory_id)
	JOIN film_category fc USING (film_id)
	JOIN category c USING (category_id)
	GROUP BY c.NAME
	ORDER BY SUM(p.amount) DESC LIMIT 5;

-- 8b. How would you display the view that you created in 8a?

SELECT * FROM top_5_genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

DROP VIEW top_5_genres;