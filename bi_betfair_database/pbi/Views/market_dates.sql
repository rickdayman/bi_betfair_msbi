






CREATE VIEW [pbi].[market_dates]
AS

-------------------------------------------------------------------------------------------------
-- Processing
-------------------------------------------------------------------------------------------------

SELECT		DISTINCT
			YEAR(market_time) * 100 + MONTH(market_time) AS market_date_month_year
			,FORMAT(market_time, 'MMM') + '-' + CAST(YEAR(market_time) AS CHAR(4))	AS market_date_month_year_desc
 FROM		dbo.event_details
 WHERE		event_id IN (SELECT event_id FROM dbo.event_details WHERE league_name NOT IN ('Lower leagues', 'Other Competitions'))

-------------------------------------------------------------------------------------------------
-- End
-------------------------------------------------------------------------------------------------
