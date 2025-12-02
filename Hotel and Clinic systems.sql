A.

CREATE TABLE users (
    user_id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100),
    phone_number VARCHAR(20),
    mail_id VARCHAR(100),
    billing_address VARCHAR(255)
);

INSERT INTO users VALUES
('21wrcxuy-67erfn', 'John Doe', '97XXXXXXXX', 'john.doe@example.com', 'Address1'),
('U002', 'Sarah Lee', '98XXXXXXXX', 'sarah@example.com', 'Address2'),
('U003', 'Michael Tan', '89XXXXXXXX', 'michael@example.com', 'Address3'),
('U004', 'Priya Shah', '79XXXXXXXX', 'priya@example.com', 'Address4');

-------------------------------------------------------

CREATE TABLE bookings (
    booking_id VARCHAR(50) PRIMARY KEY,
    booking_date TIMESTAMP,
    room_no VARCHAR(50),
    user_id VARCHAR(50),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

INSERT INTO bookings VALUES
('bk-09f3e-95hj', '2021-09-23 07:36:48', 'rm-bhf9-aerjn', '21wrcxuy-67erfn'),
('BK002', '2021-11-15 10:20:00', 'RM202', 'U002'),
('BK003', '2021-11-28 18:45:10', 'RM305', 'U003'),
('BK004', '2021-10-12 14:50:00', 'RM150', 'U004');

-------------------------------------------------------

CREATE TABLE items (
    item_id VARCHAR(50) PRIMARY KEY,
    item_name VARCHAR(100),
    item_rate DECIMAL(10,2)
);

INSERT INTO items VALUES
('itm-a9e8-q8fu', 'Tawa Paratha', 18),
('itm-a07vh-aer8', 'Mix Veg', 89),
('itm-b637-hja8', 'Coffee', 20),
('itm-c72k-jan2', 'Fried Rice', 120);

-------------------------------------------------------

CREATE TABLE booking_commercials (
    id VARCHAR(50) PRIMARY KEY,
    booking_id VARCHAR(50),
    bill_id VARCHAR(50),
    bill_date TIMESTAMP,
    item_id VARCHAR(50),
    item_quantity DECIMAL(10,2),
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id),
    FOREIGN KEY (item_id) REFERENCES items(item_id)
);

INSERT INTO booking_commercials VALUES
('ID1', 'bk-09f3e-95hj', 'bl-0a87y-q340', '2021-09-23 12:03:22', 'itm-a9e8-q8fu', 3),
('ID2', 'bk-09f3e-95hj', 'bl-0a87y-q340', '2021-09-23 12:03:22', 'itm-a07vh-aer8', 1),
('ID3', 'BK002', 'BL2001', '2021-11-15 11:00:00', 'itm-b637-hja8', 2),
('ID4', 'BK002', 'BL2001', '2021-11-15 11:00:00', 'itm-c72k-jan2', 1),
('ID5', 'BK003', 'BL3001', '2021-11-28 19:10:00', 'itm-b637-hja8', 1),
('ID6', 'BK004', 'BL4001', '2021-10-12 15:00:00', 'itm-a9e8-q8fu', 5);

1. SELECT u.user_id, b.room_no
   FROM users u
   JOIN bookings b ON u.user_id = b.user_id
       WHERE b.booking_date = (
            SELECT MAX(b2.booking_date)
            FROM bookings b2
           WHERE b2.user_id = u.user_id
   );

2. SELECT b.booking_id,
       COALESCE(SUM(bc.item_quantity * i.item_rate), 0) AS total_amount
   FROM bookings b
   LEFT JOIN booking_commercials bc
        ON b.booking_id = bc.booking_id
   LEFT JOIN items i 
        ON bc.item_id = i.item_id
   WHERE strftime('%Y', b.booking_date) = '2021'
     AND strftime('%m', b.booking_date) = '11'
   GROUP BY b.booking_id;

3. WITH bill_totals AS (
       SELECT 
           b.booking_id,
           SUM(bc.item_quantity * i.item_rate) AS total_amount
       FROM bookings b
       LEFT JOIN booking_commercials bc ON b.booking_id = bc.booking_id
       LEFT JOIN items i ON bc.item_id = i.item_id
       GROUP BY b.booking_id
   )
   SELECT booking_id, total_amount
   FROM bill_totals
   WHERE total_amount > 1000;

4. WITH monthly_totals AS (
       SELECT 
           strftime('%m', bc.bill_date) AS month,
           bc.item_id,
           SUM(bc.item_quantity) AS total_qty
       FROM booking_commercials bc
       JOIN items i ON bc.item_id = i.item_id
       WHERE strftime('%Y', bc.bill_date) = '2021'
       GROUP BY month, bc.item_id
   ),

   ranked_items AS (
       SELECT 
           month,
           item_id,
           total_qty,
           RANK() OVER (PARTITION BY month ORDER BY total_qty DESC) AS max_rank,
           RANK() OVER (PARTITION BY month ORDER BY total_qty ASC) AS min_rank
       FROM monthly_totals
   )

   SELECT month, item_id, total_qty, 'MOST ORDERED' AS status
   FROM ranked_items
   WHERE max_rank = 1

   UNION ALL

   SELECT month, item_id, total_qty, 'LEAST ORDERED' AS status
   FROM ranked_items
   WHERE min_rank = 1

   ORDER BY month, status DESC;

