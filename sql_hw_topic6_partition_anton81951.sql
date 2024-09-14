--JOIN
WITH facebook_google_joined_hw5_anton81951 AS (
    SELECT 
        ad_date, 
        url_parameters,
        COALESCE(spend, 0)::numeric AS spend,
        COALESCE(impressions, 0)::numeric AS impressions,
        COALESCE(reach, 0)::numeric AS reach,
        COALESCE(clicks, 0)::numeric AS clicks,
        COALESCE(leads, 0)::numeric AS leads,
        COALESCE(value, 0)::numeric AS value
    FROM 
        facebook_ads_basic_daily
    UNION ALL
    SELECT 
        ad_date, 
        url_parameters,
        COALESCE(spend, 0)::numeric AS spend,
        COALESCE(impressions, 0)::numeric AS impressions,
        COALESCE(reach, 0)::numeric AS reach,
        COALESCE(clicks, 0)::numeric AS clicks,
        COALESCE(leads, 0)::numeric AS leads,
        COALESCE(value, 0)::numeric AS value
    FROM 
        google_ads_basic_daily
),
--CALCULATE METRICS
aggregated_data AS (
    SELECT 
        date_trunc('month', ad_date)::date AS ad_month, 
        CASE 
            WHEN LOWER(decode_ukrainian(SUBSTRING(url_parameters, 'utm_campaign=([^&]*)'))) = 'nan' THEN NULL
            ELSE LOWER(decode_ukrainian(SUBSTRING(url_parameters, 'utm_campaign=([^&]*)')))
        END AS utm_campaign, 
        SUM(spend) AS total_cost, 
        SUM(impressions) AS total_impressions,
        SUM(clicks) AS total_clicks,
        SUM(value) AS total_value,
        CASE
            WHEN SUM(impressions) = 0 THEN 0
            ELSE (SUM(clicks) * 100.0 / SUM(impressions))
        END AS CTR,
        CASE
            WHEN SUM(clicks) = 0 THEN 0
            ELSE SUM(spend) / SUM(clicks)
        END AS CPC,
        CASE 
            WHEN SUM(impressions) = 0 THEN 0
            ELSE ROUND(SUM(spend) / NULLIF(SUM(impressions)::numeric, 0) * 1000.0, 2)
        END AS CPM,
        CASE 
            WHEN SUM(spend) = 0 THEN 0
            ELSE ROUND((SUM(value) - SUM(spend)) * 100.0 / SUM(spend), 2)
        END AS ROMI
    FROM 
        facebook_google_joined_hw5_anton81951
    GROUP BY 
        ad_month, utm_campaign
),
--PARITION AND COMPARISON
comparison AS (
    SELECT
        ad_month,
        utm_campaign,
        total_cost,
        total_impressions,
        total_clicks,
        total_value,
        CTR,
        CPC,
        CPM,
        ROMI,
        LAG(CPM) OVER (PARTITION BY utm_campaign ORDER BY ad_month) AS prev_CPM,
        LAG(CTR) OVER (PARTITION BY utm_campaign ORDER BY ad_month) AS prev_CTR,
        LAG(ROMI) OVER (PARTITION BY utm_campaign ORDER BY ad_month) AS prev_ROMI
    FROM
        aggregated_data
)
SELECT
    ad_month,
    utm_campaign,
    total_cost,
    total_impressions,
    total_clicks,
    total_value,
    CTR,
    CPC,
    CPM,
    ROMI,
    CASE
        WHEN prev_CPM IS NULL THEN NULL
        ELSE ROUND((CPM - prev_CPM) * 100.0 / NULLIF(prev_CPM, 0), 2)
    END AS "CPM_diff_percent",
    CASE
        WHEN prev_CTR IS NULL THEN NULL
        ELSE ROUND((CTR - prev_CTR) * 100.0 / NULLIF(prev_CTR, 0), 2)
    END AS "CTR_diff_percent",
    CASE
        WHEN prev_ROMI IS NULL THEN NULL
        ELSE ROUND((ROMI - prev_ROMI) * 100.0 / NULLIF(prev_ROMI, 0), 2)
    END AS "ROMI_diff_percent"
FROM
    comparison
ORDER BY
    ad_month, utm_campaign;



--DECODING
CREATE OR REPLACE FUNCTION decode_ukrainian (utm_campaign TEXT) RETURNS TEXT AS $$
DECLARE
    decoded_text TEXT;
