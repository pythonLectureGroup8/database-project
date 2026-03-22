-- ============================================================
-- CS27 Hotel Booking System
-- Part 3 -- Aggregate Functions & Reporting [15 marks]
-- Scenario : Hotel Booking System
-- Database : hotel_booking_db
-- Instructor: Kweyakie Afi Blebo | blebo.kweyakie@bit.bf
-- ============================================================

USE hotel_booking_db;

-- ============================================================
-- Q1 [2 marks] -- COUNT: Total Records in a Table
-- ============================================================

-- Count all guests
SELECT COUNT(*) AS total_guests
FROM GUEST;

-- Count all bookings
SELECT COUNT(*) AS total_bookings
FROM BOOKING;

-- Count all available services
SELECT COUNT(*) AS total_services
FROM SERVICE;

-- Expected results:
-- total_guests  = 10
-- total_bookings = 10
-- total_services = 10


-- ============================================================
-- Q2 [2 marks] -- MAX and MIN of a Numeric Column
-- ============================================================

-- Most and least expensive room per night
SELECT
    MAX(price_per_night) AS most_expensive_room,
    MIN(price_per_night) AS cheapest_room
FROM ROOM;

-- Highest and lowest booking total
SELECT
    MAX(total_amount) AS highest_booking,
    MIN(total_amount) AS lowest_booking
FROM BOOKING;

-- Expected results:
-- most_expensive_room = 220.00  (Room 303, Suite)
-- cheapest_room       =  60.00  (Room 101, Single)
-- highest_booking     = 1100.00 (Booking 7 - George, Suite 303)
-- lowest_booking      =  130.00 (Booking 4 - Diana, Single 102, Cancelled)


-- ============================================================
-- Q3 [2 marks] -- AVG of a Numeric Column
-- ============================================================

-- Average room price per night
SELECT ROUND(AVG(price_per_night), 2) AS avg_room_price
FROM ROOM;

-- Average booking total
SELECT ROUND(AVG(total_amount), 2) AS avg_booking_total
FROM BOOKING;

-- Average invoice amount due
SELECT ROUND(AVG(total_due), 2) AS avg_invoice_due
FROM INVOICE;

-- Expected results:
-- avg_room_price    = 121.00
-- avg_booking_total = 416.00
-- avg_invoice_due   = 470.30
-- Note: avg_invoice_due > avg_booking_total because invoices
--       include the cost of additional services (Breakfast, Spa, etc.)


-- ============================================================
-- Q4 [3 marks] -- GROUP BY with an Aggregate Function
-- ============================================================

-- 4a: Number of bookings per booking status
SELECT booking_status,
       COUNT(*) AS booking_count
FROM BOOKING
GROUP BY booking_status;

-- Expected:
-- Confirmed  = 6
-- Completed  = 3
-- Cancelled  = 1

-- 4b: Total revenue generated per room type
SELECT R.room_type,
       COUNT(B.booking_id)          AS total_bookings,
       SUM(B.total_amount)          AS total_revenue,
       ROUND(AVG(B.total_amount),2) AS avg_booking_amount
FROM BOOKING B
JOIN ROOM R ON B.room_id = R.room_id
GROUP BY R.room_type
ORDER BY total_revenue DESC;

-- Expected:
-- Suite  | 3 bookings | 2620.00 | 873.33
-- Double | 4 bookings | 1490.00 | 372.50
-- Single | 3 bookings |  450.00 | 150.00

-- 4c: Total quantity of services ordered per booking
SELECT booking_id,
       COUNT(service_id)  AS distinct_services,
       SUM(quantity)      AS total_service_units
FROM BOOKING_SERVICE
GROUP BY booking_id
ORDER BY total_service_units DESC;

-- Expected (top rows):
-- booking_id=3 | 3 distinct services | 7 units  (4xBreakfast, 2xSpa, 1xAirport Pickup)
-- booking_id=2 | 2 distinct services | 5 units
-- booking_id=1 | 2 distinct services | 4 units
-- booking_id=5 | 1 distinct service  | 4 units


-- ============================================================
-- Q5 [3 marks] -- HAVING to Filter Grouped Results
-- ============================================================

-- 5a: Room types where average booking total exceeds 300.00
SELECT R.room_type,
       ROUND(AVG(B.total_amount), 2) AS avg_booking_total
