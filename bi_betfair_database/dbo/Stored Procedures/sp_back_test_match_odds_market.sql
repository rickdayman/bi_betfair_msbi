CREATE PROCEDURE [dbo].[sp_back_test_match_odds_market] (@hours_before		INT				= 8
														,@drift_percent		DECIMAL(4, 2)	= 1.05
														)
AS
BEGIN

SET NOCOUNT ON

--EXEC [dbo].[sp_back_test_match_odds_market] @hours_before = 1, @drift_percent = 1.02
--EXEC [dbo].[sp_back_test_match_odds_market] @hours_before = 2, @drift_percent = 1.02
--EXEC [dbo].[sp_back_test_match_odds_market] @hours_before = 3, @drift_percent = 1.02
--EXEC [dbo].[sp_back_test_match_odds_market] @hours_before = 4, @drift_percent = 1.02
--EXEC [dbo].[sp_back_test_match_odds_market] @hours_before = 5, @drift_percent = 1.02
--EXEC [dbo].[sp_back_test_match_odds_market] @hours_before = 6, @drift_percent = 1.02
--EXEC [dbo].[sp_back_test_match_odds_market] @hours_before = 7, @drift_percent = 1.02
--EXEC [dbo].[sp_back_test_match_odds_market] @hours_before = 8, @drift_percent = 1.02
--EXEC [dbo].[sp_back_test_match_odds_market] @hours_before = 9, @drift_percent = 1.02
--EXEC [dbo].[sp_back_test_match_odds_market] @hours_before = 12, @drift_percent = 1.02
--EXEC [dbo].[sp_back_test_match_odds_market] @hours_before = 18, @drift_percent = 1.02

-------------------------------------------------------------------------------------------------
-- Create odds table with specified hours before
-------------------------------------------------------------------------------------------------

EXEC dbo.sp_build_bet_market_odds_drift_pre_kickoff @drift_percent
EXEC dbo.sp_build_market_odds_hour_before_game @hours_before
EXEC dbo.sp_build_event_odds

-------------------------------------------------------------------------------------------------
-- Processing
-------------------------------------------------------------------------------------------------


DROP TABLE IF EXISTS #events


DECLARE @bet_amount DECIMAL(5, 2)
SET		@bet_amount = 10.00

DECLARE @commission DECIMAL(5, 2)
SET		@commission = 5.0
SET		@commission = (100.0 - @commission) / 100.0


SELECT		evo.*
			,lge.league_name
			,dft.market_8hrs_before_order
			,dft.drift_desc
			,CASE
				WHEN [Home] < [Draw]
				AND [Home] < [Away]
				AND [Home] <= 1.5
				THEN 'Home big favourite'
				WHEN [Away] < [Draw]
				AND [Away] < [Home]
				AND [Away] <= 1.5
				THEN 'Away big favourite'


				WHEN [Home] < [Draw]
				AND [Home] < [Away]
				THEN 'Home favourite'
				WHEN [Away] < [Draw]
				AND [Away] < [Home]
				THEN 'Away favourite'
				WHEN [Draw] < [Away]
				AND [Draw] < [Home]
				THEN 'Draw favourite'
			END AS favourite
			,CASE
				WHEN evo.match_odds_winner = 'Home'
				THEN CAST(((@bet_amount * Home) - @bet_amount) * @commission AS DECIMAL(7, 2))
				ELSE -1 * @bet_amount
			END AS bet_home_profit_loss
			,CASE
				WHEN evo.match_odds_winner = 'The Draw'
				THEN CAST(((@bet_amount * Draw) - @bet_amount) * @commission AS DECIMAL(7, 2))
				ELSE -1 * @bet_amount
			END AS bet_draw_profit_loss
			,CASE
				WHEN evo.match_odds_winner = 'Away'
				THEN CAST(((@bet_amount * Away) - @bet_amount) * @commission AS DECIMAL(7, 2))
				ELSE -1 * @bet_amount
			END AS bet_away_profit_loss

			,CASE
				WHEN evo.match_odds_winner = 'Home'
				THEN -1 * @bet_amount
				ELSE CAST((@bet_amount / (home_lay - 1.00)) * @commission AS DECIMAL(7, 2))
			END AS lay_home_profit_loss
			,CASE
				WHEN evo.match_odds_winner = 'The Draw'
				THEN -1 * @bet_amount
				ELSE CAST((@bet_amount / (draw_lay - 1.00)) * @commission AS DECIMAL(7, 2))
			END AS lay_draw_profit_loss
			,CASE
				WHEN evo.match_odds_winner = 'Away'
				THEN -1 * @bet_amount
				ELSE CAST((@bet_amount / (away_lay - 1.00)) * @commission AS DECIMAL(7, 2))
			END AS lay_away_profit_loss
			,lge.home_team_goals_from_prv_6 
			,lge.away_team_goals_from_prv_6
			,lge.home_team_goals_from_prv_6 - lge.away_team_goals_from_prv_6 AS form_diff

