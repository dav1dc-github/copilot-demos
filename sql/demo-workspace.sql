-- Generate a SQL table for storing customers data including customer ID, customer name, and customer email, country of residence, and the date the customer was added to the database
CREATE TABLE IF NOT EXISTS customers (
  customer_id INT PRIMARY KEY,
  customer_name STRING,
  customer_email STRING,
  country STRING,
  date_added DATE
);

-- Generate a SQL table for customer's portfolio value data including customer ID, portfolio value, and the date the portfolio value was recorded
CREATE TABLE IF NOT EXISTS portfolio_value (
  customer_id INT,
  portfolio_value FLOAT,
  date_recorded DATE
);

-- Gneerate a SQL table for the customer's trades that they have bought and sold including the price at the time of the transaction, the quantity of the transaction, the date of the transaction, and the type of transaction (buy or sell)
CREATE TABLE IF NOT EXISTS trades (
  customer_id INT,
  price FLOAT,
  quantity INT,
  date DATE,
  type STRING
);

-- Generate a SQL Table for the customer's holdings include the stock symbol, the quantity of the stock held, and the date the holding was recorded, and add current price of the stock
CREATE TABLE IF NOT EXISTS holdings (
  customer_id INT,
  stock_symbol STRING,
  quantity INT,
  date DATE,
  current_price FLOAT
);



-- Write a Stored Procedure that returns the total number of trades a customer has made given the customer ID
CREATE OR REPLACE PROCEDURE get_total_trades(customer_id INT)
RETURNS TABLE (total_trades INT)
LANGUAGE SQL
AS $$
    SELECT COUNT(*)
    FROM trades
    WHERE customer_id = $1;
$$;

-- Create an index on the customer_id column in the trades table to improve the performance of the stored procedure
CREATE INDEX idx_trades_customer_id ON trades (customer_id);



-- Write a Stored Procedure to Validate a Sell order such that the customer ID has enough of the stock to sell,
-- throw an error if the customer ID does not exist
CREATE OR REPLACE PROCEDURE validate_sell_order(customer_id INT, stock_symbol STRING, quantity INT)
RETURNS STRING
LANGUAGE SQL
AS $$
    DECLARE
        total_stock INT;
        customer_exists INT;
    BEGIN
        -- check if the customer exists
        SELECT COUNT(*) INTO customer_exists
        FROM customers
        WHERE customer_id = $1;

        IF customer_exists = 0 THEN
            RETURN 'Customer does not exist';
        END IF;

        -- check if the customer has enough of the stock to sell
        SELECT SUM(quantity) INTO total_stock
        FROM holdings
        WHERE customer_id = $1 AND stock_symbol = $2;

        IF total_stock IS NULL THEN
            RETURN 'Customer does not own any of the stock';
        END IF;

        IF total_stock < $3 THEN
            RETURN 'Customer does not have enough of the stock to sell';
        END IF;

        RETURN 'Sell order is valid';
    END;
$$;

-- Create an index on the customer_id and stock_symbol columns in the holdings table to improve the performance of the stored procedure
CREATE INDEX idx_holdings_customer_stock ON holdings (customer_id, stock_symbol);