FROM BOOKING B
JOIN ROOM R ON B.room_id = R.room_id
GROUP BY R.room_type
HAVING AVG(B.total_amount) > 300.00;

-- Expected:
-- Suite  | 873.33
-- Double | 372.50
-- (Single = 150.00 is excluded by HAVING)

-- 5b: Guests who have made more than 1 booking
SELECT G.guest_id,
       CONCAT(G.first_name, ' ', G.last_name) AS guest_name,
       COUNT(B.booking_id) AS booking_count
FROM GUEST G
JOIN BOOKING B ON G.guest_id = B.guest_id
GROUP BY G.guest_id, G.first_name, G.last_name
HAVING COUNT(B.booking_id) > 1;

-- Expected: empty set
-- Each guest_id appears exactly once in BOOKING (Part 2 data).
-- The empty result correctly demonstrates HAVING filtering when
-- no group meets the threshold.

-- 5c: Services ordered more than once (total quantity > 1)
SELECT S.service_name,
       SUM(BS.quantity) AS total_ordered
FROM BOOKING_SERVICE BS
JOIN SERVICE S ON BS.service_id = S.service_id
GROUP BY S.service_name
HAVING SUM(BS.quantity) > 1
ORDER BY total_ordered DESC;

-- Expected:
-- Breakfast    | 12  (ordered across 4 bookings)
-- Room Service |  4
-- Spa          |  3
-- Laundry      |  2
-- (Airport Pickup, City Tour excluded: each ordered only once)


-- ============================================================
-- Q6 [3 marks] -- Summary Report: JOIN + GROUP BY + HAVING
-- ============================================================

-- Full guest financial report:
-- For each guest: name, nationality, number of bookings,
-- total room cost, total service cost, total invoiced amount.
-- Filter: only guests whose total invoiced amount exceeds 200.00.

SELECT
    G.guest_id,
    CONCAT(G.first_name, ' ', G.last_name)  AS guest_name,
    G.nationality,
    COUNT(DISTINCT B.booking_id)             AS total_bookings,
    SUM(B.total_amount)                      AS total_room_cost,
    COALESCE(SUM(BS.quantity * S.price), 0)  AS total_service_cost,
    SUM(I.total_due)                         AS total_invoiced
FROM GUEST G
JOIN      BOOKING          B  ON G.guest_id   = B.guest_id
JOIN      INVOICE          I  ON B.booking_id = I.booking_id
LEFT JOIN BOOKING_SERVICE  BS ON B.booking_id = BS.booking_id
LEFT JOIN SERVICE          S  ON BS.service_id = S.service_id
GROUP BY G.guest_id, G.first_name, G.last_name, G.nationality
HAVING SUM(I.total_due) > 200.00
ORDER BY total_invoiced DESC;

-- Expected results (ordered by total_invoiced DESC):
-- guest_id | guest_name              | nationality | bookings | room_cost | svc_cost | invoiced
--        7 | George Papadopoulos     | Greek       |        1 |   1100.00 |    45.00 | 1145.00
--        3 | Carlos Diaz             | Spanish     |        1 |    720.00 |   210.00 |  930.00
--        5 | Ethan Johnson           | American    |        1 |    800.00 |    80.00 |  880.00
--        9 | Ivan Petrov             | Russian     |        1 |    330.00 |    45.00 |  375.00
--        2 | Bob Smith               | British     |        1 |    270.00 |    36.00 |  306.00
--       10 | Jasmine Osei            | Ghanaian    |        1 |    300.00 |    24.00 |  324.00
--        6 | Fatima El-Amin          | Moroccan    |        1 |    190.00 |    30.00 |  220.00
--        1 | Alice Martin            | French      |        1 |    180.00 |    45.00 |  225.00
--
-- Excluded: Diana Nguyen (booking_id=4, Cancelled, total_due=130.00 < 200.00)
--
-- Notes:
-- JOIN BOOKING + INVOICE  : links each guest to their payment obligation
-- LEFT JOIN BOOKING_SERVICE + SERVICE : adds service revenue (COALESCE
--   ensures guests with no services return 0 instead of NULL)
-- GROUP BY   : aggregates all costs per guest
-- HAVING     : filters out guests whose total invoiced < 200.00

-- ============================================================
-- End of Part 3 -- Aggregate Functions & Reporting [15 marks]
-- CS27 -- Computer Science Dept | Burkina Institute of Technology
-- ============================================================
