use mavenfuzzyfactory;

select * from website_sessions
limit 10000;

SELECT 
    *
FROM
    website_sessions
WHERE
    website_session_id = 1059; 
    
SELECT 
    *
FROM
    website_pageviews
WHERE
    website_pageview_id = 1059;
    
SELECT 
    *
FROM
    orders
WHERE
    website_session_id = 1059;
    
SELECT DISTINCT
    utm_source, utm_campaign
FROM
    website_sessions;
    
SELECT 
    *
FROM
    website_sessions
WHERE
    website_session_id BETWEEN 1000 AND 2000;
    
SELECT 
    utm_content, COUNT(DISTINCT website_session_id) AS sessions
FROM
    website_sessions
WHERE
    website_session_id BETWEEN 1000 AND 2000
GROUP BY utm_content
ORDER BY COUNT(DISTINCT website_session_id) DESC;
 
SELECT 
    ws.utm_content,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    CONCAT((COUNT(DISTINCT o.order_id) / COUNT(DISTINCT ws.website_session_id)) * 100,
            '%') AS conversion_rate
FROM
    website_sessions ws
        LEFT JOIN
    orders o ON ws.website_session_id = o.website_session_id
WHERE
    ws.website_session_id BETWEEN 1000 AND 2000
GROUP BY 1
ORDER BY 2 DESC;

SELECT 
    utm_source,
    utm_campaign,
    http_referer,
    COUNT(distinct website_session_id) AS sessions
FROM
    website_sessions
WHERE
    created_at < '2012-04-12'
GROUP BY 1,2,3
ORDER BY utm_source, sessions desc; 

SELECT 
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    (COUNT(DISTINCT o.order_id) / COUNT(DISTINCT ws.website_session_id) * 100) AS conversion_rate,
    CASE
        WHEN (COUNT(DISTINCT o.order_id) / COUNT(DISTINCT ws.website_session_id) * 100) < 4 THEN 'Reduce Bids'
        ELSE 'Increase Bids'
    END AS 'Decision'
FROM
    website_sessions ws
	LEFT JOIN
    orders o ON ws.website_session_id = o.website_session_id
WHERE
    ws.created_at < '2022-10-14'
        AND utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand';
        
SELECT 
    item_purchased_id,
    created_at,
    YEAR(created_at),
    MONTH(created_at),
    WEEK(created_at),
    DAY(created_at)
FROM
    website_sessions
WHERE
    website_session_id BETWEEN 1000 AND 11500;
    
SELECT 
    MONTH(created_at),
    WEEK(created_at),
    MIN(DATE(created_at)) AS week_start,
    COUNT(DISTINCT website_session_id) AS sessions
FROM
    website_sessions
WHERE
    website_session_id BETWEEN 1000 AND 11500
GROUP BY 1 , 2;

SELECT 
    primary_product_id,
    order_id,
    items_purchased,
    COUNT(DISTINCT CASE
            WHEN items_purchased = 1 THEN order_id
            ELSE NULL
        END) AS single_order,
    COUNT(DISTINCT CASE
            WHEN items_purchased = 2 THEN order_id
            ELSE NULL
        END) AS multiple_order
FROM
    orders
WHERE
    order_id BETWEEN 31000 AND 32000
group by 1, 2;

SELECT 
    primary_product_id,
    COUNT(DISTINCT CASE
            WHEN items_purchased = 1 THEN order_id
            ELSE NULL
        END) AS single_order,
    COUNT(DISTINCT CASE
            WHEN items_purchased = 2 THEN order_id
            ELSE NULL
        END) AS multiple_order
FROM
    orders
WHERE
    order_id BETWEEN 31000 AND 32000
group by 1;

select * from website_sessions;

SELECT 
    MIN(DATE(created_at)) AS week_start,
    WEEK(created_at) AS wk,
    COUNT(DISTINCT website_session_id) AS sessions
FROM
    website_sessions
WHERE
    utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand'
        AND created_at < '2012-05-12'
GROUP BY WEEK(created_at)
ORDER BY created_at;

SELECT 
    ws.device_type,
    COUNT(ws.website_session_id) AS sessions,
    COUNT(o.order_id) AS orders,
    (COUNT(o.order_id) / COUNT(ws.website_session_id)) * 100 AS conversion_rate
FROM
    website_sessions ws
        LEFT JOIN
    orders o ON ws.website_session_id = o.website_session_id
WHERE
    ws.created_at < '2012-05-11'
GROUP BY ws.device_type;

SELECT 
    MIN(DATE(created_at)) AS week_start,
    COUNT(DISTINCT CASE
            WHEN device_type = 'mobile' THEN website_session_id
            ELSE NULL
        END) AS mobile_session,
    COUNT(DISTINCT CASE
            WHEN device_type = 'desktop' THEN website_session_id
            ELSE NULL
        END) AS desktop_session,
    COUNT(DISTINCT website_session_id) AS total_sessions
FROM
    website_sessions
WHERE
    created_at BETWEEN '2012-04-15' AND '2012-06-09'
        AND utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand'
GROUP BY WEEK(created_at);

SELECT 
    DATE(created_at) AS week_start,
    COUNT(DISTINCT CASE
            WHEN device_type = 'mobile' THEN website_session_id
            ELSE NULL
        END) AS mobile_sessions,
    COUNT(DISTINCT CASE
            WHEN device_type = 'desktop' THEN website_session_id
            ELSE NULL
        END) AS desktop_sessions,
    COUNT(website_session_id) AS total_sessions
FROM
    website_sessions
WHERE
    created_at BETWEEN '2012-04-15' AND '2012-06-09'
        AND utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand'
GROUP BY WEEK(created_at);

SELECT 
    utm_campaign, utm_source, http_referer
FROM
    website_sessions
GROUP BY 1 , 2 , 3;
    