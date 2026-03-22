-- ============================================================
--  CS27 — Hotel Booking System
--  Complete MySQL Script — Run this file entirely in one click
--  Order: Database → Tables → Data → Updates → Queries
-- ============================================================


-- ============================================================
--  STEP 1: CREATE DATABASE
-- ============================================================

CREATE DATABASE IF NOT EXISTS hotel_booking_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE hotel_booking_db;


-- ============================================================
--  STEP 2: CREATE TABLES (order matters — FKs first!)
-- ============================================================

-- 2.1 GUEST
CREATE TABLE GUEST (
    guest_id     INT           NOT NULL AUTO_INCREMENT,
    first_name   VARCHAR(50)   NOT NULL,
    last_name    VARCHAR(50)   NOT NULL,
    email        VARCHAR(100)  NOT NULL,
    phone        VARCHAR(20),
    nationality  VARCHAR(50)   DEFAULT 'Unknown',
    CONSTRAINT PK_GUEST  PRIMARY KEY (guest_id),
    CONSTRAINT UQ_EMAIL  UNIQUE      (email)
);

-- 2.2 ROOM
CREATE TABLE ROOM (
    room_id          INT           NOT NULL AUTO_INCREMENT,
    room_number      VARCHAR(10)   NOT NULL,
    room_type        ENUM('Single','Double','Suite') NOT NULL,
    price_per_night  DECIMAL(8,2)  NOT NULL CHECK (price_per_night > 0),
    capacity         INT           NOT NULL DEFAULT 1,
    status           ENUM('Available','Occupied','Maintenance') NOT NULL DEFAULT 'Available',
    CONSTRAINT PK_ROOM      PRIMARY KEY (room_id),
    CONSTRAINT UQ_ROOM_NUM  UNIQUE      (room_number)
);

