CREATE PROCEDURE [dbo].[sp_back_test_after_x_mins] (@bet_selection		VARCHAR(20) = 'Under 4.5 Goals'
													,@after_x_mins		INT = 85
													)
AS
BEGIN

SET NOCOUNT ON

-------------------------------------------------------------------------------------------------
-- Processing
-------------------------------------------------------------------------------------------------


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
					WHEN DATEDIFF(MINUTE, bmr.market_inplay_timestamp, bmo.odds_timestamp) >= @after_x_mins
					AND	 DATEDIFF(MINUTE, bmr.market_inplay_timestamp, bmo.odds_timestamp) < @after_x_mins + 2
					THEN 1
					ELSE 0
				 END) AS timestamp_during
			,SUM(CASE
					WHEN DATEDIFF(MINUTE, bmr.market_inplay_timestamp, bmo.odds_timestamp) >= @after_x_mins + 2
					THEN 1
					ELSE 0
				 END) AS timestamp_after
INTO		#odds_in_range
FROM		dbo.bet_market_odds		bmo
			INNER JOIN
			dbo.bet_markets			bmr
			ON bmr.market_id = bmo.market_id

			INNER JOIN
			dbo.event_details		evt
			ON bmr.event_id = evt.event_id
			AND evt.league_name IN ('English Premier League'
									,'Spanish La Liga'
									,'Italian Serie A'
									,'German Bundesliga'
									)

-- SELECT DISTINCT league_name FROM dbo.event_details

WHERE		1 = 1
AND			bmo.bet_selection_id = @bet_selection_id
AND			bmo.market_status = 'OPEN'
AND			bmo.market_in_play = 'True'
AND			bmr.market_time <= '2024-12-01' -- Testing

--AND			bmr.market_time > '2024-12-01' -- Testing

--AND			bmo.market_id IN (1218381278
--								,1218178304
--								,1224077197
--								,1224077287
--								,1224077748
--								)

GROUP BY	bmo.market_id
			,bmo.runner_id






--SELECT		*
--FROM		#odds_in_range

-----------------------------------------------------------------------------------------------------
-- Create ladder
-----------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #match_odds_ladder;

SELECT		bmo.market_id
			,bmo.runner_id
			,evt.league_name
			,bmo.matched_bets_order
			,bmo.odds_timestamp
			,DATEDIFF(MINUTE, bmr.market_inplay_timestamp, bmo.odds_timestamp) - 15 AS minutes_in_play
			,bmo.odds_price_traded

INTO		#match_odds_ladder
FROM		dbo.bet_market_odds		bmo
			INNER JOIN
			#odds_in_range			oir
			ON bmo.market_id = oir.market_id
			AND bmo.runner_id = oir.runner_id
			AND oir.timestamp_during >= 1

			INNER JOIN
			dbo.bet_markets			bmr
			ON bmr.market_id = bmo.market_id
			INNER JOIN
			dbo.event_details		evt
			ON bmr.event_id = evt.event_id
WHERE		bmo.market_status = 'OPEN'
AND			bmo.market_in_play = 'True'
AND			DATEDIFF(MINUTE, bmr.market_inplay_timestamp, bmo.odds_timestamp) >= @after_x_mins

-----------------------------------------------------------------------------------------------------
-- Pick timestamp line
-----------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #timestamp_odds;

SELECT		mol.market_id
			,mol.runner_id
			,MIN(mol.matched_bets_order) AS matched_bets_order
INTO		#timestamp_odds
FROM		#match_odds_ladder		mol

GROUP BY	mol.market_id
			,mol.runner_id




--SELECT		*
--FROM		#match_odds_ladder


--SELECT		*
--FROM		#timestamp_odds

--SELECT		bmo.market_id
--			,bmo.runner_id
--			,bmr.market_result
--			,bmo.odds_price_traded
--			,CASE
--				WHEN bmr.market_result = 'WINNER'
--				THEN ((@bet_amount * bmo.odds_price_traded) - @bet_amount) * @commission
--				ELSE -1 * @bet_amount
--			END AS profit_loss
--FROM		dbo.bet_market_odds			bmo
--			INNER JOIN
--			#timestamp_odds				odd
--			ON bmo.market_id = odd.market_id
--			AND bmo.runner_id = odd.runner_id
--			AND bmo.matched_bets_order = odd.matched_bets_order
--			INNER JOIN
--			dbo.bet_market_results			bmr
--			ON bmo.market_id = bmr.market_id
--			AND bmo.runner_id = bmr.runner_id

-----------------------------------------------------------------------------------------------------
-- Calculate profit
-----------------------------------------------------------------------------------------------------

;WITH DRAWPROFITATEND AS
(
SELECT		bmo.market_id
			,bmo.runner_id
			,bmr.market_result
			,bmo.odds_price_traded
			,CASE
				WHEN bmr.market_result = 'WINNER'
				THEN ((@bet_amount * bmo.odds_price_traded) - @bet_amount) * @commission
				ELSE -1 * @bet_amount
			END AS profit_loss
FROM		dbo.bet_market_odds			bmo
			INNER JOIN
			#timestamp_odds				odd
			ON bmo.market_id = odd.market_id
			AND bmo.runner_id = odd.runner_id
			AND bmo.matched_bets_order = odd.matched_bets_order
			INNER JOIN
			dbo.bet_market_results			bmr
			ON bmo.market_id = bmr.market_id
			AND bmo.runner_id = bmr.runner_id


--WHERE		bmo.odds_price_traded BETWEEN 1.5 AND 2.0 -- Under 4.5
--WHERE		bmo.odds_price_traded BETWEEN 1.8 AND 2.2 -- Under 3.5
--WHERE		bmo.odds_price_traded BETWEEN 1.45 AND 1.8 -- Under 2.5

)
SELECT		OBJECT_NAME(@@PROCID)				AS test_proc_name
			,@bet_selection						AS bet_selection
			,@after_x_mins - 15					AS after_x_mins
			,SUM(profit_loss)					AS profit_loss
			,COUNT(*)							AS match_count
			,SUM(CASE WHEN market_result = 'WINNER' THEN 1 ELSE 0 END) AS win_count
			,SUM(CASE WHEN market_result = 'LOSER' THEN 1 ELSE 0 END) AS lose_count
FROM		DRAWPROFITATEND


--SELECT		odds_price_traded
--			,OBJECT_NAME(@@PROCID)				AS test_proc_name
--			,@bet_selection						AS bet_selection
--			,@after_x_mins - 15					AS after_x_mins
--			,SUM(profit_loss)					AS profit_loss
--			,COUNT(*)							AS match_count
--			,SUM(CASE WHEN market_result = 'WINNER' THEN 1 ELSE 0 END) AS win_count
--			,SUM(CASE WHEN market_result = 'LOSER' THEN 1 ELSE 0 END) AS lose_count
--FROM		DRAWPROFITATEND
--GROUP BY	odds_price_traded
--ORDER BY	odds_price_traded


-------------------------------------------------------------------------------------------------
-- End processing
-------------------------------------------------------------------------------------------------

END