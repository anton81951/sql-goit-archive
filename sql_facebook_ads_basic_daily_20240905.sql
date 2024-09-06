SELECT ad_date, campaign_id, 
       SUM(spend) AS "total spent", 
       SUM(impressions) AS "total impressions", 
       SUM(clicks) AS "total clicks", 
       SUM(value) AS "total value",
       SUM(spend) / NULLIF(SUM(clicks), 0) AS "CPC",
       round(SUM(spend) / NULLIF(SUM(impressions)::numeric, 0)*1000.0) AS "CPM",
       (SUM(clicks) * 100.0 / NULLIF(SUM(impressions), 0)) AS "CTR",
       ((SUM(value) - SUM(spend)) * 100.0 / SUM(spend)) AS "ROMI (%)"
FROM public.facebook_ads_basic_daily
WHERE impressions > 0
      AND clicks > 0
GROUP BY ad_date, campaign_id
ORDER BY ad_date;

SELECT campaign_id,
       SUM(spend) AS "total spent", 
       SUM(value) AS "total value",
       ((SUM(value) - SUM(spend)) * 100.0 / SUM(spend)) AS "ROMI (%)"
FROM public.facebook_ads_basic_daily
WHERE spend > 0
  AND value > 0
GROUP BY campaign_id
HAVING SUM(spend) > 500000
ORDER BY "ROMI (%)" DESC
LIMIT 1;