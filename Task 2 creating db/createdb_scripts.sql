CREATE DATABASE IF NOT EXISTS movie_theater_db;
CREATE SCHEMA IF NOT EXISTS movie_theater_schema;



CREATE TABLE IF NOT EXISTS movie_theater_schema.theaters (
    theater_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    address VARCHAR(100) NOT NULL,
    rating DECIMAL(2,1) DEFAULT 0 CHECK (rating BETWEEN 0 AND 10)
);

CREATE TABLE IF NOT EXISTS movie_theater_schema.genres (
    genre_id SERIAL PRIMARY KEY,
    name VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS movie_theater_schema.films (
    film_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    duration INTERVAL NOT NULL,
    genre_id INT REFERENCES movie_theater_schema.genres(genre_id),
    release_date DATE NOT NULL CHECK (release_date > DATE '2026-01-01'),
    age_restriction VARCHAR(3) NOT NULL CHECK (age_restriction IN ('0+','6+','12+','16+','18+')),
    rating DECIMAL(2,1) DEFAULT 0 CHECK (rating BETWEEN 0 AND 10),
    description TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS movie_theater_schema.staff (
    staff_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    phone_number VARCHAR(12) NOT NULL UNIQUE,
    age INT NOT NULL CHECK (age >= 18),
    job_position VARCHAR(50) NOT NULL,
    shift VARCHAR(20) NOT NULL,
    salary NUMERIC(10,2) NOT NULL CHECK (salary > 0),
    theater_id INT NOT NULL REFERENCES movie_theater_schema.theaters(theater_id)
);

CREATE TABLE IF NOT EXISTS movie_theater_schema.customers (
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    phone_number VARCHAR(12) NOT NULL UNIQUE,
    credit_card VARCHAR(16)
);

CREATE TYPE purchase_option AS ENUM ('Cash','Credit_card');

CREATE TABLE IF NOT EXISTS movie_theater_schema.operations (
    operation_id SERIAL PRIMARY KEY,
    purchase_type purchase_option NOT NULL,
    operation_date DATE NOT NULL CHECK (operation_date > DATE '2026-01-01'),
    operation_time TIME NOT NULL
);

CREATE TYPE ticket_option AS ENUM ('Child','Adult','Student');

CREATE TABLE IF NOT EXISTS movie_theater_schema.tickets (
    ticket_id SERIAL PRIMARY KEY,
    ticket_type ticket_option NOT NULL,
    price NUMERIC(10,2) NOT NULL CHECK (price >= 500)
);

CREATE TYPE seat_option AS ENUM ('Normal','Comfort','VIP');

CREATE TABLE IF NOT EXISTS movie_theater_schema.seats (
    seat_id SERIAL PRIMARY KEY,
    seat_type seat_option NOT NULL,
    seat_row CHAR(1) NOT NULL,
    seat_number INT NOT NULL CHECK (seat_number > 0),
    price NUMERIC(10,2) NOT NULL CHECK (price >= 800)
);

CREATE TABLE IF NOT EXISTS movie_theater_schema.screenings (
    screening_id SERIAL PRIMARY KEY,
    film_id INT NOT NULL REFERENCES movie_theater_schema.films(film_id),
    theater_id INT NOT NULL REFERENCES movie_theater_schema.theaters(theater_id),
    screening_date DATE NOT NULL CHECK (screening_date > DATE '2026-01-01'),
    start_time TIME NOT NULL,
    end_time TIME NOT NULL CHECK (end_time > start_time)
);

CREATE TABLE IF NOT EXISTS movie_theater_schema.reservations (
    reservation_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES movie_theater_schema.customers(customer_id),
    seat_id INT NOT NULL REFERENCES movie_theater_schema.seats(seat_id),
    ticket_id INT NOT NULL REFERENCES movie_theater_schema.tickets(ticket_id),
    screening_id INT NOT NULL REFERENCES movie_theater_schema.screenings(screening_id),
    operation_id INT NOT NULL REFERENCES movie_theater_schema.operations(operation_id),
    total_price NUMERIC(10,2) NOT NULL
);


ALTER TABLE movie_theater_schema.films ADD CONSTRAINT unique_film_name UNIQUE (name);
ALTER TABLE movie_theater_schema.theaters ADD CONSTRAINT unique_theater_name UNIQUE (name);
ALTER TABLE movie_theater_schema.staff ADD CONSTRAINT valid_shift CHECK (shift IN ('Morning','Evening','Night'));
ALTER TABLE movie_theater_schema.customers ADD CONSTRAINT card_length CHECK (credit_card IS NULL OR length(credit_card) = 16);
ALTER TABLE movie_theater_schema.screenings ADD CONSTRAINT unique_screening UNIQUE (film_id,theater_id,screening_date,start_time);



TRUNCATE TABLE
movie_theater_schema.reservations,
movie_theater_schema.screenings,
movie_theater_schema.operations,
movie_theater_schema.tickets,
movie_theater_schema.seats,
movie_theater_schema.staff,
movie_theater_schema.customers,
movie_theater_schema.films,
movie_theater_schema.genres,
movie_theater_schema.theaters
CASCADE;

INSERT INTO movie_theater_schema.theaters (name,address,rating) 
VALUES
('Cinema City','Main street 10',8.5),
('Mega Films','Central avenue 22',9.1),
('Star Theater','West road 5',7.9)
;

INSERT INTO movie_theater_schema.genres (name) 
VALUES
('Action'),
('Drama'),
('Comedy')
;

INSERT INTO movie_theater_schema.films (name,duration,genre_id,release_date,age_restriction,rating,description)
VALUES
('Future War','2 hours',(SELECT genre_id FROM movie_theater_schema.genres WHERE name='Action'),'2026-05-01','16+',8.7,'Sci‑fi action film'),
('Life Story','1 hour 45 minutes',(SELECT genre_id FROM movie_theater_schema.genres WHERE name='Drama'),'2026-06-10','12+',7.9,'Emotional drama'),
('Laugh Time','1 hour 30 minutes',(SELECT genre_id FROM movie_theater_schema.genres WHERE name='Comedy'),'2026-07-15','6+',8.2,'Comedy movie')
;

INSERT INTO movie_theater_schema.staff (name,phone_number,age,job_position,shift,salary,theater_id) 
VALUES
('Alex Brown','87010000001',25,'Cashier','Morning',(300000),(SELECT theater_id FROM movie_theater_schema.theaters WHERE name='Cinema City')),
('Maria Stone','87010000002',30,'Manager','Evening',(450000),(SELECT theater_id FROM movie_theater_schema.theaters WHERE name='Mega Films')),
('John Lee','87010000003',22,'Cleaner','Night',(200000),(SELECT theater_id FROM movie_theater_schema.theaters WHERE name='Star Theater'))
;

INSERT INTO movie_theater_schema.customers (name,phone_number,credit_card) 
VALUES
('Alice','87020000001','1234567812345678'),
('Bob','87020000002','8765432187654321'),
('Chris','87020000003',NULL)
;

INSERT INTO movie_theater_schema.operations (purchase_type,operation_date,operation_time) 
VALUES
('Cash','2026-08-01','12:00'),
('Credit_card','2026-08-01','14:00'),
('Credit_card','2026-08-02','16:30')
;

INSERT INTO movie_theater_schema.tickets (ticket_type,price) 
VALUES
('Child',500),
('Adult',1000),
('Student',700)
;

INSERT INTO movie_theater_schema.seats (seat_type,seat_row,seat_number,price) 
VALUES
('Normal','A',1,800),
('Comfort','B',5,1200),
('VIP','C',10,2000)
;

INSERT INTO movie_theater_schema.screenings (film_id,theater_id,screening_date,start_time,end_time)
VALUES
((SELECT film_id FROM movie_theater_schema.films WHERE name='Future War'),
 (SELECT theater_id FROM movie_theater_schema.theaters WHERE name='Cinema City'),
 '2026-08-10','18:00','20:00'),
((SELECT film_id FROM movie_theater_schema.films WHERE name='Life Story'),
 (SELECT theater_id FROM movie_theater_schema.theaters WHERE name='Mega Films'),
 '2026-08-11','17:00','18:45'),
((SELECT film_id FROM movie_theater_schema.films WHERE name='Laugh Time'),
 (SELECT theater_id FROM movie_theater_schema.theaters WHERE name='Star Theater'),
 '2026-08-12','19:00','20:30')
;

INSERT INTO movie_theater_schema.reservations (customer_id,seat_id,ticket_id,screening_id,operation_id, total_price)
VALUES
((SELECT customer_id FROM movie_theater_schema.customers WHERE name='Alice'),
 (SELECT seat_id FROM movie_theater_schema.seats WHERE seat_type='Normal'),
 (SELECT ticket_id FROM movie_theater_schema.tickets WHERE ticket_type='Adult'),
 (SELECT screening_id FROM movie_theater_schema.screenings LIMIT 1),
 (SELECT operation_id FROM movie_theater_schema.operations LIMIT 1),
 (1200)),
((SELECT customer_id FROM movie_theater_schema.customers WHERE name='Bob'),
 (SELECT seat_id FROM movie_theater_schema.seats WHERE seat_type='Comfort'),
 (SELECT ticket_id FROM movie_theater_schema.tickets WHERE ticket_type='Student'),
 (SELECT screening_id FROM movie_theater_schema.screenings OFFSET 1 LIMIT 1),
 (SELECT operation_id FROM movie_theater_schema.operations OFFSET 1 LIMIT 1),
 (1500)),
((SELECT customer_id FROM movie_theater_schema.customers WHERE name='Chris'),
 (SELECT seat_id FROM movie_theater_schema.seats WHERE seat_type='VIP'),
 (SELECT ticket_id FROM movie_theater_schema.tickets WHERE ticket_type='Adult'),
 (SELECT screening_id FROM movie_theater_schema.screenings OFFSET 2 LIMIT 1),
 (SELECT operation_id FROM movie_theater_schema.operations OFFSET 2 LIMIT 1),
 (2000))
;