-- Create the table for the data sets
CREATE TABLE swiggy_vs_zomato (
    restaurant_id                        VARCHAR(20)    PRIMARY KEY,
    restaurant_name                      VARCHAR(100)   NOT NULL,
    city                                 VARCHAR(50)    NOT NULL,
    locality                             VARCHAR(100)   NOT NULL,
    restaurant_type                      VARCHAR(50)    NOT NULL,
    cuisines                             TEXT           NOT NULL,
    distance_from_city_center_km         NUMERIC(5,2)   NOT NULL,
    opening_time                         TIME           NOT NULL,
    closing_time                         TIME           NOT NULL,
    days_operational                     INT            NOT NULL,
    swiggy_rating                        NUMERIC(3,1)   NOT NULL,
    swiggy_total_reviews                 INT            NOT NULL,
    zomato_rating                        NUMERIC(3,1)   NOT NULL,
    zomato_total_reviews                 INT            NOT NULL,
    average_rating_both_platforms        NUMERIC(3,2)   NOT NULL,
    avg_cost_per_person_inr              INT            NOT NULL,
    price_category                       VARCHAR(20)    NOT NULL,
    swiggy_delivery_fee_inr              INT            NOT NULL,
    zomato_delivery_fee_inr              INT            NOT NULL,
    swiggy_avg_delivery_time_minutes     INT            NOT NULL,
    zomato_avg_delivery_time_minutes     INT            NOT NULL,
    swiggy_platform_commission_pct       INT            NOT NULL,
    zomato_platform_commission_pct       INT            NOT NULL,
    swiggy_discount_frequency_pct        INT            NOT NULL,
    zomato_discount_frequency_pct        INT            NOT NULL,
    swiggy_estimated_monthly_orders      INT            NOT NULL,
    zomato_estimated_monthly_orders      INT            NOT NULL,
    swiggy_estimated_monthly_revenue_inr INT            NOT NULL,
    zomato_estimated_monthly_revenue_inr INT            NOT NULL,
    swiggy_estimated_net_profit_inr      INT            NOT NULL,
    zomato_estimated_net_profit_inr      INT            NOT NULL,
    swiggy_market_share_pct              INT            NOT NULL,
    zomato_market_share_pct              INT            NOT NULL,
    platform_performance_better          VARCHAR(20)    NOT NULL,
    amenities                            TEXT,
    amenities_count                      INT            NOT NULL,
    has_own_website                      BOOLEAN        NOT NULL,
    has_own_app                          BOOLEAN        NOT NULL,
    food_license_verified                BOOLEAN        NOT NULL,
    listing_date                         DATE           NOT NULL,
    days_listed                          INT            NOT NULL,
    swiggy_revenue_outlier_flag          VARCHAR(10)    DEFAULT 'Normal',
    zomato_revenue_outlier_flag          VARCHAR(10)    DEFAULT 'Normal',
    swiggy_orders_outlier_flag           VARCHAR(10)    DEFAULT 'Normal',
    zomato_orders_outlier_flag           VARCHAR(10)    DEFAULT 'Normal',

    CONSTRAINT chk_swiggy_rating        CHECK (swiggy_rating BETWEEN 1.0 AND 5.0),
    CONSTRAINT chk_zomato_rating        CHECK (zomato_rating BETWEEN 1.0 AND 5.0),
    CONSTRAINT chk_market_share         CHECK (swiggy_market_share_pct + zomato_market_share_pct = 100),
    CONSTRAINT chk_price_category       CHECK (price_category IN ('Budget', 'Mid-Range', 'Premium', 'Luxury')),
    CONSTRAINT chk_platform_winner      CHECK (platform_performance_better IN ('Swiggy Better', 'Zomato Better', 'Balanced')),
    CONSTRAINT chk_swiggy_rev_flag      CHECK (swiggy_revenue_outlier_flag IN ('Outlier', 'Normal')),
    CONSTRAINT chk_zomato_rev_flag      CHECK (zomato_revenue_outlier_flag IN ('Outlier', 'Normal')),
    CONSTRAINT chk_swiggy_ord_flag      CHECK (swiggy_orders_outlier_flag  IN ('Outlier', 'Normal')),
    CONSTRAINT chk_zomato_ord_flag      CHECK (zomato_orders_outlier_flag  IN ('Outlier', 'Normal'))
);


-- Checking the table 

SELECT * FROM swiggy_vs_zomato;


-- Swiggy vs Zomato — Restaurant Performance Analysis :-

--1.    Top 15 restaurants by combined monthly revenue
SELECT
	RESTAURANT_NAME,
	CITY,
	RESTAURANT_TYPE,
	CUISINES,
	SWIGGY_ESTIMATED_MONTHLY_REVENUE_INR AS SWIGGY_REV,
	ZOMATO_ESTIMATED_MONTHLY_REVENUE_INR AS ZOMATO_REV,
	(
		SWIGGY_ESTIMATED_MONTHLY_REVENUE_INR + ZOMATO_ESTIMATED_MONTHLY_REVENUE_INR
	) AS TOTAL_REVENUE
