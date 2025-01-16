-- generate a table for products which contains a product ID, a product Name, a product description, and a product price
CREATE TABLE IF NOT EXISTS products (
  product_id INT PRIMARY KEY,
  product_name STRING,
  product_description STRING,
  product_price DECIMAL(10, 2)
);

-- generate a table for customers which contains a customer ID, a customer Name, and a customer email
CREATE TABLE IF NOT EXISTS customers (
  customer_id INT PRIMARY KEY,
  customer_name STRING,
  customer_email STRING
);

-- generate a table for orders which contains an order ID, a customer ID, a product ID, a quantity, an order date, a shipped date, and a tracking number
CREATE TABLE IF NOT EXISTS orders (
  order_id INT PRIMARY KEY,
  customer_id INT,
  order_date DATE,
  shipped_date DATE,
  tracking_number STRING
);

-- generate an invoice table which will map multiple products and the quantity ordered to an order ID
CREATE TABLE IF NOT EXISTS invoice (
  order_id INT,
  product_id INT,
  quantity INT
);

-- generate a table for inventory which contains a product ID, a quantity, and a last updated timestamp
CREATE TABLE IF NOT EXISTS inventory (
  product_id INT PRIMARY KEY,
  quantity INT,
  last_updated TIMESTAMP
);



-- write a stored procedure which updates the available quantity of a product in the inventory table given the product ID and the quantity to add to the existing inventory value, also update the last updated timestamp
CREATE OR REPLACE PROCEDURE update_inventory(product_id INT, quantity INT)
LANGUAGE SQL
AS $$
  UPDATE inventory
  SET quantity = quantity + $2, last_updated = CURRENT_TIMESTAMP
  WHERE product_id = $1;
$$;

-- write a stored procedure which returns the quantity of a product in the inventory table given the product ID
CREATE OR REPLACE PROCEDURE get_inventory(product_id INT)
RETURNS TABLE (quantity INT)
LANGUAGE SQL
AS $$
  SELECT quantity
  FROM inventory
  WHERE product_id = $1;
$$;

-- Add an index to improve the performance of the above stored procedure's select query
CREATE INDEX IF NOT EXISTS inventory_product_id_index ON inventory (product_id);


-- write a stored procedure which will list all orders for a given customer ID
CREATE OR REPLACE PROCEDURE list_orders(customer_id INT)
RETURNS TABLE (order_id INT, order_date DATE)
LANGUAGE SQL
AS $$
  SELECT order_id, order_date
  FROM orders
  WHERE customer_id = $1;
$$;

-- write a stored procedure to create an order given a customer ID, assigning today's date as the order date
CREATE OR REPLACE PROCEDURE create_order(customer_id INT)
LANGUAGE SQL
AS $$
  INSERT INTO orders (order_id, customer_id, order_date)
  VALUES (NEXTVAL('order_id_seq'), $1, CURRENT_DATE);
$$;

-- write a stored procedure to add a given quantity of a product ID to an order given an order ID
-- check using the get_inventory stored procedure that the quantity of the product is available in the inventory table
-- update the inventory table using the update_inventory stored procedure decrementing available quantity by the quantity of the product in the order
-- insert the product ID and quantity into the invoice table
CREATE OR REPLACE PROCEDURE add_product_to_order(order_id INT, product_id INT, quantity INT)
LANGUAGE SQL
AS $$
  DECLARE
    available_quantity INT;
  BEGIN
    FOR row IN
      SELECT quantity
      FROM get_inventory(product_id)
    LOOP
      available_quantity := row.quantity;
    END LOOP;

    IF available_quantity >= quantity THEN
      CALL update_inventory(product_id, -quantity);
      INSERT INTO invoice (order_id, product_id, quantity)
      VALUES (order_id, product_id, quantity);
    ELSE
      RAISE EXCEPTION 'Insufficient quantity in inventory';
    END IF;
  END;
$$;

-- write a stored procedure to ship an order given an order ID, assigning today's date as the shipped date
-- also accept the tracking number of the shipment, updating the orders table with that tracking number
CREATE OR REPLACE PROCEDURE ship_order(order_id INT, tracking_number STRING)
LANGUAGE SQL
AS $$
  UPDATE orders
  SET shipped_date = CURRENT_DATE, tracking_number = $2
  WHERE order_id = $1;
$$;






