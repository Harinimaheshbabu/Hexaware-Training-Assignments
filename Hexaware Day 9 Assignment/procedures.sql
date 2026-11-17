USE telecom_db;

CREATE TABLE IF NOT EXISTS plans (
    plan_id INT PRIMARY KEY,
    plan_name VARCHAR(50),
    min_amount DECIMAL(10,2),
    validity_days INT
);

INSERT IGNORE INTO plans VALUES
(1, 'Basic Plan', 50.00, 28),
(2, 'Standard Plan', 100.00, 56),
(3, 'Premium Plan', 200.00, 84);

DROP PROCEDURE IF EXISTS sp_recharge;
DROP FUNCTION IF EXISTS fn_validity_days_left;

DELIMITER $$

CREATE PROCEDURE sp_recharge(
    IN p_subscriber_id INT,
    IN p_plan_id INT,
    IN p_amount DECIMAL(10,2),
    OUT p_new_balance DECIMAL(10,2)
)
BEGIN
    DECLARE v_min_amount DECIMAL(10,2);
    DECLARE v_validity INT;
    DECLARE v_count INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    IF p_amount <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Recharge amount must be greater than zero';
    END IF;

    SELECT COUNT(*) INTO v_count
    FROM subscribers
    WHERE subscriber_id = p_subscriber_id
      AND connection_type = 'PREPAID';

    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid or non-prepaid subscriber';
    END IF;

    SELECT COUNT(*) INTO v_count
    FROM plans
    WHERE plan_id = p_plan_id;

    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid recharge plan';
    END IF;

    SELECT min_amount, validity_days
    INTO v_min_amount, v_validity
    FROM plans
    WHERE plan_id = p_plan_id;

    IF p_amount < v_min_amount THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Recharge amount is below plan minimum';
    END IF;

    UPDATE subscribers
    SET balance = balance + p_amount,
        validity_date = DATE_ADD(
            GREATEST(validity_date, CURDATE()),
            INTERVAL v_validity DAY
        )
    WHERE subscriber_id = p_subscriber_id;

    INSERT INTO recharges
        (subscriber_id, recharge_amount, recharge_date)
    VALUES
        (p_subscriber_id, p_amount, CURDATE());

    SELECT balance INTO p_new_balance
    FROM subscribers
    WHERE subscriber_id = p_subscriber_id;

    COMMIT;
END $$

CREATE FUNCTION fn_validity_days_left(p_validity_date DATE)
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN GREATEST(DATEDIFF(p_validity_date, CURDATE()), 0);
END $$

DELIMITER ;

SELECT
    subscriber_name,
    validity_date,
    fn_validity_days_left(validity_date) AS days_left
FROM subscribers
WHERE connection_type = 'PREPAID';

SET @new_balance = 0;
CALL sp_recharge(1, 1, 100.00, @new_balance);
SELECT @new_balance AS new_balance;

-- Run separately to demonstrate the business error.
-- CALL sp_recharge(1, 99, 100.00, @new_balance);