FROM
	SWIGGY_VS_ZOMATO
ORDER BY
	TOTAL_REVENUE DESC
LIMIT
	15;

--2.  Average net profit by price category on both platforms
 SELECT
	PRICE_CATEGORY,
	ROUND(AVG(SWIGGY_ESTIMATED_NET_PROFIT_INR)) AS SWIGGY_AVG_PROFIT,
	ROUND(AVG(ZOMATO_ESTIMATED_NET_PROFIT_INR)) AS ZOMATO_AVG_PROFIT,
	ROUND(
		AVG(
			SWIGGY_ESTIMATED_NET_PROFIT_INR + ZOMATO_ESTIMATED_NET_PROFIT_INR
		)
	) AS TOTAL_AVG_PROFIT
FROM
	SWIGGY_VS_ZOMATO
GROUP BY
	PRICE_CATEGORY
ORDER BY
	TOTAL_AVG_PROFIT DESC;



--3.   Restaurants where Swiggy revenue > Zomato revenue by 20%+
SELECT
	RESTAURANT_NAME,
	CITY,
	RESTAURANT_TYPE,
	SWIGGY_ESTIMATED_MONTHLY_REVENUE_INR AS SWIGGY_REV,
	ZOMATO_ESTIMATED_MONTHLY_REVENUE_INR AS ZOMATO_REV,
	-- Swiggy revenue is at least 20% more than Zomato revenue.
	ROUND(
		100 * (
			SWIGGY_ESTIMATED_MONTHLY_REVENUE_INR - ZOMATO_ESTIMATED_MONTHLY_REVENUE_INR
		) / ZOMATO_ESTIMATED_MONTHLY_REVENUE_INR,
		1
	) AS SWIGGY_LEAD_PCT
FROM
	SWIGGY_VS_ZOMATO
WHERE
	SWIGGY_ESTIMATED_MONTHLY_REVENUE_INR > ZOMATO_ESTIMATED_MONTHLY_REVENUE_INR * 1.2
ORDER BY
	SWIGGY_LEAD_PCT;



-- 4.	Top 15 highest rated restaurants (average both platforms)

SELECT
	RESTAURANT_NAME,
	CITY,
	CUISINES,
	SWIGGY_RATING,
	ZOMATO_RATING,
	AVERAGE_RATING_BOTH_PLATFORMS
FROM
	SWIGGY_VS_ZOMATO
ORDER BY
	AVERAGE_RATING_BOTH_PLATFORMS DESC,
	(SWIGGY_TOTAL_REVIEWS + ZOMATO_TOTAL_REVIEWS) DESC
LIMIT
	15;


--5.	Largest rating gap between platforms (Swiggy vs Zomato)

SELECT 
    restaurant_name,
    city,
    restaurant_type,
    swiggy_rating,
    zomato_rating,

    ROUND(
        ABS(swiggy_rating - zomato_rating),
        1
    ) AS rating_gap,

    CASE 
        WHEN swiggy_rating > zomato_rating
        THEN 'SWIGGY HIGHER'
        
        ELSE 'ZOMATO HIGHER'
    END AS better_rated

FROM swiggy_vs_zomato

ORDER BY rating_gap DESC

LIMIT 15;


-- 6.	Average rating by city and restaurant type

SELECT
	CITY,
	RESTAURANT_TYPE,
	COUNT(*) AS TOTAL,
	ROUND(AVG(SWIGGY_RATING), 2) AS AVG_SWIGGY,
	ROUND(AVG(ZOMATO_RATING), 2) AS AVG_ZOMATO,
	ROUND(AVG(AVERAGE_RATING_BOTH_PLATFORMS), 2) AS AVG_COMBINED
FROM
	SWIGGY_VS_ZOMATO
GROUP BY
	CITY,
	RESTAURANT_TYPE
ORDER BY
	AVG_COMBINED DESC;

-- 7.	Platform winner breakdown by city
SELECT
	CITY,
	SUM(
		CASE
			WHEN PLATFORM_PERFORMANCE_BETTER = 'Swiggy Better' THEN 1
			ELSE 0
		END
	) AS SWIGGY_WINS,
	SUM(
		CASE
			WHEN PLATFORM_PERFORMANCE_BETTER = 'Zomato Better' THEN 1
			ELSE 0
		END
	) AS ZOMATO_WINS,
	COUNT(*) AS TOTAL
FROM
	SWIGGY_VS_ZOMATO
GROUP BY
	CITY
ORDER BY
	CITY;

