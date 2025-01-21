BEGIN TRANSACTION;

INSERT INTO users (user_id,username,"password",email) VALUES
	 (1,'alice','b9e4378a1c42ecb8803ef455795b4cb598f17d43','alice@example.com'),
	 (2,'bob','ae79be8c4d5c0bd7de4665164569b75fbc1135d3','bob@example.com'),
	 (3,'charlie','44cd2a2da64a9d6c6fe2a7b2932d084b6db8506d','charlie@example.com');

INSERT INTO listings (listing_id,tm_id,selling_user_id,listed_on,time_to_list,starting_bid_price,reserve_price,current_bid_price,current_bid_id) VALUES
	 (3,3,2,'2024-09-30 00:00:00','30 days'::interval,500.00,4000.00,NULL,NULL),
	 (1,1,1,'2024-01-01 00:00:00','28 days'::interval,1000.00,5000.00,NULL,NULL),
	 (2,4,1,'2024-01-10 00:00:00','14 days'::interval,100.00,2500.00,NULL,NULL),
	 (4,10,2,'2024-09-30 00:00:00','30 days'::interval,0.00,1000.00,NULL,NULL);

INSERT INTO bids (bid_id,listing_id,user_id,bid_time,bid_price) VALUES
	 (1,1,2,'2024-01-02 00:00:00',750.00),
	 (2,1,3,'2024-01-03 00:00:00',1500.00),
	 (3,1,2,'2024-01-04 00:00:00',2555.50),
	 (4,1,3,'2024-01-05 00:00:00',4444.44),
	 (5,2,3,'2024-02-02 00:00:00',10000.00),
	 (7,2,2,'2024-02-03 00:00:00',11111.00),
	 (8,4,1,'2024-10-01 00:00:00',2000.00);

UPDATE listings_1 SET current_bid_price=4444.44, current_bid_id=4
WHERE listing_id = 1;

UPDATE listings_1 SET current_bid_price=11111.00, current_bid_id=7
WHERE listing_id = 2;

UPDATE listings_1 SET current_bid_price=2000.00, current_bid_id=8
WHERE listing_id = 4;

COMMIT;
rollback;