BEGIN
    decoded_text := utm_campaign;

    decoded_text := REPLACE(decoded_text, '%D0%B0', 'а'); -- а
    decoded_text := REPLACE(decoded_text, '%D0%B1', 'б'); -- б
    decoded_text := REPLACE(decoded_text, '%D0%B2', 'в'); -- в
    decoded_text := REPLACE(decoded_text, '%D0%B3', 'г'); -- г
    decoded_text := REPLACE(decoded_text, '%D0%B4', 'д'); -- д
    decoded_text := REPLACE(decoded_text, '%D0%B5', 'е'); -- е
    decoded_text := REPLACE(decoded_text, '%D1%91', 'є'); -- є
    decoded_text := REPLACE(decoded_text, '%D0%B6', 'ж'); -- ж
    decoded_text := REPLACE(decoded_text, '%D0%B7', 'з'); -- з
    decoded_text := REPLACE(decoded_text, '%D0%B8', 'и'); -- и
    decoded_text := REPLACE(decoded_text, '%D0%B9', 'ї'); -- ї
    decoded_text := REPLACE(decoded_text, '%D0%BA', 'к'); -- к
    decoded_text := REPLACE(decoded_text, '%D0%BB', 'л'); -- л
    decoded_text := REPLACE(decoded_text, '%D0%BC', 'м'); -- м
    decoded_text := REPLACE(decoded_text, '%D0%BD', 'н'); -- н
    decoded_text := REPLACE(decoded_text, '%D0%BE', 'о'); -- о
    decoded_text := REPLACE(decoded_text, '%D0%BF', 'п'); -- п
    decoded_text := REPLACE(decoded_text, '%D1%80', 'р'); -- р
    decoded_text := REPLACE(decoded_text, '%D1%81', 'с'); -- с
    decoded_text := REPLACE(decoded_text, '%D1%82', 'т'); -- т
    decoded_text := REPLACE(decoded_text, '%D1%83', 'у'); -- у
    decoded_text := REPLACE(decoded_text, '%D1%84', 'ф'); -- ф
    decoded_text := REPLACE(decoded_text, '%D1%85', 'х'); -- х
    decoded_text := REPLACE(decoded_text, '%D1%86', 'ц'); -- ц
    decoded_text := REPLACE(decoded_text, '%D1%87', 'ч'); -- ч
    decoded_text := REPLACE(decoded_text, '%D1%88', 'ш'); -- ш
    decoded_text := REPLACE(decoded_text, '%D1%89', 'щ'); -- щ
    decoded_text := REPLACE(decoded_text, '%D1%8A', 'ь'); -- ь
    decoded_text := REPLACE(decoded_text, '%D1%8B', 'и'); -- и
    decoded_text := REPLACE(decoded_text, '%D1%8C', 'ь'); -- ь
    decoded_text := REPLACE(decoded_text, '%D1%8D', 'е'); -- э
    decoded_text := REPLACE(decoded_text, '%D1%8E', 'ю'); -- ю
    decoded_text := REPLACE(decoded_text, '%D1%8F', 'я'); -- я

    decoded_text := REPLACE(decoded_text, '%D0%90', 'А'); -- А
    decoded_text := REPLACE(decoded_text, '%D0%91', 'Б'); -- Б
    decoded_text := REPLACE(decoded_text, '%D0%92', 'В'); -- В
    decoded_text := REPLACE(decoded_text, '%D0%93', 'Г'); -- Г
    decoded_text := REPLACE(decoded_text, '%D0%94', 'Д'); -- Д
    decoded_text := REPLACE(decoded_text, '%D0%95', 'Е'); -- Е
    decoded_text := REPLACE(decoded_text, '%D0%81', 'Є'); -- Є
    decoded_text := REPLACE(decoded_text, '%D0%96', 'Ж'); -- Ж
    decoded_text := REPLACE(decoded_text, '%D0%97', 'З'); -- З
    decoded_text := REPLACE(decoded_text, '%D0%98', 'И'); -- И
    decoded_text := REPLACE(decoded_text, '%D0%99', 'Ї'); -- Ї
    decoded_text := REPLACE(decoded_text, '%D0%9A', 'К'); -- К
    decoded_text := REPLACE(decoded_text, '%D0%9B', 'Л'); -- Л
    decoded_text := REPLACE(decoded_text, '%D0%9C', 'М'); -- М
    decoded_text := REPLACE(decoded_text, '%D0%9D', 'Н'); -- Н
    decoded_text := REPLACE(decoded_text, '%D0%9E', 'О'); -- О
    decoded_text := REPLACE(decoded_text, '%D0%9F', 'П'); -- П
    decoded_text := REPLACE(decoded_text, '%D0%A0', 'Р'); -- Р
    decoded_text := REPLACE(decoded_text, '%D0%A1', 'С'); -- С
    decoded_text := REPLACE(decoded_text, '%D0%A2', 'Т'); -- Т
    decoded_text := REPLACE(decoded_text, '%D0%A3', 'У'); -- У
    decoded_text := REPLACE(decoded_text, '%D0%A4', 'Ф'); -- Ф
    decoded_text := REPLACE(decoded_text, '%D0%A5', 'Х'); -- Х
    decoded_text := REPLACE(decoded_text, '%D0%A6', 'Ц'); -- Ц
    decoded_text := REPLACE(decoded_text, '%D0%A7', 'Ч'); -- Ч
    decoded_text := REPLACE(decoded_text, '%D0%A8', 'Ш'); -- Ш
    decoded_text := REPLACE(decoded_text, '%D0%A9', 'Щ'); -- Щ
    decoded_text := REPLACE(decoded_text, '%D0%AA', 'Ь'); -- Ь
    decoded_text := REPLACE(decoded_text, '%D0%AB', 'И'); -- И
    decoded_text := REPLACE(decoded_text, '%D0%AC', 'Ь'); -- Ь
    decoded_text := REPLACE(decoded_text, '%D0%AD', 'Е'); -- Е
    decoded_text := REPLACE(decoded_text, '%D0%AE', 'Ю'); -- Ю
    decoded_text := REPLACE(decoded_text, '%D0%AF', 'Я'); -- Я

    RETURN decoded_text;
END;
$$ LANGUAGE plpgsql;











	