-- 8.	Average market share by restaurant type

SELECT
	RESTAURANT_TYPE,
	ROUND(AVG(SWIGGY_MARKET_SHARE_PCT), 1) AS AVG_SWIGGY_SHARE,
	ROUND(AVG(ZOMATO_MARKET_SHARE_PCT), 1) AS AVG_ZOMATO_SHARE,
	COUNT(*) AS TOTAL_RESTAURENT
FROM
	SWIGGY_VS_ZOMATO
GROUP BY
	RESTAURANT_TYPE
ORDER BY
	AVG_SWIGGY_SHARE DESC;



-- 9.	Commission rate vs net profit correlation by platform
		-- Commission Rate vs Net Profit Correlation by Platform
		-- This query compares average net profit of Swiggy and Zomato
		-- across different commission percentage levels to analyze
		-- the impact of platform commission on restaurant profitability.

SELECT 
    swiggy_platform_commission_pct AS swiggy_commission_pct,

    zomato_platform_commission_pct AS zomato_commission_pct,

    COUNT(*) AS restaurants,

    ROUND(
        AVG(swiggy_estimated_net_profit_inr),
        0
    ) AS avg_swiggy_profit,

    ROUND(
        AVG(zomato_estimated_net_profit_inr),
        0
    ) AS avg_zomato_profit

FROM swiggy_vs_zomato

GROUP BY 
    swiggy_platform_commission_pct,
    zomato_platform_commission_pct

ORDER BY 
    swiggy_commission_pct,
    zomato_commission_pct;


-- 10.	Average delivery time by distance bucket
-- Average delivery time analysis by distance bucket
-- comparing Swiggy and Zomato delivery performance.

SELECT 
    CASE
        WHEN DISTANCE_FROM_CITY_CENTER_KM < 2 
        THEN '0-2 KM'

        WHEN DISTANCE_FROM_CITY_CENTER_KM < 5 
        THEN '2-5 KM'

        WHEN DISTANCE_FROM_CITY_CENTER_KM < 10 
        THEN '5-10 KM'

        ELSE '10+ KM'
    END AS DISTANCE_BUCKET,

    COUNT(*) AS TOTAL_ORDERS,

    ROUND(
        AVG(SWIGGY_AVG_DELIVERY_TIME_MINUTES),
        1
    ) AS SWIGGY_AVG_DELIVERY_TIME,

    ROUND(
        AVG(ZOMATO_AVG_DELIVERY_TIME_MINUTES),
        1
    ) AS ZOMATO_AVG_DELIVERY_TIME

FROM SWIGGY_VS_ZOMATO

GROUP BY DISTANCE_BUCKET

ORDER BY 
    SWIGGY_AVG_DELIVERY_TIME,
    ZOMATO_AVG_DELIVERY_TIME;


-- 11.	Fastest delivering restaurants (average across 	both platforms)
SELECT
	RESTAURANT_NAME,
	CITY,
	RESTAURANT_TYPE,
	SWIGGY_AVG_DELIVERY_TIME_MINUTES AS SWIGGY_MINS,
	ZOMATO_AVG_DELIVERY_TIME_MINUTES AS ZOMATO_MINS,
	ROUND(
		(
			SWIGGY_AVG_DELIVERY_TIME_MINUTES + ZOMATO_AVG_DELIVERY_TIME_MINUTES
		) / 2.0,
		2
	) AS AVG_MINUTES
FROM
	SWIGGY_VS_ZOMATO
ORDER BY
	AVG_MINUTES DESC
LIMIT
	15;


-- 12.	Most popular cuisines by total monthly orders
SELECT
	CUISINES,
	COUNT(*) AS TOTAL,
	SUM(SWIGGY_ESTIMATED_MONTHLY_ORDERS) AS SWIGGY_MONTHLY_ORDERS,
	SUM(ZOMATO_ESTIMATED_MONTHLY_ORDERS) AS ZOMATO_MONTHLY_ORDERS,
	SUM(
		SWIGGY_ESTIMATED_MONTHLY_ORDERS + ZOMATO_ESTIMATED_MONTHLY_ORDERS
	) AS TOTAL_ORDERS,
	ROUND(AVG(AVERAGE_RATING_BOTH_PLATFORMS), 2) AS AVG_RATING
FROM
	SWIGGY_VS_ZOMATO
WHERE
	CUISINES NOT LIKE '%;%'
GROUP BY
	CUISINES
ORDER BY
	TOTAL_ORDERS DESC;


-- 13.	Revenue per order by restaurant type
-- Average Revenue Per Order Analysis by Restaurant Type
-- This query calculates the average revenue earned per order
-- for Swiggy and Zomato across different restaurant categories.

