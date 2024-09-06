SELECT ad_date, spend, clicks, spend / clicks AS "spend per clicks"   
FROM public.facebook_ads_basic_daily
WHERE spend != 0 AND clicks != 0
ORDER BY ad_date desc;