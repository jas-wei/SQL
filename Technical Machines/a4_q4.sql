-- Write an UPDATE query that sets the current_bid_id and current_bid_price
--for each row in listings based on the data in the bids table. If the listing has no bids
--current_bid_id and current_bid_price should both be be NULL. If the listing has
--one or more bids, then set current_bid_id to the bid_id with the highest bid_price
--and set the bid_price.
--The provided data had the correct values set already, so your query should not change
--anything unless you insert new data

UPDATE listings l
SET 
    current_bid_id = (
        SELECT b.bid_id
        FROM bids b
        WHERE b.listing_id = l.listing_id
        ORDER BY b.bid_price DESC
        LIMIT 1
    ),
    current_bid_price = (
        SELECT b.bid_price
        FROM bids b
        WHERE b.listing_id = l.listing_id
        ORDER BY b.bid_price DESC
        LIMIT 1
    )
WHERE EXISTS (
    SELECT 1
    FROM bids b
    WHERE b.listing_id = l.listing_id
);

	
UPDATE listings
SET 
    current_bid_id = NULL,
    current_bid_price = NULL
WHERE NOT EXISTS (
    SELECT 1
    FROM bids
    WHERE bids.listing_id = listings.listing_id
);

select * from listings