SELECT 
    RESTAURANT_TYPE,
    ROUND(
        AVG(
            SWIGGY_ESTIMATED_MONTHLY_REVENUE_INR * 1.0
            / NULLIF(SWIGGY_ESTIMATED_MONTHLY_ORDERS, 0)
        ),
        0
    ) AS SWIGGY_REV_PER_ORDER,
    ROUND(
        AVG(
            ZOMATO_ESTIMATED_MONTHLY_REVENUE_INR * 1.0
            / NULLIF(ZOMATO_ESTIMATED_MONTHLY_ORDERS, 0)
        ),
        0
    ) AS ZOMATO_REV_PER_ORDER
FROM 
	SWIGGY_VS_ZOMATO
GROUP BY 
	RESTAURANT_TYPE
ORDER BY 
	SWIGGY_REV_PER_ORDER 
DESC;


-- 14.	High discount restaurants — do they earn more?
		-- High discount restaurants analysis:
		-- checking whether higher discount frequency
		-- leads to higher revenue and more orders.

SELECT

    CASE
        WHEN SWIGGY_DISCOUNT_FREQUENCY_PCT >= 25 
        THEN 'HIGH (25%+)'

        WHEN SWIGGY_DISCOUNT_FREQUENCY_PCT >= 15 
        THEN 'MEDIUM (15–24%)'

        ELSE 'LOW (<15%)'
    END AS SWIGGY_DISCOUNT_TIER,

    CASE
        WHEN ZOMATO_DISCOUNT_FREQUENCY_PCT >= 25 
        THEN 'HIGH (25%+)'

        WHEN ZOMATO_DISCOUNT_FREQUENCY_PCT >= 15 
        THEN 'MEDIUM (15–24%)'

        ELSE 'LOW (<15%)'
    END AS ZOMATO_DISCOUNT_TIER,

    COUNT(*) AS RESTAURANTS,

    ROUND(
        AVG(SWIGGY_ESTIMATED_MONTHLY_REVENUE_INR),
        0
    ) AS AVG_SWIGGY_REV,

    ROUND(
        AVG(ZOMATO_ESTIMATED_MONTHLY_REVENUE_INR),
        0
    ) AS AVG_ZOMATO_REV,

    ROUND(
        AVG(SWIGGY_ESTIMATED_MONTHLY_ORDERS),
        0
    ) AS AVG_SWIGGY_ORDERS,

    ROUND(
        AVG(ZOMATO_ESTIMATED_MONTHLY_ORDERS),
        0
    ) AS AVG_ZOMATO_ORDERS

FROM SWIGGY_VS_ZOMATO

GROUP BY 
    SWIGGY_DISCOUNT_TIER,
    ZOMATO_DISCOUNT_TIER

ORDER BY 
    AVG_SWIGGY_REV DESC,
    AVG_ZOMATO_REV DESC;


-- 15.	Food license compliance vs revenue and rating

SELECT
    CASE 
        WHEN FOOD_LICENSE_VERIFIED = TRUE 
        THEN 'VERIFIED'

        ELSE 'NOT VERIFIED'
    END AS LICENSE_STATUS,

    COUNT(*) AS RESTAURANTS,

    ROUND(
        AVG(AVERAGE_RATING_BOTH_PLATFORMS),
        2
    ) AS AVG_RATING,

    ROUND(
        AVG(
            SWIGGY_ESTIMATED_MONTHLY_REVENUE_INR
            + ZOMATO_ESTIMATED_MONTHLY_REVENUE_INR
        ),
        0
    ) AS AVG_TOTAL_REV

FROM SWIGGY_VS_ZOMATO

GROUP BY FOOD_LICENSE_VERIFIED;


-- 16.	Restaurant-Type Wise Commission vs Profit 	Analysis by Platform
	-- Commission rate vs net profit correlation comparison
	-- between Swiggy and Zomato by restaurant type.
SELECT
    RESTAURANT_TYPE,

    SWIGGY_PLATFORM_COMMISSION_PCT,
    
    ROUND(
        AVG(SWIGGY_ESTIMATED_NET_PROFIT_INR),
        0
    ) AS AVG_SWIGGY_PROFIT,

    ZOMATO_PLATFORM_COMMISSION_PCT,

    ROUND(
        AVG(ZOMATO_ESTIMATED_NET_PROFIT_INR),
        0
    ) AS AVG_ZOMATO_PROFIT,

    COUNT(*) AS RESTAURANTS

FROM SWIGGY_VS_ZOMATO

GROUP BY
    RESTAURANT_TYPE,
    SWIGGY_PLATFORM_COMMISSION_PCT,
    ZOMATO_PLATFORM_COMMISSION_PCT

ORDER BY
    RESTAURANT_TYPE,
    SWIGGY_PLATFORM_COMMISSION_PCT,
    ZOMATO_PLATFORM_COMMISSION_PCT;
















































 