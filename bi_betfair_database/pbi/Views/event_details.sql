






CREATE VIEW [pbi].[event_details]
AS

-------------------------------------------------------------------------------------------------
-- Processing
-------------------------------------------------------------------------------------------------

SELECT		event_id
			,event_name
			,market_time
			,YEAR(market_time) * 100 + MONTH(market_time) AS market_date_month_year
			,FORMAT(market_time, 'MMM') + '-' + CAST(YEAR(market_time) AS CHAR(4))	AS market_date_month_year_desc
			,home_team
			,away_team
			,match_odds_winner
			,league_name
			,event_goes_in_play
			,home_team_goals_from_prv_6
			,away_team_goals_from_prv_6
FROM		dbo.event_details
WHERE		league_name NOT IN ('Lower leagues', 'Other Competitions')

-------------------------------------------------------------------------------------------------
-- End
-------------------------------------------------------------------------------------------------