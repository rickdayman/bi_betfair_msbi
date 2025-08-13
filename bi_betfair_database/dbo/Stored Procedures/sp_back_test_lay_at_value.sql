CREATE PROCEDURE [dbo].[sp_back_test_lay_at_value] (@odds_at_end			DECIMAL(4, 2) = 1.2
													,@bet_selection		VARCHAR(20) = 'The Draw')
AS
BEGIN

SET NOCOUNT ON

-------------------------------------------------------------------------------------------------
-- Get games with decent in-play timestamp data
-------------------------------------------------------------------------------------------------
/*
EXEC [dbo].[sp_back_test_lay_at_value] @odds_at_end	= 1.2, @bet_selection = 'Over 3.5 Goals'
EXEC [dbo].[sp_back_test_lay_at_value] @odds_at_end	= 1.2, @bet_selection = 'Under 3.5 Goals'
*/
--Over 2.5 Goals
--Under 2.5 Goals
--Over 3.5 Goals
--Under 3.5 Goals
--Over 4.5 Goals
--Under 4.5 Goals

DECLARE @market_type VARCHAR(15)
SET		@market_type =	CASE
							WHEN @bet_selection LIKE '%2.5%' THEN 'OVER_UNDER_25'
							WHEN @bet_selection LIKE '%3.5%' THEN 'OVER_UNDER_35'
							WHEN @bet_selection LIKE '%4.5%' THEN 'OVER_UNDER_45'
							ELSE 'MATCH_ODDS'
						END



DROP TABLE IF EXISTS #matches_were_odds_drift_down


DECLARE @bet_amount DECIMAL(5, 2)
SET		@bet_amount = 10.00

DECLARE @commission DECIMAL(5, 2)
SET		@commission = 6.0
SET		@commission = (100.0 - @commission) / 100.0


SELECT		bmo.market_id
			,bmo.runner_id
			,MIN(bmo.matched_bets_order)	AS matched_bets_order
INTO		#matches_were_odds_drift_down
FROM		dbo.bet_market_odds		bmo
			INNER JOIN
			dbo.bet_selection		bsl
			ON bmo.bet_selection_id = bsl.bet_selection_id
WHERE		bmo.odds_price_traded <= @odds_at_end
AND			bsl.selection_desc = @bet_selection
AND			bmo.market_status = 'OPEN'
AND			bmo.market_in_play = 'True'
GROUP BY	bmo.market_id
			,bmo.runner_id
HAVING		MIN(bmo.matched_bets_order) >= 50


-------------------------------------------------------------------------------------------------
-- Calculate profits
-------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #profit_from_lay

SELECT		evt.event_id
			,bmr.runner_name
			,bmr.market_type
			,bmr.market_result
			,evt.event_name
			,evt.market_time
			,evt.home_team
			,evt.away_team
			,evt.league_name

			,CASE
				WHEN bmr.market_result = 'WINNER'
				THEN -1 * @bet_amount
				WHEN bmr.market_result = 'LOSER'
				THEN CAST((@bet_amount / (@odds_at_end - 1.00)) * @commission AS DECIMAL(7, 2))
			END AS lay_profit_loss
INTO		#profit_from_lay
FROM		#matches_were_odds_drift_down		mth
			INNER JOIN
			dbo.bet_market_results				bmr
			ON mth.market_id = bmr.market_id
			AND mth.runner_id = bmr.runner_id
			INNER JOIN
			dbo.bet_markets						bmt
			ON mth.market_id = bmt.market_id
			AND bmt.market_type = @market_type
			INNER JOIN
			dbo.event_details					evt
			ON evt.event_id = bmt.event_id

--WHERE		mth.market_id = 1242349577
--AND			mth.runner_id = 58805



--SELECT		*
--FROM		#profit_from_lay


SELECT		@bet_selection			AS bet_selection
			,@odds_at_end			AS lay_odds
			,SUM(lay_profit_loss)	AS lay_profit_loss
			,COUNT(*)				AS bet_count
			,SUM(CASE WHEN market_result = 'WINNER' THEN 1 ELSE 0 END) AS lose_count
			,SUM(CASE WHEN market_result = 'LOSER' THEN 1 ELSE 0 END) AS win_count
FROM		#profit_from_lay




-------------------------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------------------------


-------------------------------------------------------------------------------------------------
-- End processing
-------------------------------------------------------------------------------------------------

END