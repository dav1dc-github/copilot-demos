-- A SQL table that will be used to store the members of a mailing list
-- The table will have the following columns:
-- 1. email address which is also the primary key for the database table
-- 2. first name
-- 3. last name
-- 4. date subscribed to the mailing list
-- 5. date unsubscribed from the mailing list
-- 6. reason for unsubscribing from the mailing list
-- 7. subscription status boolean (true if subscribed, false if unsubscribed)

CREATE TABLE mailing_list (
  email_address VARCHAR(255) PRIMARY KEY,
  first_name VARCHAR(255),
  last_name VARCHAR(255),
  date_subscribed DATE,
  date_unsubscribed DATE,
  reason_unsubscribed VARCHAR(255),
  subscription_status BOOLEAN
);

-- A SQL storec procedure that will be used to add a new member to the mailing list
-- The stored procedure will have the following parameters:
-- 1. email address
-- 2. first name
-- 3. last name
-- automatically set the date subscribed to the current date
-- automatically set the subscription status to true

CREATE PROCEDURE add_member_to_mailing_list (
    IN email_address VARCHAR(255),
    IN first_name VARCHAR(255),
    IN last_name VARCHAR(255)
)
BEGIN
    DECLARE email_exists INT;
    
    SELECT COUNT(*) INTO email_exists
    FROM mailing_list
    WHERE email_address = email_address AND subscription_status = TRUE;
    
    IF email_exists > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email address is already subscribed';
    ELSE
        INSERT INTO mailing_list (email_address, first_name, last_name, date_subscribed, subscription_status)
        VALUES (email_address, first_name, last_name, CURDATE(), TRUE);
    END IF;
END;
/

-- A SQL stored procedure that will be used to remove a member from the mailing list
-- The stored procedure will have the following parameters:
-- 1. email address
-- 2. reason for ubsubscribing 
-- automatically set the date unsubscribed to the current date
-- automatically set the subscription status to false
-- throw an exception if the email address is not found in the mailing list
-- throw an exception if the email address is already unsubscribed

CREATE PROCEDURE remove_member_from_mailing_list (
    IN email_address VARCHAR(255),
    IN reason_unsubscribed VARCHAR(255)
)
BEGIN
    DECLARE email_exists INT;
    DECLARE is_subscribed BOOLEAN;
    
    SELECT COUNT(*), subscription_status INTO email_exists, is_subscribed
    FROM mailing_list
    WHERE email_address = email_address;
    
    IF email_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email address not found in the mailing list';
    ELSEIF is_subscribed = FALSE THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email address is already unsubscribed';
    ELSE
        UPDATE mailing_list
        SET date_unsubscribed = CURDATE(), reason_unsubscribed = reason_unsubscribed, subscription_status = FALSE
        WHERE email_address = email_address;
    END IF;
END;
/