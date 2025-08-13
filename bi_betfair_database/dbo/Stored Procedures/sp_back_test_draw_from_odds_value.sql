CREATE PROCEDURE [dbo].[sp_back_test_draw_from_odds_value] (@odds_at_end			DECIMAL(4, 2) = 1.1
															,@bet_selection		VARCHAR(20) = 'Under 3.5 Goals'
															,@after_x_mins		INT = 47
															)
AS
BEGIN

SET NOCOUNT ON

-------------------------------------------------------------------------------------------------
-- Processing
-------------------------------------------------------------------------------------------------

-- ##############################################################################################
-- ##############################################################################################
-- ############################## DAMN, can't preset odds to match ##############################
-- ##############################################################################################
-- ##############################################################################################


DECLARE @bet_amount DECIMAL(5, 2)
SET		@bet_amount = 10.00

DECLARE @commission DECIMAL(5, 2)
SET		@commission = 5.0
SET		@commission = (100.0 - @commission) / 100.0

-----------------------------------------------------------------------------------------------------
-- Adjust @after_x_mins for half-time
-----------------------------------------------------------------------------------------------------

SET @after_x_mins = @after_x_mins + 15

-----------------------------------------------------------------------------------------------------
-- Bet selection
-----------------------------------------------------------------------------------------------------

DECLARE @bet_selection_id INT
SET		@bet_selection_id = (SELECT bet_selection_id FROM dbo.bet_selection WHERE selection_desc = @bet_selection)

-----------------------------------------------------------------------------------------------------
-- Ensure odds available for selected range
-----------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #odds_in_range

SELECT		bmo.market_id
			,bmo.runner_id
			,SUM(CASE
					WHEN DATEDIFF(MINUTE, bmr.market_inplay_timestamp, bmo.odds_timestamp) >= @after_x_mins - 10
					AND DATEDIFF(MINUTE, bmr.market_inplay_timestamp, bmo.odds_timestamp) < @after_x_mins
					THEN 1
					ELSE 0
				 END) AS timestamp_before
			,SUM(CASE
					WHEN DATEDIFF(MINUTE, bmr.market_inplay_timestamp, bmo.odds_timestamp) >= @after_x_mins
					THEN 1
					ELSE 0
				 END) AS timestamp_after
INTO		#odds_in_range
FROM		dbo.bet_market_odds		bmo
			INNER JOIN
			dbo.bet_markets			bmr
			ON bmr.market_id = bmo.market_id
WHERE		1 = 1
AND			bmo.bet_selection_id = @bet_selection_id
AND			bmo.market_status = 'OPEN'
AND			bmo.market_in_play = 'True'
AND			bmr.market_time <= '2024-12-01' -- Testing

--AND			bmr.market_time > '2024-12-01' -- Testing

--AND			bmo.market_id = 1218984594

GROUP BY	bmo.market_id
			,bmo.runner_id

-----------------------------------------------------------------------------------------------------
-- Create ladder with prev value range
-----------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #match_odds_ladder;

SELECT		bmo.market_id
			,bmo.runner_id
			,evt.league_name
			,bmo.matched_bets_order
			,bmo.odds_timestamp
			,DATEDIFF(MINUTE, bmr.market_inplay_timestamp, bmo.odds_timestamp) AS minutes_in_play
			,bmo.odds_price_traded
			,LAG(odds_price_traded, 1) OVER(PARTITION BY bmo.market_id, bmo.runner_id ORDER BY odds_timestamp ASC) AS prv_odds_price_traded
			,CASE WHEN DATEDIFF(MINUTE, bmr.market_inplay_timestamp, bmo.odds_timestamp) >= @after_x_mins THEN 1 ELSE 0 END AS is_range
INTO		#match_odds_ladder
FROM		dbo.bet_market_odds		bmo
			INNER JOIN
			#odds_in_range			oir
			ON bmo.market_id = oir.market_id
			AND bmo.runner_id = oir.runner_id
			AND oir.timestamp_before >= 1
			AND oir.timestamp_after >= 7
			INNER JOIN
			dbo.bet_markets			bmr
			ON bmr.market_id = bmo.market_id
			INNER JOIN
			dbo.event_details		evt
			ON bmr.event_id = evt.event_id
