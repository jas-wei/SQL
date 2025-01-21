drop view if exists listing_details;

CREATE VIEW listing_details AS
SELECT
    l.listing_id,
    l.tm_id,
    l.selling_user_id,
    l.listed_on,
    l.time_to_list,
    l.starting_bid_price,
    l.reserve_price,
    (NOW() > (l.listed_on + l.time_to_list)) AS is_listing_over,
    (COALESCE(MAX(b.bid_price), 0) >= l.reserve_price) AS is_item_sold,
	NULLIF(MAX(b.bid_price), 0) AS current_bid_price,
	MAX(b.bid_id) AS current_bid_id

FROM
    listings l
LEFT JOIN
    bids b ON l.listing_id = b.listing_id

GROUP BY
    l.listing_id, l.tm_id, l.selling_user_id, l.listed_on, l.time_to_list,
    l.starting_bid_price, l.reserve_price;
    

SELECT * 
FROM listing_details
--FROM listings
ORDER BY listing_id ASC;
