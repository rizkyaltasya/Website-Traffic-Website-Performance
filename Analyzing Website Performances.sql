#### Analyzing Website Performance ####

SELECT 
    *
FROM
    website_pageviews
WHERE
    website_pageview_id < 100;
    
SELECT 
    pageview_url AS url, 
    COUNT(DISTINCT website_pageview_id) AS pageview
FROM
    website_pageviews
WHERE
    website_pageview_id < 1000
GROUP BY pageview_url
ORDER BY pageview DESC;

create temporary table first_pageview
SELECT 
    website_session_id, 
    MIN(website_pageview_id) AS min_pv_id
FROM
    website_pageviews
WHERE
    website_pageview_id < 1000
group by website_session_id
ORDER BY website_session_id;
    
SELECT 
    *
FROM
    first_pageview;
    
SELECT 
    fp.website_session_id,
    wp.pageview_url as url_view
FROM
    first_pageview fp
        LEFT JOIN
    website_pageviews wp ON fp.min_pv_id = wp.website_pageview_id;
    
SELECT 
    count(wp.website_session_id) as total_session,
    wp.pageview_url as url_view
FROM
    first_pageview fp
        LEFT JOIN
    website_pageviews wp ON fp.min_pv_id = wp.website_pageview_id
group by wp.pageview_url;

SELECT 
    pageview_url AS url,
    COUNT(DISTINCT website_pageview_id) AS pvs
FROM
    website_pageviews
WHERE
    created_at < '2012-09-12'
GROUP BY pageview_url
ORDER BY 2 DESC;

create temporary table onces_pageview
SELECT 
    website_session_id, 
    MIN(website_pageview_id) AS min_pv_view
FROM
    website_pageviews
WHERE
    created_at < '2012-06-12'
GROUP BY website_session_id;

SELECT 
    wp.pageview_url AS landing_page,
    COUNT(DISTINCT op.website_session_id) AS sessions
FROM
    onces_pageview op
        LEFT JOIN
    website_pageviews wp ON op.min_pv_view = wp.website_pageview_id
GROUP BY wp.pageview_url;

SELECT 
    wp.website_session_id as sessions, 
    MIN(wp.website_pageview_id) as first_pv
FROM
    website_pageviews wp
        JOIN
    website_sessions ws ON wp.website_session_id = ws.website_session_id
where wp.created_at between '2014-01-01' and '2014-02-01' 
GROUP BY wp.website_session_id;

select * from first_pageviews_demo;

CREATE TEMPORARY TABLE first_pageviews_demo    
SELECT 
    wp.website_session_id AS sessions,
    MIN(wp.website_pageview_id) AS first_pv
FROM
    website_pageviews wp
        JOIN
    website_sessions ws ON wp.website_session_id = ws.website_session_id
WHERE
    wp.created_at BETWEEN '2014-01-01' AND '2014-02-01'
GROUP BY wp.website_session_id;

drop temporary table if exists first_pageviews_demo;
create temporary table sessions_landing_page_demo
SELECT 
    wp.website_session_id, 
    wp.pageview_url AS landing_page
FROM
    first_pageviews_demo fp
        LEFT JOIN
    website_pageviews wp ON fp.first_pv = wp.website_pageview_id;
    
select * from sessions_landing_page_demo;

create temporary table bounce_sessions_only;
SELECT 
    sessions_landing_page_demo.website_session_id,
    sessions_landing_page_demo.landing_page,
    COUNT(website_pageviews.website_pageview_id) AS count_of_pageviews
FROM
    sessions_landing_page_demo
        LEFT JOIN
    website_pageviews ON sessions_landing_page_demo.website_session_id = website_pageviews.website_session_id
GROUP BY sessions_landing_page_demo.website_session_id , sessions_landing_page_demo.landing_page
having COUNT(website_pageviews.website_pageview_id) = 1;

SELECT 
    sessions_landing_page_demo.landing_page,
    COUNT(DISTINCT sessions_landing_page_demo.website_session_id) AS sessions,
    COUNT(DISTINCT bounce_sessions_only.website_session_id) AS total_bounces_session
FROM
    sessions_landing_page_demo
        LEFT JOIN
    bounce_sessions_only ON bounce_sessions_only.website_session_id = sessions_landing_page_demo.website_session_id
GROUP BY sessions_landing_page_demo.landing_page;

CREATE TEMPORARY TABLE first_page_views
SELECT 
    website_session_id, 
    MIN(website_pageview_id) AS min_pv
FROM
    website_pageviews
WHERE
    created_at < '2012-06-14'
GROUP BY website_session_id;

SELECT 
    *
