BEGIN TRANSACTION;

-- 1. Create a table that will get dropped at the end of the transaction.
CREATE TEMPORARY TABLE to_import (
  tm SERIAL,
  "name" TEXT,
  "type" pokemon_type,
  category move_category,
  power INTEGER,
  acc INTEGER,
  pp INTEGER
) ON COMMIT DROP;

-- 2. Import data from the CSV into the temporary table.
COPY to_import
FROM 'C:\Users\Public\pokemon_technical_machines.csv'
DELIMITER ',' 
CSV HEADER
NULL AS '-';


-- 3. Import the CSV data into the technical_machines table.
INSERT INTO technical_machines (
  tm_number,
  tm_name,
  applies_to_type,
  category,
  attack_power,
  accuracy,
  power_points 
)
SELECT tm, "name","type", category, power, acc, pp
FROM to_import;

-- Commit the changes. The temporary table will get dropped.
COMMIT;

BEGIN transaction;

drop table if exists users;
drop table if exists listings;
drop table if exists bids;

CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,     
    email TEXT UNIQUE NOT NULL
);

CREATE TABLE listings (
    listing_id SERIAL PRIMARY KEY,
    tm_id INT NOT null,
    selling_user_id INT NOT null,
    listed_on TIMESTAMP NOT NULL,
    time_to_list INTERVAL,
    starting_bid_price NUMERIC(10, 2) NOT null CHECK (starting_bid_price >= 0),
    reserve_price NUMERIC(10, 2) check (reserve_price >= 0),
    current_bid_price NUMERIC(10, 2),
    current_bid_id INT,
    
    foreign key (tm_id) references technical_machines(tm_id) ON DELETE CASCADE,
    foreign key (selling_user_id) references users(user_id) ON DELETE CASCADE
);

CREATE TABLE bids (
    bid_id SERIAL PRIMARY KEY,
    listing_id INT NOT null,
    user_id INT NOT null,
    bid_time TIMESTAMP NOT NULL,
    bid_price NUMERIC(10, 2) NOT null check (bid_price >= 0),
    
    foreign key (listing_id) references listings(listing_id) ON DELETE CASCADE,
    foreign key (user_id) references users(user_id) ON DELETE CASCADE
);

COMMIT;
ROLLBACK;
