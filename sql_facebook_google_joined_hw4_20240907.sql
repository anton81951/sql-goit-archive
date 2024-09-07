
WITH facebook_google_joined_hw4_anton81951 AS (
SELECT 
d.ad_date, 
c.campaign_name,
a.adset_name,
d.spend, d.impressions, d.reach, d.clicks, d.leads, d.value, 'Facebook Ads' AS media_source
FROM facebook_ads_basic_daily d
INNER JOIN facebook_adset a ON a.adset_id = d.adset_id
INNER JOIN facebook_campaign c ON c.campaign_id = d.campaign_id
WHERE d.impressions > 0
  AND d.clicks > 0
UNION ALL
SELECT 
ad_date, campaign_name, adset_name, spend, impressions, reach, clicks, leads, value, 'Google Ads' AS media_source  
FROM google_ads_basic_daily
WHERE impressions > 0
  AND clicks > 0)
SELECT ad_date, 
       media_source,
       campaign_name,
       adset_name,
       SUM(spend) AS "total spent", 
       SUM(impressions) AS "total impressions",
       SUM(clicks) AS "total clicks",
       SUM(value) AS "total value"
FROM facebook_google_joined_hw4_anton81951
GROUP BY ad_date, media_source, campaign_name, adset_name
ORDER BY ad_date;








	
