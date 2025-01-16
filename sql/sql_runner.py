#!/usr/bin/env python3

# connect to a postgresql database and execute the stored procedure list_orders from workspace.sql and pass in the value of customer_id into the stored procedure
def list_orders(customer_id):
    conn = psycopg2.connect(
        host=os.getenv("DB_HOST"),
        database=os.getenv("DB_NAME"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD"),
    )
    cur = conn.cursor()
    cur.callproc("list_orders", [customer_id])
    rows = cur.fetchall()
    cur.close()
    conn.close()
    return rows