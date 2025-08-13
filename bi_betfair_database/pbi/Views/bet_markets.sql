




CREATE VIEW [pbi].[bet_markets]
AS

-------------------------------------------------------------------------------------------------
-- Processing
-------------------------------------------------------------------------------------------------

SELECT		market_id
			,market_type
			,event_id
			,event_name
			,market_time
			,YEAR(market_time) * 100 + MONTH(market_time) AS market_date_month_year
			,FORMAT(market_time, 'MMM') + '-' + CAST(YEAR(market_time) AS CHAR(4))	AS market_date_month_year_desc
			,home_team
			,away_team
			,market_open_timestamp
			,market_inplay_timestamp
			,pre_inplay_timestamp_count
			,is_open_24hrs_before_kickoff
 FROM		dbo.bet_markets
 WHERE		event_id IN (SELECT event_id FROM dbo.event_details WHERE league_name NOT IN ('Lower leagues', 'Other Competitions'))

-------------------------------------------------------------------------------------------------
-- End
-------------------------------------------------------------------------------------------------
