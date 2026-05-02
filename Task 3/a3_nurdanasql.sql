BEGIN;
-- TASK 1 using CTEs
WITH new_movies AS (
SELECT 
		'Soulmates' AS title,
		'It follows the lifelong, complex friendship between two women, Ansheng and Qiyue, whose bond is tested by love, 
		ambition, and the choices that pull them in different directions. As they grow from carefree youth into adulthood, their 
		shared past and emotional connection are challenged by rivalry and sacrifice, revealing how deeply intertwined love 
		and friendship can be.' AS description,
		2016 AS release_year,
		(
	SELECT
		l."language_id"
	FROM
		"language" l
	WHERE 
			lower(l."name") = 'mandarin') AS language_id, --finds language no matter of capitalization
		7 AS rental_duration,
		4.99 AS rental_rate,
		110 AS length,
		'R'::mpaa_rating AS rating --motion picture accosiation
UNION ALL
SELECT 
		'The promised neverland' AS title,
		'A Japanese thriller about gifted orphans 
		who uncover a dark secret about their home and plan 
		a risky escape to survive.' AS description,
		2020 AS release_year,
		(
	SELECT
		l."language_id"
	FROM
		"language" l
	WHERE 
			lower(l."name") = 'japanese') AS language_id,
		14 AS rental_duration,
		9.99 AS rental_rate,
		119 AS length,
		'PG-13'::mpaa_rating AS rating
UNION ALL
SELECT 
		'Strangers from hell' AS title,
		'Yuu feels trapped in his hometown. He decides to go to 
		Tokyo and visit his girlfriend, Megumi. Yuu tells her that he wants 
		to live with her in Tokyo, but she is confused by his sudden visit. 
		They end up having an argument. Yuu doesnt have 
		a place to stay in Tokyo, and he ends up staying at 
		a cheap sharehouse named Hakobune. Other people staying there 
		include Yamaguchi, Maru, Yoshiko, Goro, and Kirishima. 
		During his first night there, Yuu sees Yamaguchi and Maru 
		having an argument.' AS description,
		2024 release_year,
		(
	SELECT
		l."language_id"
	FROM
		"language" l
	WHERE 
			lower(l."name") = 'japanese') AS language_id,
		21 AS rental_duration,
		19.99 AS rental_rate,
		123 AS length,
		'PG-13'::mpaa_rating AS rating
	),
	inserted_movies AS (
INSERT INTO
		film 
	(title,
		description,
		release_year,
		language_id,
		rental_duration,
		rental_rate,
		"length",
		rating,
		last_update)
		SELECT
			nm.title,
			nm.description,
			nm.release_year,
			nm.language_id,
			nm.rental_duration,
			nm.rental_rate,
			nm."length",
			nm.rating,
			current_date AS last_update
		FROM
			new_movies nm
		WHERE
			NOT EXISTS (
			SELECT
				*
			FROM
				film f
			WHERE
				f.title = nm.title
				AND f.release_year = nm.release_year)
	RETURNING film_id,
			title,
			release_year,
			rental_duration,
			rental_rate,
			last_update
	)
	SELECT
	film_id,
	title,
	release_year,
	rental_duration,
	rental_rate,
	last_update
FROM
	inserted_movies
;

-- TASK 2 

WITH new_actor AS (
	SELECT 
		'Dongyu' AS first_name,
		'Zhou' AS last_name,
		'Soulmates' AS film_title
	UNION ALL --includes all rows from each select statement
	SELECT 
		'Sichun' AS first_name,
		'Ma' AS last_name,
		'Soulmates' AS film_title
	UNION ALL
	SELECT 
		'Rihito' AS first_name,
		'Itagaki' AS last_name,
		'The promised neverland' AS film_title
	UNION ALL
	SELECT 
		'Minami' AS first_name,
		'Hamabe' AS last_name,
		'The promised neverland' AS film_title
	UNION ALL
	SELECT 
		'Hachimura' AS first_name,
		'Rintaro' AS last_name,
		'Strangers from hell' AS film_title
	UNION ALL
	SELECT 
		'Yanagi' AS first_name,
		'Shuntaro' AS last_name,
		'Strangers from hell' AS film_title
	UNION ALL
	SELECT 
		'Aoki' AS first_name,
		'Sayaka' AS last_name,
		'Strangers from hell' AS film_title
	),
	inserted_actors AS (
	INSERT INTO actor (
	first_name,
	last_name,
	last_update
	)
	SELECT na.first_name, na.last_name, current_date AS last_update
	FROM new_actor na
	WHERE NOT EXISTS (SELECT * FROM actor a WHERE a.first_name = na.first_name AND a.last_name = na.last_name)
	RETURNING actor_id, first_name, last_name, last_update
	)
	--SELECT actor_id, first_name, last_name, last_update FROM inserted_actors; added leading actors
	, all_actors AS (
	SELECT actor_id, first_name, last_name FROM inserted_actors 
	UNION 
	SELECT actor_id, first_name, last_name FROM actor 
	WHERE (first_name, last_name) IN (SELECT first_name, last_name FROM new_actor)
	),
	film_data AS (
	SELECT film_id, title
	FROM film
	)
	INSERT INTO film_actor (actor_id, film_id, last_update)
	SELECT a.actor_id, fa.film_id, current_date AS last_update
	FROM new_actor na 
	JOIN all_actors a ON a.first_name = na.first_name
	AND a.last_name = na.last_name
	JOIN film_data fa ON fa.title = na.film_title
	ON CONFLICT DO NOTHING; --linked via film_actor

