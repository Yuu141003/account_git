CREATE DATABASE SqlTrainingTest
GO
USE SqlTrainingTest
GO

-- PART 1

CREATE TABLE customers (
  customer_id INT PRIMARY KEY,
  name        VARCHAR(100) NOT NULL,
  email       VARCHAR(150) UNIQUE NOT NULL,
  city        VARCHAR(80),
  joined_at   DATE NOT NULL
);

CREATE TABLE books (
  book_id      INT PRIMARY KEY,
  title        VARCHAR(200) NOT NULL,
  author       VARCHAR(100) NOT NULL,
  genre        VARCHAR(50),
  price        DECIMAL(8,2) NOT NULL,
  stock        INT DEFAULT 0,
  published_at DATE
);

CREATE TABLE orders (
  order_id     INT PRIMARY KEY,
  customer_id  INT NOT NULL REFERENCES customers(customer_id),
  ordered_at   DATETIME2 NOT NULL,
  status       VARCHAR(20) NOT NULL,
  total_amount DECIMAL(10,2) NOT NULL
);

CREATE TABLE order_items (
  item_id    INT PRIMARY KEY,
  order_id   INT NOT NULL REFERENCES orders(order_id),
  book_id    INT NOT NULL REFERENCES books(book_id),
  quantity   INT NOT NULL,
  unit_price DECIMAL(8,2) NOT NULL
);

CREATE TABLE reviews (
  review_id   INT PRIMARY KEY,
  book_id     INT NOT NULL REFERENCES books(book_id),
  customer_id INT NOT NULL REFERENCES customers(customer_id),
  rating      INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  reviewed_at DATE NOT NULL
);

-- customers (8 rows)
INSERT INTO customers VALUES
(1,'Alice Chen','alice@mail.com','New York','2022-01-15'),
(2,'Bob Kumar','bob@mail.com','Chicago','2022-03-08'),
(3,'Clara Novak','clara@mail.com','Seattle','2022-06-20'),
(4,'Diego Reyes','diego@mail.com','Austin','2023-01-05'),
(5,'Eva Müller','eva@mail.com','New York','2023-02-14'),
(6,'Frank Li','frank@mail.com','Chicago','2023-04-30'),
(7,'Grace Osei','grace@mail.com','Seattle','2023-07-11'),
(8,'Hiro Tanaka','hiro@mail.com','Austin','2024-01-22');

-- books (10 rows)
INSERT INTO books VALUES
(1,'Dune','Frank Herbert','Sci-Fi',18.99,120,'1965-08-01'),
(2,'The Pragmatic Programmer','David Thomas','Technology',45.00,60,'1999-10-30'),
(3,'Sapiens','Yuval Harari','Non-Fiction',22.50,85,'2011-01-01'),
(4,'Project Hail Mary','Andy Weir','Sci-Fi',17.99,40,'2021-05-04'),
(5,'Atomic Habits','James Clear','Non-Fiction',19.99,200,'2018-10-16'),
(6,'1984','George Orwell','Fiction',12.99,150,'1949-06-08'),
(7,'Clean Code','Robert Martin','Technology',42.00,0,'2008-08-01'),
(8,'The Hobbit','J.R.R. Tolkien','Fiction',14.99,300,'1937-09-21'),
(9,'Thinking Fast and Slow','Daniel Kahneman','Non-Fiction',24.99,55,'2011-10-25'),
(10,'Enders Game','Orson Scott Card','Sci-Fi',15.99,70,'1985-01-15');

-- orders (10 rows)
INSERT INTO orders VALUES
(1, 1,'2024-01-10 09:00','delivered',63.98),
(2, 2,'2024-01-15 14:30','delivered',45.00),
(3, 3,'2024-02-01 11:15','shipped',55.48),
(4, 1,'2024-02-14 16:00','delivered',37.98),
(5, 4,'2024-03-05 08:45','cancelled',22.50),
(6, 5,'2024-03-20 12:00','delivered',84.99),
(7, 6,'2024-04-02 10:30','shipped',42.00),
(8, 2,'2024-04-18 15:00','pending',62.97),
(9, 7,'2024-05-01 09:00','delivered',32.98),
(10,3,'2024-05-15 13:45','delivered',107.50);

