CREATE PROCEDURE [dbo].[sp_back_test_scalp_on_under_market]	(@hours_before		INT = 8
															,@spread_points		INT = 1
															,@market_type		VARCHAR(15) = 'OVER_UNDER_45'
															)
AS
BEGIN

SET NOCOUNT ON

--EXEC [dbo].[sp_back_test_scalp_on_under_market]	@hours_before = 1, @spread_points = 1, @market_type = 'OVER_UNDER_25'
--EXEC [dbo].[sp_back_test_scalp_on_under_market]	@hours_before = 1, @spread_points = 2, @market_type = 'OVER_UNDER_25'
--EXEC [dbo].[sp_back_test_scalp_on_under_market]	@hours_before = 1, @spread_points = 3, @market_type = 'OVER_UNDER_25'

--EXEC [dbo].[sp_back_test_scalp_on_under_market]	@hours_before = 2, @spread_points = 1, @market_type = 'OVER_UNDER_25'
--EXEC [dbo].[sp_back_test_scalp_on_under_market]	@hours_before = 2, @spread_points = 2, @market_type = 'OVER_UNDER_25'
--EXEC [dbo].[sp_back_test_scalp_on_under_market]	@hours_before = 2, @spread_points = 3, @market_type = 'OVER_UNDER_25'

--EXEC [dbo].[sp_back_test_scalp_on_under_market]	@hours_before = 4, @spread_points = 1, @market_type = 'OVER_UNDER_25'
--EXEC [dbo].[sp_back_test_scalp_on_under_market]	@hours_before = 4, @spread_points = 2, @market_type = 'OVER_UNDER_25'
--EXEC [dbo].[sp_back_test_scalp_on_under_market]	@hours_before = 4, @spread_points = 3, @market_type = 'OVER_UNDER_25'

--EXEC [dbo].[sp_back_test_scalp_on_under_market]	@hours_before = 8, @spread_points = 1, @market_type = 'OVER_UNDER_25'
--EXEC [dbo].[sp_back_test_scalp_on_under_market]	@hours_before = 8, @spread_points = 2, @market_type = 'OVER_UNDER_25'
--EXEC [dbo].[sp_back_test_scalp_on_under_market]	@hours_before = 8, @spread_points = 3, @market_type = 'OVER_UNDER_25'

-------------------------------------------------------------------------------------------------
-- Create odds table with specified hours before
-------------------------------------------------------------------------------------------------

EXEC dbo.sp_build_bet_market_odds_drift_pre_kickoff @drift_percent = 1.01
EXEC dbo.sp_build_market_odds_hour_before_game @hours_before
EXEC dbo.sp_build_event_odds

-------------------------------------------------------------------------------------------------
-- Determine under selection
-------------------------------------------------------------------------------------------------

DECLARE @bet_selection VARCHAR(15)
SET		@bet_selection = CASE
							WHEN @market_type = 'OVER_UNDER_25' THEN 'Under 2.5 Goals'
							WHEN @market_type = 'OVER_UNDER_35' THEN 'Under 3.5 Goals'
							WHEN @market_type = 'OVER_UNDER_45' THEN 'Under 4.5 Goals'
						END

-------------------------------------------------------------------------------------------------
-- Odds at start
-------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #events

SELECT		evo.event_id
			,evo.event_name
			,evo.home_team
			,evo.away_team
			,evo.market_time
			,lge.league_name
			,bmt.market_id
			,CASE
				WHEN @market_type = 'OVER_UNDER_25' THEN over_under_25_winner
				WHEN @market_type = 'OVER_UNDER_35' THEN over_under_35_winner
				WHEN @market_type = 'OVER_UNDER_45' THEN over_under_45_winner
			END AS over_under_winner
			,CASE
				WHEN @market_type = 'OVER_UNDER_25' THEN under_25_goals
				WHEN @market_type = 'OVER_UNDER_35' THEN under_35_goals
				WHEN @market_type = 'OVER_UNDER_45' THEN under_45_goals
			END AS under_goals
			,CASE
				WHEN @market_type = 'OVER_UNDER_25' THEN under_25_goals_lay
				WHEN @market_type = 'OVER_UNDER_35' THEN under_35_goals_lay
				WHEN @market_type = 'OVER_UNDER_45' THEN under_45_goals_lay
			END AS under_goals_lay

			,lge.home_team_goals_from_prv_6 + lge.away_team_goals_from_prv_6 AS prev_6_goals