FROM
    first_page_views;

CREATE TEMPORARY TABLE landing_sessions_page
SELECT 
    first_page_views.website_session_id,
    website_pageviews.pageview_url AS landing_page
FROM
    first_page_views
        LEFT JOIN
 website_pageviews ON first_page_views.min_pv = website_pageviews.website_pageview_id
WHERE
    website_pageviews.pageview_url = '/home';
    
CREATE TEMPORARY TABLE bounce_sessions
SELECT 
    landing_sessions_page.website_session_id,
    landing_sessions_page.landing_page,
    COUNT(website_pageviews.website_pageview_id) AS count_of_page_views
FROM
    landing_sessions_page 
        LEFT JOIN
    website_pageviews ON landing_sessions_page.website_session_id = website_pageviews.website_session_id
GROUP BY landing_sessions_page.website_session_id , landing_sessions_page.landing_page
HAVING COUNT(website_pageviews.website_pageview_id) = 1;

drop table if exists bounces_rate;

SELECT 
    COUNT(DISTINCT landing_sessions_page.website_session_id) AS total_sessions,
    COUNT(DISTINCT bounce_sessions.website_session_id) AS bounce_sessions,
    (COUNT(DISTINCT bounce_sessions.website_session_id) / COUNT(DISTINCT landing_sessions_page.website_session_id)) * 100 AS bounce_rate
FROM
    landing_sessions_page
        LEFT JOIN
    bounce_sessions ON landing_sessions_page.website_session_id = bounce_sessions.website_session_id;
    
SELECT 
    MIN(created_at) AS week_start,
    MIN(website_pageview_id) AS first_pageviews
FROM
    website_pageviews
WHERE
    pageview_url = '/lander-1';

create temporary table first_pageviews_demo
SELECT 
    website_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) as min_pageview
FROM
    website_pageviews
        INNER JOIN
    website_sessions ON website_sessions.website_session_id = website_pageviews.website_session_id 
        AND website_sessions.created_at < '2012-07-28'
        AND website_pageviews.website_pageview_id > 23504
        AND website_sessions.utm_source = 'gsearch'
        AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY website_pageviews.website_session_id;

create temporary table landing_page_session
SELECT 
    first_pageviews_demo.website_session_id,
    website_pageviews.pageview_url AS landing_page
FROM
    first_pageviews_demo
        LEFT JOIN
    website_pageviews ON first_pageviews_demo.min_pageview = website_pageviews.website_pageview_id
WHERE
    website_pageviews.pageview_url IN ('/home' , '/lander-1');
 
create temporary table bounce_sessions_non_brand
SELECT 
    landing_page_session.website_session_id,
    landing_page_session.landing_page,
    COUNT(website_pageviews.website_pageview_id) AS count_pageviews
FROM
    landing_page_session
        LEFT JOIN
    website_pageviews ON landing_page_session.website_session_id = website_pageviews.website_session_id
GROUP BY 1 , 2
having COUNT(website_pageviews.website_pageview_id) = 1;

SELECT 
    landing_page_session.landing_page,
    COUNT(DISTINCT bounce_sessions_non_brand.website_session_id) AS bounce_sessions,
    COUNT(DISTINCT landing_page_session.website_session_id) AS total_sessions,
    COUNT(DISTINCT bounce_sessions_non_brand.website_session_id) / COUNT(DISTINCT landing_page_session.website_session_id) AS bounce_rates
FROM
    landing_page_session
        LEFT JOIN
    bounce_sessions_non_brand ON landing_page_session.website_session_id = bounce_sessions_non_brand.website_session_id
GROUP BY landing_page_session.landing_page;

SELECT 
    *
FROM
    website_sessions;

create temporary table first_page_views_non_brand;
SELECT 
    website_sessions.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_pageviews,
    COUNT(website_pageviews.website_pageview_id) AS count_websitepageview
FROM
    website_sessions
        LEFT JOIN
    website_pageviews ON website_pageviews.website_session_id = website_sessions.website_session_id
where
	website_sessions.utm_source = 'gsearch'
	AND website_sessions.utm_campaign = 'nonbrand'
	AND website_sessions.created_at BETWEEN '2012-06-01' AND '2012-08-31'
GROUP BY 1;

drop temporary table if exists first_page_views_non_brand;

create temporary table landing_page_nonbrand_paidsearch;
SELECT 
    first_page_views_non_brand.website_session_id,
    first_page_views_non_brand.min_pageviews,
    first_page_views_non_brand.count_websitepageview,
    website_pageviews.pageview_url AS landing_page,
	website_pageviews.created_at as session_created_at
