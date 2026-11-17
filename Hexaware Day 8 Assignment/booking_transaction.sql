-- Day 8 - Airline Seat Booking

-- 1. DATABASE AND TABLES

DROP DATABASE IF EXISTS airline_booking;
CREATE DATABASE airline_booking;
USE airline_booking;

CREATE TABLE flights (
    flight_id INT PRIMARY KEY,
    flight_no VARCHAR(10) NOT NULL UNIQUE,
    origin VARCHAR(30) NOT NULL,
    destination VARCHAR(30) NOT NULL,
    departure_time DATETIME NOT NULL
) ENGINE = InnoDB;

CREATE TABLE seats (
    seat_id INT PRIMARY KEY,
    flight_id INT NOT NULL,
    seat_no VARCHAR(5) NOT NULL,
    seat_class VARCHAR(10) NOT NULL,
    status VARCHAR(10) DEFAULT 'AVAILABLE',
    CONSTRAINT uq_flight_seat UNIQUE (flight_id, seat_no),
    CONSTRAINT chk_seat_status CHECK (status IN ('AVAILABLE', 'BOOKED')),
    FOREIGN KEY (flight_id) REFERENCES flights(flight_id)
) ENGINE = InnoDB;

CREATE TABLE passengers (
    passenger_id INT PRIMARY KEY,
    passenger_name VARCHAR(50) NOT NULL,
    city VARCHAR(30)
) ENGINE = InnoDB;

CREATE TABLE bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    passenger_id INT NOT NULL,
    seat_id INT NOT NULL,
    fare DECIMAL(10,2) NOT NULL,
    booking_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_booking_seat UNIQUE (seat_id),
    FOREIGN KEY (passenger_id) REFERENCES passengers(passenger_id),
    FOREIGN KEY (seat_id) REFERENCES seats(seat_id)
) ENGINE = InnoDB;


-- 2. SAMPLE DATA

INSERT INTO flights VALUES
(1, 'SK201', 'Madurai', 'Chennai', '2026-12-10 07:15:00'),
(2, 'SK305', 'Chennai', 'Bengaluru', '2026-12-10 09:40:00'),
(3, 'SK412', 'Coimbatore', 'Mumbai', '2026-12-11 06:30:00'),
(4, 'SK518', 'Bengaluru', 'Delhi', '2026-12-11 14:05:00');

INSERT INTO passengers VALUES
(1, 'Aravind Subramanian', 'Madurai'),
(2, 'Meenakshi Sundaram', 'Madurai'),
(3, 'Karthik Raghavan', 'Dindigul'),
(4, 'Divya Bharathi', 'Trichy'),
(5, 'Mohammed Irfan', 'Chennai'),
(6, 'Lakshmi Narayanan', 'Chennai'),
(7, 'Pooja Venkatesh', 'Vellore'),
(8, 'Suresh Babu', 'Tiruvallur'),
(9, 'Nithin Krishnan', 'Coimbatore'),
(10, 'Ananya Iyer', 'Coimbatore'),
(11, 'Rohit Deshmukh', 'Pune'),
(12, 'Shruthi Menon', 'Palakkad'),
(13, 'Harish Gowda', 'Bengaluru'),
(14, 'Preethi Nair', 'Bengaluru'),
(15, 'Vikram Chauhan', 'Mysuru'),
(16, 'Janani Ramesh', 'Madurai'),
(17, 'Faisal Ahmed', 'Chennai'),
(18, 'Gayathri Prabhu', 'Chennai');

INSERT INTO seats VALUES
(1,1,'1A','BUSINESS','BOOKED'),
(2,1,'1B','BUSINESS','BOOKED'),
(3,1,'2A','ECONOMY','BOOKED'),
(4,1,'2B','ECONOMY','BOOKED'),
(5,1,'2C','ECONOMY','AVAILABLE'),
(6,2,'1A','BUSINESS','BOOKED'),
(7,2,'1B','BUSINESS','AVAILABLE'),
(8,2,'2A','ECONOMY','BOOKED'),
(9,2,'2B','ECONOMY','BOOKED'),
(10,2,'2C','ECONOMY','BOOKED'),
(11,3,'1A','BUSINESS','BOOKED'),
(12,3,'1B','BUSINESS','BOOKED'),
(13,3,'2A','ECONOMY','BOOKED'),
(14,3,'2B','ECONOMY','BOOKED'),
(15,3,'2C','ECONOMY','AVAILABLE'),
(16,4,'1A','BUSINESS','BOOKED'),
(17,4,'1B','BUSINESS','AVAILABLE'),
(18,4,'2A','ECONOMY','BOOKED'),
(19,4,'2B','ECONOMY','BOOKED'),
(20,4,'2C','ECONOMY','AVAILABLE');

