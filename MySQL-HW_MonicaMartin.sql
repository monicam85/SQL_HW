
USE Sakila;

#1a. Display Firt & Last Name
SELECT first_name, last_name
FROM actor;

#1b. Display First & Last Name in single column
SELECT CONCAT(first_name, ' ' ,last_name) AS Actor_Name
FROM actor;

#2a Query "Joe" to find first_name, last_name, and ID #
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name LIKE 'JOE';

#2b Find all actors whose last name contain the letters GEN
SELECT actor_id, first_name, last_name
FROM actor
WHERE last_name LIKE '%GEN%';

#2c Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT actor_id, last_name, first_name
FROM actor
WHERE last_name LIKE '%LI%';

#2d Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT  country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

#3a Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify the data type.
ALTER TABLE actor
	ADD COLUMN middle_name VARCHAR(20) NOT NULL
	AFTER first_name;
    
#3b You realize that some of these actors have tremendously long last names. Change the data type of the middle_name column to blobs
ALTER TABLE actor
	MODIFY COLUMN middle_name BLOB;
    
#3c Delete the middle_name column
ALTER TABLE actor
	DROP COLUMN middle_name;
    
#4a List the last names of actors, as well as how many actors have that last name
SELECT last_name, COUNT(last_name) 
FROM actor 
GROUP BY last_name;

#4b List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(last_name) 
FROM actor
GROUP BY last_name
HAVING COUNT(last_name) > '1';

/*4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, 
the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.*/

#REplace GOUCHO with HARPO
UPDATE actor
SET first_name ='HARPO'  
WHERE last_name ='WILLIAMS'
AND first_name = 'GROUCHO';

#Verify GOUCHO replced with Harpo
SELECT first_name, last_name
FROM actor
WHERE last_name LIKE 'WILLIAMS';

/*4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name 
after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. Otherwise, 
change the first name to MUCHO GROUCHO, as that is exactly what the actor will be with the grievous error. BE CAREFUL 
NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! (Hint: update the record using a unique identifier.)*/

#Replace HARPO w/ GOUCHO and GOUCHO w/ MUCHOGOUCHO
# "Safe Updates" was disabled to permit the following line of code to RUN (locatio: Edit/Preferences/SQL Editor)
UPDATE actor
SET first_name =
	(CASE first_name
		WHEN  'HARPO' THEN 'GROUCHO'  
		WHEN  'GROUCHO' THEN 'MUCHO GROUCHO'
        ELSE first_name
	END)
WHERE  actor_id <> 0;

#Verify GOUCHO replcement
SELECT first_name, last_name
FROM actor
WHERE first_name LIKE '%GROUCHO%';

#5a You cannot locate the schema of the address table. Which query would you use to re-create it?
show create table address;
# From Table: Select "Create Table" row, right click, select "Copy Row (Unquotted), paste into mysql script

#6a Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT first_name, last_name, address
FROM address ad
INNER JOIN staff s
ON (ad.address_id = s.address_id);

#6b Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment. 
SELECT first_name, last_name, SUM(amount) AS total_amount
FROM payment pm
JOIN staff s
ON (s.staff_id = pm.staff_id)
WHERE payment_date LIKE '2005-08%'
GROUP BY first_name;

#6c List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT title, SUM(actor_id)
FROM film f
INNER JOIN film_actor fa
ON (f.film_id = fa.film_id)
GROUP BY title;

#6d How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT title, COUNT(title)
FROM film f
INNER JOIN inventory inv
ON (f.film_id = inv.film_id)
WHERE title LIKE 'Hunchback Impossible';


/*6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
List the customers alphabetically by last name:*/
SELECT last_name, SUM(amount) AS total_amount_paid
FROM payment pm
JOIN customer c
ON (pm.customer_id = c.customer_id)
GROUP BY last_name ASC;

/*7a The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, 
films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of 
movies starting with the letters K and Q whose language is English*/ 
SELECT title, lan.name AS language
FROM film f
JOIN language lan
ON (f.language_id = lan.language_id)
WHERE (title LIKE 'K%' OR title LIKE 'Q%') AND lan.name = 'English';

/*7b Use subqueries to display all actors who appear in the film Alone Trip.*/
SELECT first_name, last_name, title
FROM actor a
INNER JOIN film_actor fa
ON (a.actor_id = fa.actor_id)
INNER JOIN film f
ON (fa.film_id = f.film_id)
WHERE f.title LIKE 'Alone Trip';

/*7c You want to run an email marketing campaign in Canada, for which you will need the names and email addresses 
of all Canadian customers. Use joins to retrieve this information.*/
SELECT first_name, last_name, email, country
FROM customer c
INNER JOIN address ad
ON (c.address_id = ad.address_id)
INNER JOIN city ct
ON (ad.city_id = ct.city_id)
INNER JOIN country co
ON (co.country_id = ct.country_id)
WHERE co.country LIKE 'Canada';

/*7d Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify
 all movies categorized as famiy films.*/
SELECT title, cat.name AS category_name
FROM film f
INNER JOIN film_category fc
ON (f.film_id = fc.film_id)
INNER JOIN category cat
ON (fc.category_id = cat.category_id)
WHERE cat.name LIKE 'Family';
 
/*7e Display the most frequently rented movies in descending order.*/
SELECT rental_rate, title
FROM film
WHERE rental_rate > 2.99
GROUP BY title DESC;

/*7f Write a query to display how much business, in dollars, each store brought in*/
SELECT st.store_id, SUM(amount) AS business_in_dollars
FROM payment pm
INNER JOIN staff s
ON (pm.staff_id = s.staff_id)
INNER JOIN store st
ON (s.store_id = st.store_id)
GROUP BY st.store_id;

/*7g Write a query to display for each store its store ID, city, and country*/
SELECT st.store_id, city, country
FROM store st
INNER JOIN address ad
ON (st.address_id = ad.address_id)
INNER JOIN city ct
ON (ad.city_id = ct.city_id)
INNER JOIN country co
ON (co.country_id = ct.country_id);

/*7h List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category,
 film_category, inventory, payment, and rental.)*/
SELECT cat.name AS top_5_genres, SUM(amount) AS gross_revenue
FROM payment pm
INNER JOIN rental r
ON (pm.rental_id = r.rental_id)
INNER JOIN inventory inv
ON (r.inventory_id = inv.inventory_id)
INNER JOIN film_category fc
ON (inv.film_id = fc.film_id)
INNER JOIN category cat
ON (fc.category_id = cat.category_id)
GROUP BY cat.category_id
ORDER BY gross_revenue DESC
LIMIT 5;

 
/*8a In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use
 the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.*/

DROP VIEW IF EXISTS top_5_genres;

CREATE VIEW top_5_genres AS
SELECT cat.name AS top_5_genres, SUM(amount) AS gross_revenue
FROM payment pm
INNER JOIN rental r
ON (pm.rental_id = r.rental_id)
INNER JOIN inventory inv
ON (r.inventory_id = inv.inventory_id)
INNER JOIN film_category fc
ON (inv.film_id = fc.film_id)
INNER JOIN category cat
ON (fc.category_id = cat.category_id)
GROUP BY cat.category_id
ORDER BY gross_revenue DESC
LIMIT 5;

/*8b How would you display the view that you created in 8a?*/
SELECT * 
FROM sakila.top_5_genres;

/*8c You find that you no longer need the view top_five_genres. Write a query to delete it*/
DROP VIEW top_5_genres;