FROM
    first_page_views_non_brand
        LEFT JOIN
    website_pageviews ON first_page_views_non_brand.min_pageviews = website_pageviews.website_pageview_id;
	
SELECT 
    DATE(session_created_at) AS week_start_date,
    COUNT(DISTINCT CASE
            WHEN landing_page = '/home' THEN website_session_id
            ELSE NULL
        END) AS home_sessions,
    COUNT(DISTINCT CASE
            WHEN
                count_websitepageview = 1
                    AND landing_page = '/home'
            THEN
                website_session_id
            ELSE NULL
        END) AS bounce_sessions_home,
    COUNT(DISTINCT CASE
            WHEN
                count_websitepageview = 1
                    AND landing_page = '/home'
            THEN
                website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN landing_page = '/home' THEN website_session_id
            ELSE NULL
        END) AS bounce_rate_homes,
    COUNT(DISTINCT CASE
            WHEN landing_page = '/lander-1' THEN website_session_id
            ELSE NULL
        END) AS lander1_sessions,
    COUNT(DISTINCT CASE
            WHEN
                count_websitepageview = 1
                    AND landing_page = '/lander-1'
            THEN
                website_session_id
            ELSE NULL
        END) AS bounce_sessions_lander1,
    COUNT(DISTINCT CASE
            WHEN
                count_websitepageview = 1
                    AND landing_page = '/lander-1'
            THEN
                website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN landing_page = '/lander-1' THEN website_session_id
            ELSE NULL
        END) AS bounce_rate_landers1
FROM
    landing_page_nonbrand_paidsearch
GROUP BY WEEK(session_created_at);

##### Conversion Funnel #####
SELECT 
    website_sessions.website_session_id,
    website_pageviews.website_pageview_id,
    website_pageviews.created_at,
    case when pageview_url = '/products' then 1 else 0 end as products_page,
    case when pageview_url = '/the-original-mr-fuzzy' then 1 else 0 end as mrfuzzy_page,
    case when pageview_url = '/cart' then 1 else 0 end as cart_page
FROM
    website_sessions
        LEFT JOIN
    website_pageviews ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE
    website_sessions.created_at BETWEEN '2014-01-01' AND '2014-02-01'
        AND website_pageviews.pageview_url IN ('/lander-2' , '/products',
        '/the-original-mr-fuzzy',
        '/cart')
ORDER BY website_sessions.website_session_id;

SELECT 
    website_session_id,
    website_pageview_id,
    MAX(products_page),
    MAX(mrfuzzy_page),
    MAX(cart_page)
FROM
    (SELECT 
        website_sessions.website_session_id,
            website_pageviews.website_pageview_id,
            website_pageviews.created_at,
            CASE
                WHEN pageview_url = '/products' THEN 1
                ELSE 0
            END AS products_page,
            CASE
                WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1
                ELSE 0
            END AS mrfuzzy_page,
            CASE
                WHEN pageview_url = '/cart' THEN 1
                ELSE 0
            END AS cart_page
    FROM
        website_sessions
    LEFT JOIN website_pageviews ON website_sessions.website_session_id = website_pageviews.website_session_id
    WHERE
        website_sessions.created_at BETWEEN '2014-01-01' AND '2014-02-01'
            AND website_pageviews.pageview_url IN ('/lander-2' , '/products', '/the-original-mr-fuzzy', '/cart')
    ORDER BY website_sessions.website_session_id , website_pageviews.created_at) AS pageview_level
GROUP BY website_session_id;
 
drop table if exists session_conversion_level_demo;
create temporary table session_conversion_level_demo;
SELECT 
    website_session_id,
    website_pageview_id,
    MAX(products_page) AS product_made_it,
    MAX(mrfuzzy_page) AS mrfuzzy_made_it,
    MAX(cart_page) AS cart_made_it
FROM
    (SELECT 
        website_sessions.website_session_id,
            website_pageviews.website_pageview_id,
            website_pageviews.created_at,
            CASE
                WHEN pageview_url = '/products' THEN 1
                ELSE 0
            END AS products_page,
            CASE
                WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1
                ELSE 0
            END AS mrfuzzy_page,
            CASE
                WHEN pageview_url = '/cart' THEN 1
                ELSE 0
            END AS cart_page
    FROM
        website_sessions
    LEFT JOIN website_pageviews ON website_sessions.website_session_id = website_pageviews.website_session_id
    WHERE
        website_sessions.created_at BETWEEN '2014-01-01' AND '2014-02-01'
            AND website_pageviews.pageview_url IN ('/lander-2' , '/products', '/the-original-mr-fuzzy', '/cart')
    ORDER BY website_sessions.website_session_id , website_pageviews.created_at) AS pageview_level
