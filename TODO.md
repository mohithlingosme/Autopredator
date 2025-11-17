# Database Setup TODO

## Overview
Set up PostgreSQL database for the Autopredator project, convert MySQL schema to PostgreSQL, integrate additional tables, insert sample data, and configure environment variables.

## Steps

### 1. Set up PostgreSQL database
- [x] Install PostgreSQL on the system (PostgreSQL 18.1 installed at C:\Program Files\PostgreSQL\18).
- [x] Start PostgreSQL service.
- [x] Create a new database named 'autopredator' using psql or pgAdmin.

### 2. Convert and run MySQL schema to PostgreSQL
- [ ] Convert the users table from 'autopredator (1).sql' (MySQL) to PostgreSQL syntax.
  - Change `int(11) NOT NULL AUTO_INCREMENT` to `SERIAL PRIMARY KEY`.
  - Change `enum('Buyer','Seller','Dealer')` to `VARCHAR(20) CHECK (user_type IN ('Buyer','Seller','Dealer'))`.
  - Change `datetime DEFAULT current_timestamp()` to `TIMESTAMP DEFAULT CURRENT_TIMESTAMP`.
  - Ensure UNIQUE on email.
- [ ] Integrate additional tables from 'backend/schema.sql' (vehicles, vehicle_listings, etc.) into the schema.
- [ ] Update 'backend/schema.sql' with the converted users table and any necessary adjustments for compatibility.
- [ ] Run the updated schema on the PostgreSQL database using psql.

### 3. Insert sample data into database tables
- [ ] Convert sample data from 'sample_data.sql' (MySQL inserts for users) to PostgreSQL syntax.
- [ ] Create PostgreSQL INSERT statements for sample data from 'backend/src/data/sampleData.ts' (vehicles, vehicle_listings, etc.).
- [ ] Execute the INSERT statements on the database to populate tables with sample data.

### 4. Configure backend environment variables
- [ ] Create a '.env' file in the 'backend' directory.
- [ ] Add DATABASE_URL in the format: `DATABASE_URL=postgresql://username:password@localhost:5432/autopredator`
- [ ] Ensure the backend can connect using the configured URL (test with backend scripts if needed).

## Notes
- Backend uses 'pg' library for PostgreSQL connection.
- Verify all tables are created and data inserted correctly.
- Test database connection from backend.
cr