5. WITH bill_totals AS (
       SELECT 
           b.booking_id,
           SUM(bc.item_quantity * i.item_rate) AS total_amount
          FROM bookings b
       LEFT JOIN booking_commercials bc ON b.booking_id = bc.booking_id
       LEFT JOIN items i ON bc.item_id = i.item_id
       GROUP BY b.booking_id
   ),
   ranked AS (
       SELECT 
           booking_id,
           total_amount,
           DENSE_RANK() OVER (ORDER BY total_amount DESC) AS bill_rank
       FROM bill_totals
   )
   SELECT booking_id, total_amount
   FROM ranked
   WHERE bill_rank = 2;

B.
  
  CREATE TABLE clinics (
    cid VARCHAR(20),
    clinic_name VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50)
);

INSERT INTO clinics VALUES
('cnc-0100001', 'XYZ clinic', 'Hyderabad', 'Telangana', 'India'),
('CNC002', 'Smile Care', 'Hyderabad', 'Telangana', 'India'),
('CNC003', 'City Clinic', 'Mumbai', 'Maharashtra', 'India');

-----------------------

CREATE TABLE customer (
    uid VARCHAR(20),
    name VARCHAR(50),
    mobile VARCHAR(20)
);

INSERT INTO customer VALUES
('bk-09f3e-95hj', 'Jon Doe', '97XXXXXXX'),
('C002', 'Salma Khan', '98XXXXXXX'),
('C003', 'Rohan Gupta', '88XXXXXXX');

-----------------------

CREATE TABLE clinic_sales (
    oid VARCHAR(20),
    uid VARCHAR(20),
    cid VARCHAR(20),
    amount DECIMAL(10,2),
    datetime TIMESTAMP,
    sales_channel VARCHAR(30)
);

INSERT INTO clinic_sales VALUES
('ord-00100-00100','bk-09f3e-95hj','cnc-0100001',24999,'2021-09-23 12:03:22','sodat'),
('S2001','C002','CNC002',15000,'2021-09-10 11:00:00','walkin'),
('S3001','C003','CNC003',42000,'2021-11-01 14:22:11','online');

-----------------------

CREATE TABLE expenses (
    eid VARCHAR(20),
    cid VARCHAR(20),
    amount DECIMAL(10,2),
    datetime TIMESTAMP
);

INSERT INTO expenses VALUES
('exp-0100-00100','cnc-0100001',557,'2021-09-23 07:36:48'),
('EXP2001','CNC002',300,'2021-09-10 09:00:00'),
('EXP3001','CNC003',5000,'2021-11-01 10:10:10');

1. SELECT 
     sales_channel,
     SUM(amount) AS total_revenue
   FROM clinic_sales
   WHERE strftime('%Y', datetime) = '2021'
   GROUP BY sales_channel;

2. SELECT 
     c.uid,
     c.name,
     SUM(cs.amount) AS total_spent
   FROM customer c
   JOIN clinic_sales cs ON c.uid = cs.uid
   WHERE strftime('%Y', cs.datetime) = '2021'
   GROUP BY c.uid, c.name
   ORDER BY total_spent DESC
   LIMIT 10;

3. SELECT 
      strftime('%Y-%m', cs.datetime) AS month,
      SUM(cs.amount) AS revenue,
      COALESCE(SUM(e.amount), 0) AS expense,
      SUM(cs.amount) - COALESCE(SUM(e.amount), 0) AS profit,
      CASE 
          WHEN SUM(cs.amount) - COALESCE(SUM(e.amount), 0) > 0 THEN 'profitable'
          ELSE 'not-profitable'
      END AS status
  FROM clinic_sales cs
  LEFT JOIN expenses e 
      ON strftime('%Y-%m', cs.datetime) = strftime('%Y-%m', e.datetime)
  WHERE strftime('%Y', cs.datetime) = '2021'
  GROUP BY strftime('%Y-%m', cs.datetime)
  ORDER BY month;

4. WITH clinic_profit AS (
       SELECT 
           c.cid,
           c.clinic_name,
           c.city,
          SUM(cs.amount) - COALESCE(SUM(e.amount), 0) AS profit
       FROM clinics c
       LEFT JOIN clinic_sales cs ON c.cid = cs.cid 
         AND strftime('%Y-%m', cs.datetime) = '2021-09'
    LEFT JOIN expenses e ON c.cid = e.cid 
        AND strftime('%Y-%m', e.datetime) = '2021-09'
    GROUP BY c.cid, c.clinic_name, c.city
  )
  SELECT city, clinic_name, profit
  FROM (
      SELECT *,
           RANK() OVER (PARTITION BY city ORDER BY profit DESC) AS rnk
      FROM clinic_profit
  ) t
  WHERE rnk = 1;

5. WITH clinic_profit AS (
    SELECT 
        c.cid,
        c.clinic_name,
        c.state,
        SUM(cs.amount) - COALESCE(SUM(e.amount), 0) AS profit
    FROM clinics c
    LEFT JOIN clinic_sales cs ON c.cid = cs.cid 
        AND strftime('%Y-%m', cs.datetime) = '2021-09'
    LEFT JOIN expenses e ON c.cid = e.cid 
        AND strftime('%Y-%m', e.datetime) = '2021-09'
    GROUP BY c.cid, c.clinic_name, c.state
   )
   SELECT state, clinic_name, profit
   FROM (
      SELECT *,
           RANK() OVER (PARTITION BY state ORDER BY profit ASC) AS rnk
      FROM clinic_profit
   ) t
   WHERE rnk = 2;






