import pyodbc

connectionString = f'DRIVER={{ODBC Driver 18 for SQL Server}};SERVER=db;UID=SA;PWD=2uio4yfg4302]JJ;Encrypt=Yes;TrustServerCertificate=Yes;'

cursor = pyodbc.connect(connectionString).cursor()
cursor.execute('SELECT name FROM master.sys.databases')
records = cursor.fetchall()
for r in records:
    print(r)