INTO		#events
FROM		dbo.event_odds			evo
			INNER JOIN
			dbo.event_details		lge
			ON evo.event_id = lge.event_id
			INNER JOIN
			dbo.bet_markets			bmt
			ON bmt.event_id = evo.event_id
			AND bmt.market_type = @market_type
			AND bmt.is_open_24hrs_before_kickoff = 1

			--AND bmt.pre_inplay_timestamp_count >= 50

			INNER JOIN
			dbo.bet_market_odds_drift_pre_kickoff dft
			ON evo.event_id = dft.event_id
			AND dft.runner_name_display = @bet_selection
			AND dft.drift_desc IN ('Drift down')
			AND dft.market_8hrs_before_order >= 3

--WHERE		bmt.market_id =  1227215739
--WHERE		evo.event_name IN ('Birmingham v Peterborough'
--								,'Birmingham v Wrexham'
--								,'Bristol Rovers v Bolton'
--								,'Bristol Rovers v Rotherham'
--								)


DELETE FROM #events WHERE under_goals IS NULL











DECLARE @spread_percent DECIMAL(4, 2)
SET		@spread_percent = 0.8

DECLARE @bet_amount DECIMAL(5, 2)
SET		@bet_amount = 10.00

DECLARE @commission DECIMAL(5, 2)
SET		@commission = 5.0
SET		@commission = (100.0 - @commission) / 100.0



DROP TABLE IF EXISTS #scalper;

SELECT		evt.event_id
			,evt.market_id
			,evt.event_name
			,evt.home_team
			,evt.away_team
			,evt.league_name
			,evt.market_time
			,evt.over_under_winner
			,evt.under_goals		AS bet_at_start_under
			,evt.prev_6_goals

			,CASE
				WHEN evt.under_goals BETWEEN 1.01 AND 1.99 THEN evt.under_goals - 0.01 * @spread_points
				WHEN evt.under_goals BETWEEN 2.00 AND 2.98 THEN evt.under_goals - 0.02 * @spread_points
				WHEN evt.under_goals BETWEEN 3.00 AND 3.95 THEN evt.under_goals - 0.05 * @spread_points
				WHEN evt.under_goals BETWEEN 4.00 AND 5.90 THEN evt.under_goals - 0.10 * @spread_points
				WHEN evt.under_goals BETWEEN 6.00 AND 9.80 THEN evt.under_goals - 0.20 * @spread_points
				WHEN evt.under_goals BETWEEN 10.00 AND 19.5 THEN evt.under_goals - 0.50 * @spread_points
				WHEN evt.under_goals BETWEEN 20.00 AND 29.00 THEN evt.under_goals - 1.00 * @spread_points
				WHEN evt.under_goals BETWEEN 30.00 AND 48.00 THEN evt.under_goals - 2.00 * @spread_points
				WHEN evt.under_goals BETWEEN 50.00 AND 95.00 THEN evt.under_goals - 5.00 * @spread_points
				WHEN evt.under_goals BETWEEN 100.00 AND 1000.0 THEN evt.under_goals - 10.00 * @spread_points
			END AS lay_under_for_scalp


			,(SELECT	MIN(o.odds_price_traded_lay)
			  FROM		dbo.bet_market_odds		o
			  			INNER JOIN
						dbo.bet_markets			b
						ON o.market_id = b.market_id
						INNER JOIN
						dbo.event_details		e
						ON b.event_id = e.event_id
			WHERE		CASE WHEN o.odds_timestamp > DATEADD(HOUR, -1 * @hours_before, e.event_goes_in_play) THEN 1 ELSE 0 END = 1
			AND			o.runner_name = @bet_selection
			AND			o.market_id = evt.market_id)	AS lowest_lay_value

			  -- ####################################################################################################################
			  -- Need to be after the bet was placed
			  -- ####################################################################################################################