-- TASK 3

WITH target_films AS (
	SELECT film_id FROM film WHERE title IN ('Soulmates', 'The promised neverland', 'Strangers from hell')
), target_store AS (
	SELECT store_id FROM store LIMIT 1
)
INSERT INTO inventory (film_id, store_id, last_update)
SELECT tf.film_id, ts.store_id, current_date FROM target_films tf 
CROSS JOIN target_store ts
WHERE NOT EXISTS (SELECT 1 FROM inventory i WHERE i.film_id = tf.film_id AND i.store_id = ts.store_id);

-- TASK 4

--SELECT c.customer_id, c.first_name, c.last_name,
--	count(DISTINCT r.rental_id) AS rental_count,
--	count(DISTINCT p.payment_id) AS payment_count
--FROM customer c
--JOIN rental r ON c.customer_id = r.customer_id 
--JOIN payment p ON c.customer_id = p.customer_id
--GROUP BY c.customer_id, c.first_name, c.last_name 
--HAVING count(DISTINCT r.rental_id) >= 43
--	AND count(DISTINCT p.payment_id) >= 43
--ORDER BY rental_count DESC;

WITH target_customer AS (
	SELECT c.customer_id FROM customer c
	JOIN rental r ON c.customer_id = r.customer_id
	JOIN payment p ON c.customer_id = p.customer_id
	GROUP BY c.customer_id 
	HAVING count(DISTINCT r.rental_id) >= 43
		AND count(DISTINCT p.payment_id) >= 43
	LIMIT 1
)
UPDATE customer 
SET first_name = 'Nurdana', last_name = 'Khalelkyzy',
	email = 'nhalelkyizyi23@apec.edu.kz', address_id = (SELECT address_id FROM address LIMIT 1),
	last_update = current_date
WHERE customer_id = (
	SELECT c.customer_id FROM customer c
	JOIN rental r ON r.customer_id = c.customer_id 
	JOIN payment p ON p.customer_id = c.customer_id 
	GROUP BY c.customer_id 
	HAVING count(DISTINCT r.rental_id) >= 43
	AND count(DISTINCT p.payment_id) >= 43
	LIMIT 1
);

--TASK 5

SELECT * FROM payment WHERE customer_id = (
	SELECT customer_id FROM customer WHERE first_name = 'Nurdana' AND last_name = 'Khalelkyzy'
);
SELECT * FROM rental WHERE customer_id = (
	SELECT customer_id FROM customer WHERE first_name = 'Nurdana' AND last_name = 'Khalelkyzy'
);

DELETE FROM payment WHERE customer_id = (
	SELECT customer_id FROM customer WHERE first_name = 'Nurdana' AND last_name = 'Khalelkyzy'
);
DELETE FROM rental WHERE customer_id = (
	SELECT customer_id FROM customer WHERE first_name = 'Nurdana' AND last_name = 'Khalelkyzy'
);

--TASK 6

SELECT film_id, title
FROM film
WHERE title IN ('Soulmates', 'The promised neverland', 'Strangers from hell');

SELECT i.inventory_id, f.title, i.store_id
FROM inventory i
JOIN film f ON f.film_id = i.film_id
WHERE f.title IN ('Soulmates', 'The promised neverland', 'Strangers from hell');

SELECT r.rental_id, r.rental_date, r.return_date, r.customer_id, r.inventory_id
FROM rental r
JOIN inventory i ON i.inventory_id = r.inventory_id
JOIN film f ON f.film_id = i.film_id
WHERE f.title IN ('Soulmates', 'The promised neverland', 'Strangers from hell');

SELECT p.payment_id, p.customer_id, p.rental_id, p.amount, p.payment_date
FROM payment p
JOIN rental r ON r.rental_id = p.rental_id
JOIN inventory i ON i.inventory_id = r.inventory_id
JOIN film f ON f.film_id = i.film_id
WHERE f.title IN ('Soulmates', 'The promised neverland', 'Strangers from hell')
  AND p.payment_date BETWEEN '2017-01-01' AND '2017-06-30';

SELECT f.title,
       COUNT(DISTINCT r.rental_id) AS rentals,
       COUNT(DISTINCT p.payment_id) AS payments
FROM film f
JOIN inventory i ON i.film_id = f.film_id
JOIN rental r ON r.inventory_id = i.inventory_id
JOIN payment p ON p.rental_id = r.rental_id
WHERE f.title IN ('Soulmates', 'The promised neverland', 'Strangers from hell')
GROUP BY f.title;

COMMIT;