GROUP BY website_session_id;

SELECT 
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE
            WHEN product_made_it = 1 THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT website_session_id) AS clicked_to_products,
    COUNT(DISTINCT CASE
            WHEN mrfuzzy_made_it = 1 THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN product_made_it = 1 THEN website_session_id
            ELSE NULL
        END) AS clicked_to_mrfuzzy,
    COUNT(DISTINCT CASE
            WHEN cart_made_it = 1 THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN product_made_it = 1 THEN website_session_id
            ELSE NULL
        END) AS clicked_to_carts
FROM
    session_conversion_level_demo;

SELECT 
    *
FROM
    website_pageviews
GROUP BY pageview_url;
   
create temporary table session_all_conversion_funnel;
SELECT 
    website_sessions.website_session_id,
    website_pageviews.website_pageview_id,
    website_pageviews.created_at,
    CASE
        WHEN pageview_url = '/products' THEN 1
        ELSE 0
    END AS products_page,
    CASE
        WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1
        ELSE 0
    END AS mrfuzzy_page,
    CASE
        WHEN pageview_url = '/cart' THEN 1
        ELSE 0
    END AS carts_page,
    CASE
        WHEN pageview_url = '/shipping' THEN 1
        ELSE 0
    END AS shippings_page,
    CASE
        WHEN pageview_url = '/billing' THEN 1
        ELSE 0
    END AS billings_page,
    CASE
        WHEN pageview_url = '/thank-you-for-your-order' THEN 1
        ELSE 0
    END AS thankyou_page
FROM
    website_sessions
        LEFT JOIN
    website_pageviews ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE
    utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand'
        AND website_pageviews.created_at BETWEEN '2012-08-05' AND '2012-09-05'
ORDER BY website_session_id;

SELECT 
    COUNT(website_session_id),
    COUNT(DISTINCT CASE
            WHEN products_page = 1 THEN website_session_id
            ELSE NULL
        END) AS to_products,
    COUNT(DISTINCT CASE
            WHEN mrfuzzy_page = 1 THEN website_session_id
            ELSE NULL
        END) AS to_mrfuzzy,
    COUNT(DISTINCT CASE
            WHEN carts_page = 1 THEN website_session_id
            ELSE NULL
        END) AS to_carts,
    COUNT(DISTINCT CASE
            WHEN shippings_page = 1 THEN website_session_id
            ELSE NULL
        END) AS to_shippings,
    COUNT(DISTINCT CASE
            WHEN billings_page = 1 THEN website_session_id
            ELSE NULL
        END) AS to_billings,
    COUNT(DISTINCT CASE
            WHEN thankyou_page = 1 THEN website_session_id
            ELSE NULL
        END) AS to_thankyou
FROM
    session_all_conversion_funnel;

SELECT 
    MIN(website_pageview_id) as first_pv
FROM
    website_pageviews
WHERE
    pageview_url = '/billing-2';
  
SELECT 
    website_pageviews.website_session_id,
    website_pageviews.pageview_url as billing_version_seen,
    orders.order_id
FROM
    website_pageviews
        LEFT JOIN
    orders ON website_pageviews.website_session_id = orders.website_session_id
WHERE
    website_pageview_id >= '53550'
        AND pageview_url IN ('/billing' , '/billing-2')
        AND website_pageviews.created_at < '2012-11-10';
        
select
	billing_version_session,
    count(distinct website_session_id) as total_session,
	count(distinct order_id) as total_orders,
    count(distinct order_id)/count(distinct website_session_id) as session_to_order
from
	(SELECT 
		website_pageviews.website_session_id,
		website_pageviews.pageview_url as billing_version_session,
		orders.order_id
	FROM
		website_pageviews
			LEFT JOIN
		orders ON website_pageviews.website_session_id = orders.website_session_id
	WHERE
		website_pageview_id >= '53550'
        AND pageview_url IN ('/billing' , '/billing-2')
        AND website_pageviews.created_at < '2012-11-10') as conversion_billing
group by 1;

SELECT 
	website_sessions.device_type AS type_device,
    COUNT(DISTINCT website_sessions.website_session_id) AS total_sessions,
    COUNT(DISTINCT orders.order_id) AS total_orders,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS conversion_rate
FROM
    website_sessions
        LEFT JOIN
    orders ON website_sessions.website_session_id = orders.website_session_id
WHERE
    website_sessions.created_at BETWEEN '2014-05-31' AND '2015-05-31'
GROUP BY 1;