INTO		#scalper
FROM		#events					evt
--WHERE		league_name <> 'English League 1'







--SELECT		o.*
--			,e.event_goes_in_play
--			,CASE WHEN o.odds_timestamp > DATEADD(HOUR, -1 * 0, e.event_goes_in_play) THEN 0 ELSE 1 END
--FROM		dbo.bet_market_odds		o
--			INNER JOIN
--			dbo.bet_markets			b
--			ON o.market_id = b.market_id
--			INNER JOIN
--			dbo.event_details		e
--			ON b.event_id = e.event_id
--WHERE		CASE WHEN o.odds_timestamp > DATEADD(HOUR, -1 * 0, e.event_goes_in_play) THEN 1 ELSE 0 END = 1
--AND			o.runner_name = 'Under 2.5 Goals'
--AND			o.market_id = 1232754072
--ORDER BY	odds_timestamp




;WITH SCALPPROFIT AS
(
SELECT		scp.*
			,CASE

				WHEN lowest_lay_value > lay_under_for_scalp
				THEN -1 * @bet_amount

				WHEN lowest_lay_value <= lay_under_for_scalp
				AND over_under_winner = @bet_selection
				THEN (((bet_at_start_under - 1.0) * @bet_amount) - ((lay_under_for_scalp - 1.0) * @bet_amount)) * @commission

				WHEN lowest_lay_value <= lay_under_for_scalp
				AND over_under_winner <> @bet_selection
				THEN 0.00

			END AS profit_loss
			,CASE
				WHEN lowest_lay_value > lay_under_for_scalp
				THEN -1 * @bet_amount
				WHEN lowest_lay_value <= lay_under_for_scalp
				THEN (@bet_amount - @bet_amount * (lay_under_for_scalp / bet_at_start_under)) * @commission
			END AS cash_out

FROM		#scalper			scp
)



SELECT		@hours_before		AS hours_before
			,@spread_points		AS spread_points
			,@market_type		AS market_type
			,SUM(profit_loss)	AS profit_loss
			,SUM(cash_out)		AS cash_out
			,COUNT(*)			AS freq
			,SUM(CASE WHEN profit_loss >= 0 THEN 1 ELSE 0 END) AS scalp_win
			,SUM(CASE WHEN profit_loss < 0 THEN 1 ELSE 0 END) AS scalp_loss
FROM		SCALPPROFIT

--SELECT		@hours_before		AS hours_before
--			,@spread_points		AS spread_points
--			,@market_type		AS market_type
--			,prev_6_goals
--			,SUM(profit_loss)	AS profit_loss
--			,SUM(cash_out)		AS cash_out
--			,COUNT(*)			AS freq
--			,SUM(CASE WHEN profit_loss >= 0 THEN 1 ELSE 0 END) AS scalp_win
--			,SUM(CASE WHEN profit_loss < 0 THEN 1 ELSE 0 END) AS scalp_loss
--FROM		SCALPPROFIT
--GROUP BY	prev_6_goals
--ORDER BY	prev_6_goals

--SELECT		bet_at_start_under
--			,@hours_before		AS hours_before
--			,@spread_points		AS spread_points
--			,@market_type		AS market_type
--			,SUM(profit_loss)	AS profit_loss
--			,SUM(cash_out)		AS cash_out
--			,COUNT(*)			AS freq
--			,SUM(CASE WHEN profit_loss >= 0 THEN 1 ELSE 0 END) AS scalp_win
--			,SUM(CASE WHEN profit_loss < 0 THEN 1 ELSE 0 END) AS scalp_loss
--FROM		SCALPPROFIT
--GROUP BY	bet_at_start_under
--ORDER BY	bet_at_start_under







-------------------------------------------------------------------------------------------------
-- End processing
-------------------------------------------------------------------------------------------------

END