WHERE		bmo.market_status = 'OPEN'
AND			bmo.market_in_play = 'True'
AND			DATEDIFF(MINUTE, bmr.market_inplay_timestamp, bmo.odds_timestamp) >= @after_x_mins - 10

-------------------------------------------------------------------------------------------------------
---- Create ladder with prev value range
-------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #matches_were_odds_drift_down

SELECT		lad.market_id
			,lad.runner_id
			,lad.league_name
			,lad.matched_bets_order
			,lad.odds_price_traded
			,lad.prv_odds_price_traded
			,lad.minutes_in_play
			,ROW_NUMBER() OVER (PARTITION BY lad.market_id, lad.runner_id ORDER BY lad.matched_bets_order) AS match_order

			,CASE WHEN lad.odds_price_traded = @odds_at_end THEN 1 ELSE 0 END AS is_exact

INTO		#matches_were_odds_drift_down
FROM		#match_odds_ladder	lad
WHERE		is_range = 1
AND			@odds_at_end BETWEEN lad.odds_price_traded AND lad.prv_odds_price_traded
AND			ABS(lad.odds_price_traded - lad.prv_odds_price_traded) <= 0.1 -- ensure the odds are drifting and it hasn't jumped the value because of a goal

-----------------------------------------------------------------------------------------------------
-- Calculate profit
-----------------------------------------------------------------------------------------------------

;WITH DRAWPROFITATEND AS
(
SELECT		dft.*
			,bmr.market_result
			,CASE
				WHEN bmr.market_result = 'WINNER'
				THEN ((@bet_amount * @odds_at_end) - @bet_amount) * @commission
				ELSE -1 * @bet_amount
			END AS profit_loss

			--,CASE
			--	WHEN bmr.market_result = 'WINNER'
			--	THEN ((@bet_amount * dft.odds_price_traded) - @bet_amount) * @commission -- ######################################
			--	ELSE -1 * @bet_amount
			--END AS profit_loss

FROM		dbo.bet_market_odds				bmo
			INNER JOIN
			#matches_were_odds_drift_down	dft
			ON bmo.market_id = dft.market_id
			AND bmo.runner_id = dft.runner_id
			AND bmo.matched_bets_order = dft.matched_bets_order
			AND dft.match_order = 1
			INNER JOIN
			dbo.bet_market_results			bmr
			ON bmo.market_id = bmr.market_id
			AND bmo.runner_id = bmr.runner_id
)
--SELECT		OBJECT_NAME(@@PROCID)				AS test_proc_name
--			,@bet_selection						AS bet_selection
--			,@after_x_mins - 15					AS after_x_mins
--			,@odds_at_end						AS odds_at_end
--			,SUM(profit_loss)					AS profit_loss
--			,COUNT(*)							AS match_count
--			,SUM(CASE WHEN market_result = 'WINNER' THEN 1 ELSE 0 END) AS win_count
--			,SUM(CASE WHEN market_result = 'LOSER' THEN 1 ELSE 0 END) AS lose_count
--FROM		DRAWPROFITATEND

SELECT		OBJECT_NAME(@@PROCID)				AS test_proc_name
			,@bet_selection						AS bet_selection
			,@after_x_mins - 15					AS after_x_mins -- minus 15 to exclude half-time
			,league_name
			,@odds_at_end						AS odds_at_end
			,SUM(profit_loss)					AS profit_loss
			,COUNT(*)							AS match_count
			,SUM(CASE WHEN market_result = 'WINNER' THEN 1 ELSE 0 END) AS win_count
			,SUM(CASE WHEN market_result = 'LOSER' THEN 1 ELSE 0 END) AS lose_count

			--,AVG(minutes_in_play)	AS avg_minutes_in_play
			--,MIN(minutes_in_play)	AS min_minutes_in_play
			--,MAX(minutes_in_play)	AS max_minutes_in_play

FROM		DRAWPROFITATEND
GROUP BY	league_name
ORDER BY	league_name

-------------------------------------------------------------------------------------------------
-- End processing
-------------------------------------------------------------------------------------------------

END