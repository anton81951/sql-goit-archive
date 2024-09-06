WITH google_and_facebook_anton81951 AS (
  SELECT ad_date, spend, impressions, reach, clicks, leads, value, 'Facebook Ads' AS media_source
  FROM facebook_ads_basic_daily
  WHERE impressions > 0
  AND clicks > 0
  UNION ALL
  SELECT ad_date, spend, impressions, reach, clicks, leads, value, 'Google Ads' AS media_source
  FROM google_ads_basic_daily
  WHERE impressions > 0
  AND clicks > 0
)
SELECT ad_date, 
       media_source, 
       SUM(spend) AS "total spent", 
       SUM(impressions) AS "total impressions",
       SUM(clicks) AS "total clicks",
       SUM(value) AS "total value"
FROM google_and_facebook_anton81951
GROUP BY ad_date, media_source
ORDER BY ad_date;


