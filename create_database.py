import mysql.connector
from pathlib import Path
from getpass import getpass

password = getpass("MySQL password: ")
BASE_DIR = Path(__file__).resolve().parent

connection = mysql.connector.connect(
    host="localhost",
    user="root",
    password=password
)

cursor = connection.cursor()

with open(BASE_DIR / "schema.sql", "r") as file:
    sql_script = file.read()

# Execute each SQL statement
for statement in sql_script.split(";"):
    statement = statement.strip()
    if statement:
        cursor.execute(statement)

connection.commit()

cursor.close()
connection.close()

print("Database and tables created successfully!")