-- 2.3 BOOKING (references GUEST and ROOM)
CREATE TABLE BOOKING (
    booking_id      INT           NOT NULL AUTO_INCREMENT,
    guest_id        INT           NOT NULL,
    room_id         INT           NOT NULL,
    check_in_date   DATE          NOT NULL,
    check_out_date  DATE          NOT NULL,
    total_amount    DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    booking_status  ENUM('Confirmed','Cancelled','Completed') NOT NULL DEFAULT 'Confirmed',
    CONSTRAINT PK_BOOKING   PRIMARY KEY (booking_id),
    CONSTRAINT FK_BK_GUEST  FOREIGN KEY (guest_id)
        REFERENCES GUEST(guest_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT FK_BK_ROOM   FOREIGN KEY (room_id)
        REFERENCES ROOM(room_id)  ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT CHK_DATES    CHECK (check_out_date > check_in_date)
);

-- 2.4 SERVICE
CREATE TABLE SERVICE (
    service_id    INT           NOT NULL AUTO_INCREMENT,
    service_name  VARCHAR(100)  NOT NULL,
    price         DECIMAL(8,2)  NOT NULL CHECK (price >= 0),
    description   TEXT,
    CONSTRAINT PK_SERVICE PRIMARY KEY (service_id)
);

-- 2.5 BOOKING_SERVICE — junction table (references BOOKING and SERVICE)
CREATE TABLE BOOKING_SERVICE (
    booking_id  INT  NOT NULL,
    service_id  INT  NOT NULL,
    quantity    INT  NOT NULL DEFAULT 1 CHECK (quantity > 0),
    CONSTRAINT PK_BS         PRIMARY KEY (booking_id, service_id),
    CONSTRAINT FK_BS_BOOKING FOREIGN KEY (booking_id)
        REFERENCES BOOKING(booking_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT FK_BS_SERVICE FOREIGN KEY (service_id)
        REFERENCES SERVICE(service_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- 2.6 INVOICE (references BOOKING)
CREATE TABLE INVOICE (
    invoice_id      INT           NOT NULL AUTO_INCREMENT,
    booking_id      INT           NOT NULL,
    issue_date      DATE          NOT NULL DEFAULT (CURRENT_DATE),
    total_due       DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    payment_status  ENUM('Paid','Pending','Cancelled') NOT NULL DEFAULT 'Pending',
    payment_method  VARCHAR(30)   DEFAULT 'Unknown',
    CONSTRAINT PK_INVOICE     PRIMARY KEY (invoice_id),
    CONSTRAINT FK_INV_BOOKING FOREIGN KEY (booking_id)
        REFERENCES BOOKING(booking_id) ON DELETE RESTRICT ON UPDATE CASCADE
);


-- ============================================================
--  STEP 3: INSERT DATA (10 rows per table)
-- ============================================================

-- GUEST
INSERT INTO GUEST (first_name, last_name, email, phone, nationality) VALUES
('Alice',   'Martin',        'alice.martin@mail.com',      '+33601020304',  'French'),
('Bob',     'Smith',         'bob.smith@mail.com',         '+4477009988',   'British'),
('Carlos',  'Diaz',          'carlos.diaz@mail.com',       '+34698112233',  'Spanish'),
('Diana',   'Nguyen',        'diana.nguyen@mail.com',      '+84912345678',  'Vietnamese'),
('Ethan',   'Johnson',       'ethan.j@mail.com',           '+12025551234',  'American'),
('Fatima',  'El-Amin',       'fatima.elamin@mail.com',     '+21261234567',  'Moroccan'),
('George',  'Papadopoulos',  'george.p@mail.com',          '+30210123456',  'Greek'),
('Hannah',  'Muller',        'hannah.muller@mail.com',     '+4917612345678','German'),
('Ivan',    'Petrov',        'ivan.petrov@mail.com',       '+79161234567',  'Russian'),
('Jasmine', 'Osei',          'jasmine.osei@mail.com',      '+233244123456', 'Ghanaian');

-- ROOM
INSERT INTO ROOM (room_number, room_type, price_per_night, capacity, status) VALUES
('101', 'Single',  60.00, 1, 'Available'),
('102', 'Single',  65.00, 1, 'Occupied'),
('201', 'Double',  90.00, 2, 'Available'),
('202', 'Double',  95.00, 2, 'Available'),
('203', 'Double', 100.00, 2, 'Maintenance'),
('301', 'Suite',  180.00, 4, 'Available'),
('302', 'Suite',  200.00, 4, 'Occupied'),
('303', 'Suite',  220.00, 4, 'Available'),
('401', 'Single',  70.00, 1, 'Available'),
('402', 'Double', 110.00, 3, 'Available');

-- BOOKING
INSERT INTO BOOKING (guest_id, room_id, check_in_date, check_out_date, total_amount, booking_status) VALUES
(1,  1, '2026-01-10', '2026-01-13',  180.00, 'Completed'),
(2,  3, '2026-01-15', '2026-01-18',  270.00, 'Completed'),
(3,  6, '2026-02-01', '2026-02-05',  720.00, 'Completed'),
(4,  2, '2026-02-10', '2026-02-12',  130.00, 'Cancelled'),
(5,  7, '2026-02-20', '2026-02-24',  800.00, 'Confirmed'),
(6,  4, '2026-03-01', '2026-03-03',  190.00, 'Confirmed'),
(7,  8, '2026-03-05', '2026-03-10', 1100.00, 'Confirmed'),
(8,  9, '2026-03-12', '2026-03-14',  140.00, 'Confirmed'),
(9, 10, '2026-03-20', '2026-03-23',  330.00, 'Confirmed'),
(10, 5, '2026-04-01', '2026-04-04',  300.00, 'Confirmed');

-- SERVICE
INSERT INTO SERVICE (service_name, price, description) VALUES
('Breakfast',     15.00, 'Full continental breakfast served 7-10 AM'),
('Spa',           50.00, 'One-hour relaxation massage or facial treatment'),
('Laundry',       12.00, 'Same-day laundry and ironing service'),
('Airport Pickup', 35.00, 'Private car transfer from/to the airport'),
('Room Service',  20.00, 'In-room dining available 24/7'),
('Mini Bar',      25.00, 'Fully stocked mini-bar replenishment'),
('Gym Access',    10.00, 'Access to the hotel fitness center'),
('Parking',       18.00, 'Secure underground parking per night'),
('City Tour',     45.00, 'Half-day guided city sightseeing tour'),
('Baby Cot',       8.00, 'Baby cot and accessories for families');

-- BOOKING_SERVICE
INSERT INTO BOOKING_SERVICE (booking_id, service_id, quantity) VALUES
(1, 1, 3),   -- Booking 1: 3x Breakfast
(1, 2, 1),   -- Booking 1: 1x Spa
(2, 1, 3),   -- Booking 2: 3x Breakfast
(2, 3, 2),   -- Booking 2: 2x Laundry
(3, 1, 4),   -- Booking 3: 4x Breakfast
(3, 2, 2),   -- Booking 3: 2x Spa
(3, 4, 1),   -- Booking 3: 1x Airport Pickup
(5, 5, 4),   -- Booking 5: 4x Room Service
(6, 1, 2),   -- Booking 6: 2x Breakfast
(7, 9, 1);   -- Booking 7: 1x City Tour

-- INVOICE
INSERT INTO INVOICE (booking_id, issue_date, total_due, payment_status, payment_method) VALUES
(1,  '2026-01-13',  225.00, 'Paid',      'Card'),
(2,  '2026-01-18',  306.00, 'Paid',      'Cash'),
(3,  '2026-02-05',  930.00, 'Paid',      'Online'),
(4,  '2026-02-12',  130.00, 'Cancelled', 'Card'),
(5,  '2026-02-24',  880.00, 'Pending',   'Online'),
(6,  '2026-03-03',  220.00, 'Pending',   'Card'),
(7,  '2026-03-10', 1145.00, 'Pending',   'Online'),
(8,  '2026-03-14',  168.00, 'Pending',   'Cash'),
(9,  '2026-03-23',  375.00, 'Pending',   'Card'),
(10, '2026-04-04',  324.00, 'Pending',   'Online');


-- ============================================================
--  STEP 4: UPDATE STATEMENTS (2.3)
-- ============================================================

-- UPDATE 1: Guest updates their phone number
UPDATE GUEST
SET   phone = '+33601999000'
WHERE guest_id = 1;

-- UPDATE 2: Room 203 returns from maintenance to Available
UPDATE ROOM
SET   status = 'Available'
WHERE room_number = '203';

-- UPDATE 3: Increase all Suite prices by 10%
UPDATE ROOM
SET   price_per_night = ROUND(price_per_night * 1.10, 2)
WHERE room_type = 'Suite';

-- UPDATE 4: Mark booking 4 invoice as Cancelled
UPDATE INVOICE
SET   payment_status = 'Cancelled'
WHERE booking_id = 4;

-- UPDATE 5: Booking 9 is now completed
UPDATE BOOKING
SET   booking_status = 'Completed'
WHERE booking_id = 9;


-- ============================================================
--  STEP 5: DELETE STATEMENTS (2.3)
-- ============================================================

-- DELETE 1: Remove a service from a booking (safe — no child FKs)
DELETE FROM BOOKING_SERVICE
WHERE booking_id = 7 AND service_id = 9;

-- DELETE 2: Remove the cancelled booking (booking_id = 4)
-- Must delete INVOICE row first (FK on INVOICE references BOOKING)
DELETE FROM INVOICE  WHERE booking_id = 4;
DELETE FROM BOOKING  WHERE booking_id = 4;


-- ============================================================
--  STEP 6: REFERENTIAL INTEGRITY VIOLATION DEMO (2.3)
-- ============================================================

-- This will intentionally FAIL — showing FK protection in action.
-- Guest 5 (Ethan Johnson) has an active booking (booking_id = 5).
-- MySQL will throw: ERROR 1451 — Cannot delete or update a parent row.

-- DELETE FROM GUEST WHERE guest_id = 5;
-- ^ Uncomment the line above to see the error.
--   To fix it properly: delete the booking first, then the guest.


-- ============================================================
--  STEP 7: SELECT QUERIES (2.4)
-- ============================================================

-- Q1 [1 mark] — Retrieve all records from a table
SELECT * FROM ROOM;


-- Q2 [1 mark] — Specific columns with WHERE condition
SELECT first_name, last_name, email
FROM   GUEST
WHERE  nationality = 'French';


-- Q3 [1 mark] — Sorted results using ORDER BY
SELECT room_number, room_type, price_per_night
FROM   ROOM
ORDER BY price_per_night DESC;


-- Q4 [1 mark] — Limited results using LIMIT
SELECT room_number, room_type, price_per_night
FROM   ROOM
ORDER BY price_per_night DESC
LIMIT 3;


-- Q5 [2 marks] — BETWEEN, LIKE, IN

-- BETWEEN: bookings with total_amount between 200 and 900
SELECT booking_id, guest_id, total_amount
FROM   BOOKING
WHERE  total_amount BETWEEN 200 AND 900;

-- LIKE: guests whose email ends with 'mail.com'
SELECT first_name, last_name, email
FROM   GUEST
WHERE  email LIKE '%mail.com';

-- IN: invoices that are Paid or Cancelled
SELECT invoice_id, booking_id, payment_status
FROM   INVOICE
WHERE  payment_status IN ('Paid', 'Cancelled');


-- Q6 [2 marks] — INNER JOIN across two tables
-- Returns only bookings that have a matching guest (all rows here due to FK)
SELECT B.booking_id,
       G.first_name, G.last_name,
       B.check_in_date, B.check_out_date,
       B.total_amount, B.booking_status
FROM   BOOKING B
INNER JOIN GUEST G ON B.guest_id = G.guest_id;


-- Q7 [2 marks] — LEFT JOIN (vs INNER JOIN explanation)
-- Returns ALL guests; guests with no bookings show NULL in booking columns.
-- INNER JOIN would hide guests who never made a booking.
SELECT G.guest_id, G.first_name, G.last_name,
       B.booking_id, B.booking_status
FROM   GUEST G
LEFT JOIN BOOKING B ON G.guest_id = B.guest_id;


-- Q8 [3 marks] — JOIN across three or more tables
-- Full booking summary: guest + room + services + invoice (5 tables)
SELECT G.first_name, G.last_name,
       R.room_number, R.room_type,
       B.check_in_date, B.check_out_date,
       S.service_name, BS.quantity,
       I.total_due, I.payment_status
FROM        BOOKING         B
JOIN        GUEST           G  ON B.guest_id   = G.guest_id
JOIN        ROOM            R  ON B.room_id    = R.room_id
LEFT JOIN   BOOKING_SERVICE BS ON B.booking_id = BS.booking_id
LEFT JOIN   SERVICE         S  ON BS.service_id = S.service_id
LEFT JOIN   INVOICE         I  ON B.booking_id  = I.booking_id
ORDER BY B.booking_id;


-- Q9 [2 marks] — IS NULL and IS NOT NULL

-- IS NULL: bookings that have no invoice yet
SELECT B.booking_id, B.guest_id, B.booking_status
FROM   BOOKING B
LEFT JOIN INVOICE I ON B.booking_id = I.booking_id
WHERE  I.invoice_id IS NULL;

-- IS NOT NULL: guests who provided a phone number
SELECT first_name, last_name, phone
FROM   GUEST
WHERE  phone IS NOT NULL;


-- ============================================================
--  END OF SCRIPT
-- ============================================================
