-- Day 8 - Airline Seat Booking
-- MySQL 8.4 LTS
-- File: ranking_report.sql

USE airline_booking;

-- Check booking records
SELECT COUNT(*) AS total_bookings
FROM bookings;


-- TASK 3: RANK and DENSE_RANK

SELECT
    f.flight_no,
    p.passenger_name,
    b.fare,
    RANK() OVER (
        PARTITION BY f.flight_id
        ORDER BY b.fare DESC
    ) AS fare_rank,
    DENSE_RANK() OVER (
        PARTITION BY f.flight_id
        ORDER BY b.fare DESC
    ) AS fare_dense_rank
FROM bookings b
INNER JOIN passengers p ON b.passenger_id = p.passenger_id
INNER JOIN seats s ON b.seat_id = s.seat_id
INNER JOIN flights f ON s.flight_id = f.flight_id
ORDER BY f.flight_no, b.fare DESC, b.booking_id;


-- TASK 4: CTE with Running Revenue

WITH flight_bookings AS (
    SELECT
        f.flight_id,
        f.flight_no,
        p.passenger_name,
        b.booking_id,
        b.fare,
        RANK() OVER (
            PARTITION BY f.flight_id
            ORDER BY b.fare DESC
        ) AS fare_rank
    FROM bookings b
    INNER JOIN passengers p ON b.passenger_id = p.passenger_id
    INNER JOIN seats s ON b.seat_id = s.seat_id
    INNER JOIN flights f ON s.flight_id = f.flight_id
)
SELECT
    flight_no,
    passenger_name,
    fare,
    fare_rank,
    SUM(fare) OVER (
        PARTITION BY flight_id
        ORDER BY booking_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_revenue
FROM flight_bookings
ORDER BY flight_no, booking_id;


-- TASK 5: Correlated Subquery

SELECT
    p.passenger_name,
    f.flight_no,
    b.fare,
    (SELECT ROUND(AVG(b2.fare), 2)
     FROM bookings b2
     INNER JOIN seats s2 ON b2.seat_id = s2.seat_id
     WHERE s2.flight_id = s.flight_id
    ) AS flight_avg_fare
FROM bookings b
INNER JOIN passengers p ON b.passenger_id = p.passenger_id
INNER JOIN seats s ON b.seat_id = s.seat_id
INNER JOIN flights f ON s.flight_id = f.flight_id
WHERE b.fare > (
    SELECT AVG(b2.fare)
    FROM bookings b2
    INNER JOIN seats s2 ON b2.seat_id = s2.seat_id
    WHERE s2.flight_id = s.flight_id
)
ORDER BY f.flight_no, b.fare DESC;