-- order_items
INSERT INTO order_items VALUES
(1,1,1,1,18.99),(2,1,6,1,12.99),(3,1,8,2,14.99),
(4,2,2,1,45.00),
(5,3,3,1,22.50),(6,3,5,1,19.99),(7,3,10,1,15.99),
(8,4,4,1,17.99),(9,4,5,1,19.99),
(10,5,3,1,22.50),
(11,6,5,2,19.99),(12,6,9,1,24.99),(13,6,2,1,45.00),
(14,7,7,1,42.00),
(15,8,1,1,18.99),(16,8,3,1,22.50),(17,8,6,1,12.99),(18,8,8,1,14.99),
(19,9,4,1,17.99),(20,9,8,1,14.99),
(21,10,2,1,45.00),(22,10,5,1,19.99),(23,10,3,1,22.50),(24,10,9,1,24.99),(25,10,1,1,18.99);

-- reviews (note: some books have no review)
INSERT INTO reviews VALUES
(1,1,1,5,'2024-01-20'),(2,1,3,4,'2024-02-02'),
(3,5,1,5,'2024-02-25'),(4,5,5,3,'2024-03-30'),(5,5,6,4,'2024-04-10'),
(6,3,2,2,'2024-04-20'),(7,3,7,4,'2024-05-08'),
(8,4,1,5,'2024-05-10'),
(9,8,3,3,'2024-05-12'),(10,2,2,5,'2024-05-14');


-- PART 2

-- Q1 · INTERMEDIATE — Count books by genre

SELECT 
    genre,
    COUNT(*) AS book_count
FROM books
GROUP BY genre
ORDER BY book_count DESC;

-- Q2 · INTERMEDIATE — Genres with average price above $20

SELECT 
    genre,
    ROUND(AVG(price), 2) AS avg_price
FROM books
GROUP BY genre
HAVING AVG(price) > 20
ORDER BY avg_price DESC;

-- Q3 · INTERMEDIATE — Customers and their order count

SELECT 
    c.name,
    COUNT(o.order_id) AS order_count
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
ORDER BY order_count DESC, c.name ASC;

-- Q4 · INTERMEDIATE — Order status breakdown

SELECT 
    COUNT(CASE WHEN status = 'delivered'  THEN 1 END) AS delivered,
    COUNT(CASE WHEN status = 'shipped'    THEN 1 END) AS shipped,
    COUNT(CASE WHEN status = 'pending'    THEN 1 END) AS pending,
    COUNT(CASE WHEN status = 'cancelled'  THEN 1 END) AS cancelled
FROM orders;

-- Q5 · ADVANCED — Books that have never been ordered

SELECT 
    b.title,
    b.author
FROM books b
LEFT JOIN order_items oi ON b.book_id = oi.book_id
WHERE oi.book_id IS NULL
ORDER BY b.title;

SELECT DISTINCT book_id FROM order_items ORDER BY book_id;

-- Q6 · ADVANCED — Revenue per customer (delivered orders only)

SELECT 
    c.name,
    ROUND(SUM(o.total_amount), 2) AS total_revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.status = 'delivered'
GROUP BY c.customer_id, c.name
ORDER BY total_revenue DESC;

-- Q7 · EXPERT — Highest-priced book per genre

WITH ranked_books AS (
    SELECT 
        genre,
        title,
        price,
        ROW_NUMBER() OVER (PARTITION BY genre ORDER BY price DESC) AS rn
    FROM books
)
SELECT 
    genre,
    title,
    price
FROM ranked_books
WHERE rn = 1
ORDER BY genre;

