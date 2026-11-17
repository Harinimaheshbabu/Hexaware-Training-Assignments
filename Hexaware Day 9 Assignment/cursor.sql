USE telecom_db;

CREATE TABLE IF NOT EXISTS notifications (
    notification_id INT PRIMARY KEY AUTO_INCREMENT,
    subscriber_id INT,
    message VARCHAR(100),
    notification_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (subscriber_id) REFERENCES subscribers(subscriber_id)
);

DROP PROCEDURE IF EXISTS sp_low_balance_cursor;

DELIMITER $$

CREATE PROCEDURE sp_low_balance_cursor()
BEGIN
    DECLARE v_subscriber_id INT;
    DECLARE v_done INT DEFAULT 0;

    DECLARE subscriber_cursor CURSOR FOR
        SELECT subscriber_id
        FROM subscribers
        WHERE connection_type = 'PREPAID'
          AND balance < 50;

    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET v_done = 1;

    OPEN subscriber_cursor;

    read_loop: LOOP
        FETCH subscriber_cursor INTO v_subscriber_id;

        IF v_done = 1 THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO notifications (subscriber_id, message)
        VALUES (
            v_subscriber_id,
            'Your balance is below 50. Please recharge.'
        );
    END LOOP;

    CLOSE subscriber_cursor;
END $$

DELIMITER ;

DELETE FROM notifications;

SET @start_time = NOW(6);
CALL sp_low_balance_cursor();
SET @cursor_time = TIMESTAMPDIFF(MICROSECOND, @start_time, NOW(6));

SELECT * FROM notifications;
SELECT @cursor_time AS cursor_time_microseconds;

DELETE FROM notifications;

SET @start_time = NOW(6);

INSERT INTO notifications (subscriber_id, message)
SELECT
    subscriber_id,
    'Your balance is below 50. Please recharge.'
FROM subscribers
WHERE connection_type = 'PREPAID'
  AND balance < 50;

SET @set_time = TIMESTAMPDIFF(MICROSECOND, @start_time, NOW(6));

SELECT * FROM notifications;
SELECT @set_time AS set_based_time_microseconds;
