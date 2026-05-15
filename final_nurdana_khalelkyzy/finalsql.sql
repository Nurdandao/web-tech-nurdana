DO $$
BEGIN 
	IF NOT EXISTS (SELECT FROM pg_database WHERE datname = 'Final_Task') THEN EXECUTE 'CREATE DATABASE Final_Task';
	END IF;
END $$;

CREATE SCHEMA IF NOT EXISTS pharmacy_schema;

CREATE TABLE IF NOT EXISTS pharmacy_schema.customers (
	customer_id SERIAL PRIMARY KEY,
	first_name VARCHAR(50) NOT NULL,
	last_name VARCHAR(50) NOT NULL,
	iin VARCHAR(12) UNIQUE NOT NULL,
	date_of_birth DATE NOT NULL ,
	phone VARCHAR(12),
	registered_date DATE NOT NULL,
	last_update TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS pharmacy_schema.employees (
	employee_id SERIAL PRIMARY KEY,
	first_name VARCHAR(50) NOT NULL,
	last_name VARCHAR(50) NOT NULL,
	iin VARCHAR(12) UNIQUE NOT NULL,
	date_of_birth DATE NOT NULL ,
	phone VARCHAR(12),
	registered_date DATE NOT NULL,
	last_update TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS pharmacy_schema.category (
	category_id SERIAL PRIMARY KEY,
	"name" VARCHAR(150)
);

CREATE TABLE IF NOT EXISTS pharmacy_schema.medicines (
	medicine_id SERIAL PRIMARY KEY,
	"name" VARCHAR(300) NOT NULL,
	price VARCHAR(6) NOT NULL,
	supplier_id REFERENCES suppliers(supplier_id)
);

CREATE TABLE IF NOT EXISTS pharmacy_schema.medicine_category (
	category_id REFERENCES category(category_id),
	medicine_id REFERENCES medicines(medicine_id)
);

CREATE TABLE IF NOT EXISTS pharmacy_schema.inventory (
	inventory_id SERIAL PRIMARY KEY,
	medicine_id REFERENCES medicines(medicine_id),
	batch_number VARCHAR(50) NOT NULL,
	quantity INT,
	manufacture_date DATE,
	expiry_date DATE NOT NULL 
);

CREATE TABLE IF NOT EXISTS pharmacy_schema.prescriptions (
	prescription_id SERIAL PRIMARY KEY,
	customer_id REFERENCES customers(customer_id),
	employee_id REFERENCES employees(employee_id),
	prescription_date DATE NOT NULL,
	notes TEXT
);

CREATE TABLE IF NOT EXISTS pharmacy_schema.prescription_items (
	prescription_item_id SERIAL PRIMARY KEY,
	prescription_id REFERENCES prescriptions(prescription_id),
	medicine_id REFERENCES medicines(medicine_id),
	dosage_instruction TEXT,
	quantity int 
);

CREATE TABLE IF NOT EXISTS pharmacy_schema.sales (
	sale_id SERIAL PRIMARY KEY,
	c_id REFERENCES customers(customer_id),
	employee_id REFERENCES employees(employee_id),
	sale_date TIMESTAMP NOT NULL,
	total_amount VARCHAR(6)
);

CREATE TABLE IF NOT EXISTS pharmacy_schema.sales_items (
	sales_item_id SERIAL PRIMARY KEY,
	sale_id REFERENCES 
);