INSERT INTO bookings
(booking_id, passenger_id, seat_id, fare, booking_time) VALUES
(1,1,1,6500,'2026-11-01 09:10:00'),
(2,2,2,6500,'2026-11-01 10:25:00'),
(3,3,3,3200,'2026-11-02 11:05:00'),
(4,4,4,2800,'2026-11-03 14:40:00'),
(5,5,6,8200,'2026-11-01 08:30:00'),
(6,6,8,5100,'2026-11-02 09:15:00'),
(7,7,9,5100,'2026-11-02 09:50:00'),
(8,8,10,4300,'2026-11-04 16:20:00'),
(9,9,11,12500,'2026-11-02 12:00:00'),
(10,10,12,9800,'2026-11-03 10:10:00'),
(11,11,13,6200,'2026-11-03 15:35:00'),
(12,12,14,5400,'2026-11-05 18:45:00'),
(13,13,16,10400,'2026-11-04 07:45:00'),
(14,14,18,6300,'2026-11-05 13:20:00'),
(15,15,19,5900,'2026-11-06 17:05:00');

SELECT COUNT(*) AS total_bookings FROM bookings;
SELECT COUNT(*) AS available_seats
FROM seats WHERE status = 'AVAILABLE';


-- 3. TASK 1 - BOOKING TRANSACTION

DROP PROCEDURE IF EXISTS book_seat;

DELIMITER $$

CREATE PROCEDURE book_seat(
    IN p_passenger_id INT,
    IN p_flight_id INT,
    IN p_seat_no VARCHAR(5),
    IN p_fare DECIMAL(10,2),
    OUT p_message VARCHAR(100)
)
BEGIN
    DECLARE v_seat_id INT DEFAULT NULL;
    DECLARE v_status VARCHAR(10) DEFAULT NULL;

    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET v_seat_id = NULL;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_message = 'Booking failed: transaction rolled back';
    END;

    START TRANSACTION;

    SELECT seat_id, status
    INTO v_seat_id, v_status
    FROM seats
    WHERE flight_id = p_flight_id
      AND seat_no = p_seat_no
    FOR UPDATE;

    IF v_seat_id IS NULL THEN
        ROLLBACK;
        SET p_message = 'Seat not found';

    ELSEIF v_status <> 'AVAILABLE' THEN
        ROLLBACK;
        SET p_message = 'Seat already booked';

    ELSE
        INSERT INTO bookings (passenger_id, seat_id, fare)
        VALUES (p_passenger_id, v_seat_id, p_fare);

        UPDATE seats
        SET status = 'BOOKED'
        WHERE seat_id = v_seat_id;

        COMMIT;
        SET p_message = 'Booking successful';
    END IF;
END$$

DELIMITER ;


-- Successful booking

CALL book_seat(16, 1, '2C', 3500.00, @msg);
SELECT @msg AS booking_result;

-- Already booked seat

CALL book_seat(17, 1, '1A', 6500.00, @msg);
SELECT @msg AS booking_result;

-- Invalid passenger: foreign key error

CALL book_seat(99, 3, '2C', 5400.00, @msg);
SELECT @msg AS booking_result;

-- Verify booking and seat status

SELECT s.seat_no, s.seat_class, s.status,
       b.booking_id, p.passenger_name, b.fare
FROM seats s
LEFT JOIN bookings b ON s.seat_id = b.seat_id
LEFT JOIN passengers p ON b.passenger_id = p.passenger_id
WHERE s.flight_id = 1
ORDER BY s.seat_id;

SELECT seat_no, status
FROM seats
WHERE flight_id = 3 AND seat_no = '2C';


-- 4. TASK 2 - TWO-SESSION EXPERIMENT
-- Run Session A and Session B in separate connections.

-- SESSION A - Step 1
-- USE airline_booking;
-- START TRANSACTION;
-- SELECT seat_id, seat_no, status
-- FROM seats
-- WHERE flight_id = 2 AND seat_no = '1B'
-- FOR UPDATE;

-- Keep the transaction open.

-- SESSION B - Step 2
-- USE airline_booking;
-- SET SESSION innodb_lock_wait_timeout = 120;
-- START TRANSACTION;
-- SELECT seat_id, seat_no, status
-- FROM seats
-- WHERE flight_id = 2 AND seat_no = '1B'
-- FOR UPDATE;

-- This query waits for Session A.

-- SESSION A - Step 3
-- INSERT INTO bookings (passenger_id, seat_id, fare)
-- VALUES (17, 7, 7800.00);
-- UPDATE seats SET status = 'BOOKED' WHERE seat_id = 7;
-- COMMIT;

-- SESSION B - Step 4
-- After the waiting query finishes:
-- SELECT seat_no, status FROM seats WHERE seat_id = 7;
-- ROLLBACK;

-- Optional: Check lock information from a third connection.
-- SELECT * FROM sys.innodb_lock_waits;

-- Final verification
SELECT s.seat_no, s.status, b.booking_id,
       p.passenger_name, b.fare
FROM seats s
LEFT JOIN bookings b ON s.seat_id = b.seat_id
LEFT JOIN passengers p ON b.passenger_id = p.passenger_id
WHERE s.seat_id = 7;

