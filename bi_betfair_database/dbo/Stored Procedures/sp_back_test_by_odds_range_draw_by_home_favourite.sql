CREATE PROCEDURE [dbo].[sp_back_test_by_odds_range_draw_by_home_favourite]
AS
BEGIN

SET NOCOUNT ON

-------------------------------------------------------------------------------------------------
-- Processing
-------------------------------------------------------------------------------------------------

DECLARE @hours_before		INT				= 8
DECLARE @drift_percent		DECIMAL(4, 2)	= 1.02

-------------------------------------------------------------------------------------------------
-- Create odds table with specified hours before
-------------------------------------------------------------------------------------------------

EXEC dbo.sp_build_bet_market_odds_drift_pre_kickoff @drift_percent
EXEC dbo.sp_build_market_odds_hour_before_game @hours_before
EXEC dbo.sp_build_event_odds


DROP TABLE IF EXISTS #events


DECLARE @bet_amount DECIMAL(5, 2)
SET		@bet_amount = 10.00

DECLARE @commission DECIMAL(5, 2)
SET		@commission = 5.0
SET		@commission = (100.0 - @commission) / 100.0


SELECT		evo.[event_id]
			,evo.[event_name]
			,evo.[home_team]
			,evo.[away_team]
			,evo.[market_time]
			,evo.[match_odds_winner]
			,evo.[Home]
			,evo.[Draw]
			,evo.[Away]
			,lge.league_name
			,dft.market_8hrs_before_order
			,dft.drift_desc
			,CAST(dft.drift_percent AS DECIMAL(5, 2)) AS drift_percent
			,CASE
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

			--,CASE
			--	WHEN evo.match_odds_winner = 'Home'
			--	THEN -1 * @bet_amount
			--	ELSE CAST((@bet_amount / (home_lay - 1.00)) * @commission AS DECIMAL(7, 2))
			--END AS lay_home_profit_loss
			--,CASE
			--	WHEN evo.match_odds_winner = 'The Draw'
			--	THEN -1 * @bet_amount
			--	ELSE CAST((@bet_amount / (draw_lay - 1.00)) * @commission AS DECIMAL(7, 2))
			--END AS lay_draw_profit_loss
			--,CASE
			--	WHEN evo.match_odds_winner = 'Away'
			--	THEN -1 * @bet_amount
			--	ELSE CAST((@bet_amount / (away_lay - 1.00)) * @commission AS DECIMAL(7, 2))
			--END AS lay_away_profit_loss

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
			AND dft.runner_name_display = 'The Draw'
			--AND dft.drift_desc NOT IN ('Drift down')
			AND dft.market_8hrs_before_order >= 5


WHERE		[Home] IS NOT NULL
AND			[Draw] IS NOT NULL
AND			[Away] IS NOT NULL
--AND			lge.league_name <> 'Lower leagues'






--SELECT		*
--FROM		#events









SELECT		league_name

			,SUM(bet_draw_profit_loss) AS bet_draw_profit_loss

			,COUNT(*) AS bet_count
			--,form_diff
FROM		#events
WHERE		favourite = 'Home favourite'
AND			Draw BETWEEN 4.9 AND 7

AND			Draw BETWEEN 4.9 AND 8.2

GROUP BY	league_name
ORDER BY	league_name
			--,form_diff







--SELECT		Draw

--			,SUM(bet_draw_profit_loss) AS bet_draw_profit_loss

--			,COUNT(*) AS bet_count
--			--,form_diff
--FROM		#events
--WHERE		favourite = 'Home favourite'
----AND			Draw BETWEEN 4.9 AND 7
--GROUP BY	Draw
--ORDER BY	Draw
--			--,form_diff



-- ###########################################################################
-- ###########################################################################
-- Bet smaller than usual
-- If Home odds are favourite
-- Bet on Draw between 4.0 AND 6.0
-- ###########################################################################
-- ###########################################################################


-------------------------------------------------------------------------------------------------
-- End processing
-------------------------------------------------------------------------------------------------

END