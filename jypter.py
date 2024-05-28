import pandas as pd
import pyodbc
import json

# Read the JSON file
with open('sales.json') as file:
    data = json.load(file)

# Convert the JSON data to a pandas DataFrame
df = pd.DataFrame(data)

# Convert the date column to datetime
df['date'] = pd.to_datetime(df['date'])

# Calculate the sales for each week
df['week'] = df['date'].dt.week
weekly_sales = df.groupby('week')['sales'].sum().reset_index()

# Connect to MSSQL Server
conn = pyodbc.connect('DRIVER={SQL Server};SERVER=<server_name>;DATABASE=<database_name>;UID=<username>;PWD=<password>')

# Create a cursor object
cursor = conn.cursor()

# Create a table to store the output data
cursor.execute('CREATE TABLE WeeklySales (Week INT, Sales FLOAT)')

# Insert the weekly sales data into the table
for index, row in weekly_sales.iterrows():
    cursor.execute('INSERT INTO WeeklySales (Week, Sales) VALUES (?, ?)', row['week'], row['sales'])

# Commit the changes and close the connection
conn.commit()
conn.close()