INTO		#events
-- SELECT	*
FROM		dbo.event_odds			evo
			INNER JOIN
			dbo.event_details		lge
			ON evo.event_id = lge.event_id
			INNER JOIN
			dbo.bet_markets			bmt
			ON bmt.event_id = evo.event_id
			AND bmt.market_type = 'MATCH_ODDS'
			AND bmt.is_open_24hrs_before_kickoff = 1


			INNER JOIN
			dbo.bet_market_odds_drift_pre_kickoff dft
			ON evo.event_id = dft.event_id
			AND dft.runner_name_display = 'Home'
			AND dft.drift_desc NOT IN ('Drift down')
			AND dft.market_8hrs_before_order >= 5


WHERE		[Home] IS NOT NULL
AND			[Draw] IS NOT NULL
AND			[Away] IS NOT NULL
AND			lge.league_name <> 'Lower leagues'






-------------------------------------------------------------------------------------------------
-- Results
-------------------------------------------------------------------------------------------------

--SELECT		form_diff
--			,COUNT(*) AS game_count
--			,'|' AS '|'
--			,SUM(bet_home_profit_loss) AS bet_home_profit_loss
--			,SUM(bet_draw_profit_loss) AS bet_draw_profit_loss
--			,SUM(bet_away_profit_loss) AS bet_away_profit_loss
--			,'|' AS '|'
--			,SUM(lay_home_profit_loss) AS lay_home_profit_loss
--			,SUM(lay_draw_profit_loss) AS lay_draw_profit_loss
--			,SUM(lay_away_profit_loss) AS lay_away_profit_loss
--			,'|' AS '|'
--			,AVG(market_8hrs_before_order)	AS avg_market_8hrs_before_order
--FROM		#events

----WHERE		home_lay >= 1.95
----AND			home_lay <= 3.25
--------WHERE		Away >= 1.6
--------AND			Away <= 7.2

--GROUP BY	form_diff
--ORDER BY	form_diff


SELECT		league_name
			,COUNT(*) AS game_count
			,'|' AS '|'
			,SUM(bet_home_profit_loss) AS bet_home_profit_loss
			,SUM(bet_draw_profit_loss) AS bet_draw_profit_loss
			,SUM(bet_away_profit_loss) AS bet_away_profit_loss
			,'|' AS '|'
			,SUM(lay_home_profit_loss) AS lay_home_profit_loss
			,SUM(lay_draw_profit_loss) AS lay_draw_profit_loss
			,SUM(lay_away_profit_loss) AS lay_away_profit_loss
			,'|' AS '|'
			,AVG(market_8hrs_before_order)	AS avg_market_8hrs_before_order
FROM		#events

WHERE		1 = 1
--AND			home_lay >= 1.95
--AND			home_lay <= 3.25

AND			home_lay >= 1.95
AND			home_lay <= 4.9


GROUP BY	league_name
ORDER BY	league_name


SELECT		@drift_percent AS drift_percent
			,@hours_before AS bet_hours_before
			,'|' AS '|'
			,SUM(bet_home_profit_loss) AS bet_home_profit_loss
			,SUM(bet_draw_profit_loss) AS bet_draw_profit_loss
			,SUM(bet_away_profit_loss) AS bet_away_profit_loss
			,'|' AS '|'
			,SUM(lay_home_profit_loss) AS lay_home_profit_loss
			,SUM(lay_draw_profit_loss) AS lay_draw_profit_loss
			,SUM(lay_away_profit_loss) AS lay_away_profit_loss
			,'|' AS '|'
			,COUNT(*) AS bet_count

			,SUM(lay_home_profit_loss) / COUNT(*)	AS profit_per_bet
			,AVG(market_8hrs_before_order)	AS avg_market_8hrs_before_order
FROM		#events

WHERE		1 = 1
--AND			home_lay >= 1.95
--AND			home_lay <= 3.25

AND			home_lay >= 1.95
AND			home_lay <= 4.9


SELECT		favourite
			,COUNT(*) AS game_count
			,SUM(bet_home_profit_loss) AS bet_home_profit_loss
			,SUM(bet_draw_profit_loss) AS bet_draw_profit_loss
			,SUM(bet_away_profit_loss) AS bet_away_profit_loss
			,SUM(lay_home_profit_loss) AS lay_home_profit_loss
FROM		#events

WHERE		1 = 1
--AND			home_lay >= 1.95
--AND			home_lay <= 3.25

--AND			home_lay >= 1.95
--AND			home_lay <= 4.9

GROUP BY	favourite
ORDER BY	favourite




-- ###########################################################################
-- ###########################################################################
-- Bet usual (maybe 3-4%)
-- Odds drift has to be flat or up
-- Lay on Home between Between 1.95 and 3,25
-- ###########################################################################
-- ###########################################################################

-------------------------------------------------------------------------------------------------
-- End processing
-------------------------------------------------------------------------------------------------

END