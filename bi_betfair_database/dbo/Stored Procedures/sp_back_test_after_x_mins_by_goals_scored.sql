CREATE PROCEDURE [dbo].[sp_back_test_after_x_mins_by_goals_scored] (@bet_selection		VARCHAR(20) = 'Under 4.5 Goals'
																	,@after_x_mins		INT = 65
																	,@goal_gap			SMALLINT = 2
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

IF @after_x_mins >= 46
BEGIN
SET @after_x_mins = @after_x_mins + 15
END

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
			,egt.game_start
			,DATEDIFF(MINUTE, egt.game_start, egt.goal1)	AS goal1
			,DATEDIFF(MINUTE, egt.game_start, egt.goal2)	AS goal2
			,DATEDIFF(MINUTE, egt.game_start, egt.goal3)	AS goal3
			,DATEDIFF(MINUTE, egt.game_start, egt.goal4)	AS goal4
			,DATEDIFF(MINUTE, egt.game_start, egt.goal5)	AS goal5
			,bmr.event_id
			,@after_x_mins	AS after_x_mins
			,CASE
				WHEN egt.goal1 IS NULL
				OR DATEDIFF(MINUTE, egt.game_start, egt.goal1) > @after_x_mins
				THEN 0
				WHEN DATEDIFF(MINUTE, egt.game_start, egt.goal1) <= @after_x_mins
				AND (
					egt.goal2 IS NULL
					OR
					DATEDIFF(MINUTE, egt.game_start, egt.goal2) > @after_x_mins
					)
				THEN 1
				WHEN DATEDIFF(MINUTE, egt.game_start, egt.goal2) <= @after_x_mins
				AND (
					egt.goal3 IS NULL
					OR
					DATEDIFF(MINUTE, egt.game_start, egt.goal3) > @after_x_mins
					)
				THEN 2
				WHEN DATEDIFF(MINUTE, egt.game_start, egt.goal3) <= @after_x_mins
				AND (
					egt.goal4 IS NULL
					OR
					DATEDIFF(MINUTE, egt.game_start, egt.goal4) > @after_x_mins
					)
				THEN 3
				WHEN DATEDIFF(MINUTE, egt.game_start, egt.goal4) <= @after_x_mins
				AND (
					egt.goal5 IS NULL
					OR
					DATEDIFF(MINUTE, egt.game_start, egt.goal5) > @after_x_mins
					)
				THEN 4
				WHEN DATEDIFF(MINUTE, egt.game_start, egt.goal5) <= @after_x_mins
				THEN 5
			END AS goals_at_x_mins
			,SUM(CASE
					WHEN DATEDIFF(MINUTE, egt.game_start, bmo.odds_timestamp) >= @after_x_mins
					AND	 DATEDIFF(MINUTE, egt.game_start, bmo.odds_timestamp) < @after_x_mins + 2
					THEN 1
					ELSE 0
				 END) AS timestamp_during
			,SUM(CASE
					WHEN DATEDIFF(MINUTE, egt.game_start, bmo.odds_timestamp) >= @after_x_mins + 2
					THEN 1
					ELSE 0
				 END) AS timestamp_after
INTO		#odds_in_range
FROM		dbo.bet_market_odds		bmo
			INNER JOIN
			dbo.bet_markets			bmr
			ON bmr.market_id = bmo.market_id
			INNER JOIN
			dbo.event_goal_times	egt
			ON bmr.event_id = egt.event_id
			INNER JOIN
			dbo.event_details		evt
			ON bmr.event_id = evt.event_id
			--AND evt.league_name IN ('English Premier League'
			--						,'Spanish La Liga'
			--						,'Italian Serie A'
			--						,'German Bundesliga'
			--						,'French Ligue 1'
			--						)

WHERE		1 = 1
AND			bmo.bet_selection_id = @bet_selection_id
AND			bmo.market_status = 'OPEN'
AND			bmo.market_in_play = 'True'
--AND			bmr.market_time <= '2024-12-01' -- Testing
--AND			bmr.market_time > '2024-12-01' -- Testing

--AND			bmr.event_id >= 15551
--AND			bmr.event_id <= 15551

GROUP BY	bmo.market_id
			,bmo.runner_id
			,egt.game_start
			,DATEDIFF(MINUTE, egt.game_start, egt.goal1)
			,DATEDIFF(MINUTE, egt.game_start, egt.goal2)
			,DATEDIFF(MINUTE, egt.game_start, egt.goal3)
			,DATEDIFF(MINUTE, egt.game_start, egt.goal4)
			,DATEDIFF(MINUTE, egt.game_start, egt.goal5)
			,bmr.event_id
			,CASE
				WHEN egt.goal1 IS NULL
				OR DATEDIFF(MINUTE, egt.game_start, egt.goal1) > @after_x_mins
				THEN 0
				WHEN DATEDIFF(MINUTE, egt.game_start, egt.goal1) <= @after_x_mins
				AND (
					egt.goal2 IS NULL
					OR
					DATEDIFF(MINUTE, egt.game_start, egt.goal2) > @after_x_mins
					)
				THEN 1
				WHEN DATEDIFF(MINUTE, egt.game_start, egt.goal2) <= @after_x_mins
				AND (
					egt.goal3 IS NULL
					OR
					DATEDIFF(MINUTE, egt.game_start, egt.goal3) > @after_x_mins
					)
				THEN 2
				WHEN DATEDIFF(MINUTE, egt.game_start, egt.goal3) <= @after_x_mins
				AND (
					egt.goal4 IS NULL
					OR
					DATEDIFF(MINUTE, egt.game_start, egt.goal4) > @after_x_mins
					)
				THEN 3
				WHEN DATEDIFF(MINUTE, egt.game_start, egt.goal4) <= @after_x_mins
				AND (
					egt.goal5 IS NULL
					OR
					DATEDIFF(MINUTE, egt.game_start, egt.goal5) > @after_x_mins
					)
				THEN 4
				WHEN DATEDIFF(MINUTE, egt.game_start, egt.goal5) <= @after_x_mins
				THEN 5
			END

--SELECT * FROM #odds_in_range
-----------------------------------------------------------------------------------------------------
-- Delete cases where goals is within bracket of after x mins
-----------------------------------------------------------------------------------------------------

DELETE FROM #odds_in_range WHERE goals_at_x_mins >= CASE
														WHEN @bet_selection_id = 13		THEN 5
														WHEN @bet_selection_id = 11		THEN 4
														WHEN @bet_selection_id = 9		THEN 3
														WHEN @bet_selection_id = 7		THEN 2
														WHEN @bet_selection_id = 5		THEN 1
													END

-----------------------------------------------------------------------------------------------------
-- Create ladder
-----------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #match_odds_ladder;

SELECT		bmo.market_id
			,bmo.runner_id
			,evt.league_name
			,bmo.matched_bets_order
			,bmo.odds_timestamp
			,DATEDIFF(MINUTE, oir.game_start, bmo.odds_timestamp) - 15 AS minutes_in_play
			,bmo.odds_price_traded
			,oir.goals_at_x_mins
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
AND			DATEDIFF(MINUTE, oir.game_start, bmo.odds_timestamp) >= @after_x_mins

-----------------------------------------------------------------------------------------------------
-- Pick timestamp line
-----------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #timestamp_odds;

SELECT		mol.market_id
			,mol.runner_id
			,mol.goals_at_x_mins
			,MIN(mol.matched_bets_order) AS matched_bets_order
INTO		#timestamp_odds
FROM		#match_odds_ladder		mol

GROUP BY	mol.market_id
			,mol.runner_id
			,mol.goals_at_x_mins

-----------------------------------------------------------------------------------------------------
-- Calculate profit
-----------------------------------------------------------------------------------------------------

IF @after_x_mins >= 46
BEGIN
SET @after_x_mins = @after_x_mins - 15
END

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
			,odd.goals_at_x_mins
			,evt.event_name
			,evt.market_time
			,evt.event_id
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

			INNER JOIN
			dbo.bet_markets			bmt
			ON bmt.market_id = bmo.market_id
			INNER JOIN
			dbo.event_details		evt
			ON bmt.event_id = evt.event_id
)
SELECT		OBJECT_NAME(@@PROCID)					AS test_proc_name
			,@bet_selection							AS bet_selection
			,@after_x_mins							AS after_x_mins
			,goals_at_x_mins
			,SUM(profit_loss)						AS profit_loss
			,COUNT(*)								AS match_count
			,SUM(CASE WHEN market_result = 'WINNER' THEN 1 ELSE 0 END) AS win_count
			,SUM(CASE WHEN market_result = 'LOSER' THEN 1 ELSE 0 END) AS lose_count

			,SUM(profit_loss) / (COUNT(*) * 1.0)	AS profit_per_game

FROM		DRAWPROFITATEND
GROUP BY	goals_at_x_mins


--SELECT		OBJECT_NAME(@@PROCID)					AS test_proc_name
--			,@bet_selection							AS bet_selection
--			,@after_x_mins							AS after_x_mins
--			,goals_at_x_mins
--			,profit_loss
--			,market_result
--			,event_name
--			,market_time
--			,event_id

--FROM		DRAWPROFITATEND
--WHERE		goals_at_x_mins = 2
--ORDER BY	event_name


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