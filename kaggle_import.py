import kagglehub
import duckdb
import os

# Download dataset (only needs to run once — cached after that)
path = kagglehub.dataset_download("olistbr/brazilian-ecommerce")
print("Path to dataset files:", path)

# This connects to (or creates) the DuckDB file in your project folder
db_path = r"C:\Users\User\Documents\Dataskools\olist-e-commerce-dataset\olist-dataset.duckdb"
con = duckdb.connect(db_path)

# Load every CSV in the downloaded folder as its own table
files = [f for f in os.listdir(path) if f.endswith(".csv")]
for file in files:
    table_name = file.replace(".csv", "").replace("-", "_")
    full_path = os.path.join(path, file).replace("\\", "/")
    con.execute(f"""
        CREATE OR REPLACE TABLE {table_name} AS
        SELECT * FROM read_csv_auto('{full_path}')
    """)
    print(f"Loaded {table_name}")

print(con.execute("SHOW TABLES").fetchall())
con.close()
