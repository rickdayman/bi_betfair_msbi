CREATE PROCEDURE [dbo].[sp_build_event_goal_times]
AS
BEGIN

SET NOCOUNT ON

-------------------------------------------------------------------------------------------------
-- Create event_goal_times table
-------------------------------------------------------------------------------------------------

-- SELECT COUNT(*) FROM dbo.event_goal_times

DROP TABLE IF EXISTS dbo.event_goal_times
CREATE TABLE dbo.event_goal_times(event_id			INT NULL
									,event_name		VARCHAR(50) COLLATE Latin1_General_100_BIN2_UTF8 NULL
									,league_name	VARCHAR(50) COLLATE Latin1_General_100_BIN2_UTF8 NULL
									,market_time	DATETIME2(0) NULL
									,odd_snapshots	INT NULL
									,game_start		DATETIME NULL
									,game_end		DATETIME NULL
									,goal1			DATETIME2(3) NULL
									,goal2			DATETIME2(3) NULL
									,goal3			DATETIME2(3) NULL
									,goal4			DATETIME2(3) NULL
									,goal5			DATETIME2(3) NULL
									,event_goals	INT NULL
									)

----------------------------------------------------------------------------------------------------
-- calculate goal times
----------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #event_goals

SELECT		bmt.event_id
			,evt.event_name
			,evt.league_name
			,evt.market_time
			,COUNT(DISTINCT CASE WHEN bmr.runner_name LIKE '%Goals' THEN bmo.bet_market_odds_id ELSE NULL END)	AS odd_snapshots
			,COUNT(DISTINCT CASE WHEN bmr.runner_name = 'Under 0.5 Goals' THEN bmo.bet_market_odds_id ELSE NULL END)	AS odd_snapshots_05
			,COUNT(DISTINCT CASE WHEN bmr.runner_name = 'Under 1.5 Goals' THEN bmo.bet_market_odds_id ELSE NULL END)	AS odd_snapshots_15
			,COUNT(DISTINCT CASE WHEN bmr.runner_name = 'Under 2.5 Goals' THEN bmo.bet_market_odds_id ELSE NULL END)	AS odd_snapshots_25
			,COUNT(DISTINCT CASE WHEN bmr.runner_name = 'Under 3.5 Goals' THEN bmo.bet_market_odds_id ELSE NULL END)	AS odd_snapshots_35
			,COUNT(DISTINCT CASE WHEN bmr.runner_name = 'Under 4.5 Goals' THEN bmo.bet_market_odds_id ELSE NULL END)	AS odd_snapshots_45
			,MIN(bmo.odds_timestamp)	AS game_start
			,MAX(bmo.odds_timestamp)	AS game_end
			,MAX(CASE WHEN bmr.runner_name = 'Under 0.5 Goals' AND bmr.market_result = 'LOSER' THEN DATEADD(SECOND, 30, bmo.odds_timestamp) END) AS goal1_u
			,MAX(CASE WHEN bmr.runner_name = 'Under 1.5 Goals' AND bmr.market_result = 'LOSER' THEN DATEADD(SECOND, 30, bmo.odds_timestamp) END) AS goal2_u
			,MAX(CASE WHEN bmr.runner_name = 'Under 2.5 Goals' AND bmr.market_result = 'LOSER' THEN DATEADD(SECOND, 30, bmo.odds_timestamp) END) AS goal3_u
			,MAX(CASE WHEN bmr.runner_name = 'Under 3.5 Goals' AND bmr.market_result = 'LOSER' THEN DATEADD(SECOND, 30, bmo.odds_timestamp) END) AS goal4_u
			,MAX(CASE WHEN bmr.runner_name = 'Under 4.5 Goals' AND bmr.market_result = 'LOSER' THEN DATEADD(SECOND, 30, bmo.odds_timestamp) END) AS goal5_u
			,MAX(CASE WHEN bmr.runner_name = 'Over 0.5 Goals' AND bmr.market_result = 'WINNER' THEN DATEADD(SECOND, 30, bmo.odds_timestamp) END) AS goal1_o
			,MAX(CASE WHEN bmr.runner_name = 'Over 1.5 Goals' AND bmr.market_result = 'WINNER' THEN DATEADD(SECOND, 30, bmo.odds_timestamp) END) AS goal2_o
			,MAX(CASE WHEN bmr.runner_name = 'Over 2.5 Goals' AND bmr.market_result = 'WINNER' THEN DATEADD(SECOND, 30, bmo.odds_timestamp) END) AS goal3_o
			,MAX(CASE WHEN bmr.runner_name = 'Over 3.5 Goals' AND bmr.market_result = 'WINNER' THEN DATEADD(SECOND, 30, bmo.odds_timestamp) END) AS goal4_o
			,MAX(CASE WHEN bmr.runner_name = 'Over 4.5 Goals' AND bmr.market_result = 'WINNER' THEN DATEADD(SECOND, 30, bmo.odds_timestamp) END) AS goal5_o
INTO		#event_goals
FROM		dbo.bet_market_odds		bmo
			INNER JOIN
			dbo.bet_markets			bmt
			ON bmt.market_id = bmo.market_id
			INNER JOIN
			dbo.bet_market_results	bmr
			ON bmr.market_id = bmo.market_id
			AND bmr.runner_id = bmo.runner_id
			INNER JOIN
			dbo.event_details		evt
			ON evt.event_id = bmt.event_id
WHERE		1 = 1
AND			bmo.market_in_play = 'True'
AND			bmo.market_status IN ('SUSPENDED', 'OPEN')
-- Exclude game with inconsistent market close data
AND			bmt.event_id IN (SELECT		event_id
							 FROM		dbo.bet_market_goals_close
							 GROUP BY	event_id
							 HAVING		COUNT(*) = 5
							 )

--AND			evt.league_name IN ('Italian Serie A'
--								,'Spanish La Liga'
--								,'French Ligue 1'
--								,'English Premier League'
--								,'German Bundesliga'
--								)

--AND			evt.league_name IN ('English Premier League')

--AND			evt.event_id = 2355

GROUP BY	bmt.event_id
			,evt.event_name
			,evt.league_name
			,evt.market_time


-- SELECT	380 * 5 * 2
----------------------------------------------------------------------------------------------------
-- calculate odds coverage
----------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #event_odds_coverage

SELECT		evg.event_id
			,evg.event_name
			,evg.league_name
			,evg.market_time
			,evg.odd_snapshots
			,evg.odd_snapshots_05
			,evg.odd_snapshots_15
			,evg.odd_snapshots_25
			,evg.odd_snapshots_35
			,evg.odd_snapshots_45
			,DATEDIFF(MINUTE, evg.game_start, ISNULL(GREATEST(evg.goal1_u, evg.goal1_o), lbs.goal1_close)) * 1.0	AS goal1_mins
			,DATEDIFF(MINUTE, evg.game_start, ISNULL(GREATEST(evg.goal2_u, evg.goal2_o), lbs.goal2_close)) * 1.0	AS goal2_mins
			,DATEDIFF(MINUTE, evg.game_start, ISNULL(GREATEST(evg.goal3_u, evg.goal3_o), lbs.goal3_close)) * 1.0	AS goal3_mins
			,DATEDIFF(MINUTE, evg.game_start, ISNULL(GREATEST(evg.goal4_u, evg.goal4_o), lbs.goal4_close)) * 1.0	AS goal4_mins
			,DATEDIFF(MINUTE, evg.game_start, ISNULL(GREATEST(evg.goal5_u, evg.goal5_o), lbs.goal5_close)) * 1.0	AS goal5_mins
			,evg.game_start
			,evg.game_end
			,ISNULL(GREATEST(evg.goal1_u, evg.goal1_o), lbs.goal1_close) AS goal1
			,ISNULL(GREATEST(evg.goal2_u, evg.goal2_o), lbs.goal2_close) AS goal2
			,ISNULL(GREATEST(evg.goal3_u, evg.goal3_o), lbs.goal3_close) AS goal3
			,ISNULL(GREATEST(evg.goal4_u, evg.goal4_o), lbs.goal4_close) AS goal4
			,ISNULL(GREATEST(evg.goal5_u, evg.goal5_o), lbs.goal5_close) AS goal5
			,CASE
				WHEN last_bet_selection_id IS NULL THEN 0
				WHEN last_bet_selection_id = 5 THEN 1
				WHEN last_bet_selection_id = 7 THEN 2
				WHEN last_bet_selection_id = 9 THEN 3
				WHEN last_bet_selection_id = 11 THEN 4
				WHEN last_bet_selection_id >= 13 THEN 5
			END AS event_goals
INTO		#event_odds_coverage
FROM		#event_goals			evg
			LEFT OUTER JOIN
			(SELECT		event_id
						,MAX(CASE WHEN runner_status = 'LOSER' THEN bet_selection_id ELSE NULL END)	AS last_bet_selection_id
						-- Minus a minute from close timestamp as it takes around that to close after the goal
						,MAX(CASE WHEN runner_status = 'LOSER' AND runner_name = 'Under 0.5 Goals' THEN DATEADD(MINUTE, -1, odds_timestamp) ELSE NULL END)	AS goal1_close
						,MAX(CASE WHEN runner_status = 'LOSER' AND runner_name = 'Under 1.5 Goals' THEN DATEADD(MINUTE, -1, odds_timestamp) ELSE NULL END)	AS goal2_close
						,MAX(CASE WHEN runner_status = 'LOSER' AND runner_name = 'Under 2.5 Goals' THEN DATEADD(MINUTE, -1, odds_timestamp) ELSE NULL END)	AS goal3_close
						,MAX(CASE WHEN runner_status = 'LOSER' AND runner_name = 'Under 3.5 Goals' THEN DATEADD(MINUTE, -1, odds_timestamp) ELSE NULL END)	AS goal4_close
						,MAX(CASE WHEN runner_status = 'LOSER' AND runner_name = 'Under 4.5 Goals' THEN DATEADD(MINUTE, -1, odds_timestamp) ELSE NULL END)	AS goal5_close
			FROM		dbo.bet_market_goals_close
			GROUP BY	event_id
			) lbs
			ON evg.event_id = lbs.event_id

----------------------------------------------------------------------------------------------------
-- populate table
----------------------------------------------------------------------------------------------------

DECLARE @coverage_lowest	DECIMAL(4, 2) = 0.33
DECLARE @coverage_low		DECIMAL(4, 2) = 0.6
DECLARE @coverage_high		DECIMAL(4, 2) = 0.7

INSERT INTO dbo.event_goal_times(event_id
								,event_name
								,league_name
								,market_time
								,odd_snapshots
								,game_start
								,game_end
								,goal1
								,goal2
								,goal3
								,goal4
								,goal5
								,event_goals
								)
SELECT		event_id
			,event_name
			,league_name
			,market_time
			,odd_snapshots
			,game_start
			,game_end
			,goal1
			,goal2
			,goal3
			,goal4
			,goal5
			,event_goals

			--,odd_snapshots_05
			--,odd_snapshots_15
			--,odd_snapshots_25
			--,odd_snapshots_35
			--,odd_snapshots_45
			--,goal1_mins
			--,goal2_mins
			--,goal3_mins
			--,goal4_mins
			--,goal5_mins
			--,CASE
			--	WHEN goal1_mins IS NULL									THEN 1
			--	WHEN goal1_mins IN (1.0, 2.0) AND odd_snapshots_05 >= 0 THEN 1
			--	WHEN goal1_mins IN (3.0, 4.0) AND odd_snapshots_05 >= 1 THEN 1
			--	WHEN goal1_mins IN (5.0, 6.0) AND odd_snapshots_05 >= 3 THEN 1
			--	WHEN goal1_mins IN (7.0, 8.0) AND odd_snapshots_05 >= 4 THEN 1
			--	WHEN goal1_mins <= 20
			--	AND odd_snapshots_05 >= goal1_mins * @coverage_lowest	THEN 1
			--	WHEN goal1_mins <= 40
			--	AND odd_snapshots_05 >= goal1_mins * @coverage_low		THEN 1
			--	WHEN goal1_mins > 40
			--	AND odd_snapshots_05 >= goal1_mins * @coverage_high		THEN 1
			--	ELSE 0
			--END
			--,CASE
			--	WHEN goal2_mins IS NULL										THEN 1
			--	WHEN goal2_mins IN (1.0, 2.0) AND odd_snapshots_15 >= 0		THEN 1
			--	WHEN goal2_mins IN (3.0, 4.0) AND odd_snapshots_15 >= 1		THEN 1
			--	WHEN goal2_mins IN (5.0, 6.0) AND odd_snapshots_15 >= 3		THEN 1
			--	WHEN goal2_mins IN (7.0, 8.0) AND odd_snapshots_15 >= 4		THEN 1
			--	WHEN goal2_mins IN (9.0, 10.0) AND odd_snapshots_15 >= 6	THEN 1
			--	WHEN goal2_mins <= 20
			--	AND odd_snapshots_15 >= goal2_mins * @coverage_lowest		THEN 1
			--	WHEN goal2_mins <= 40
			--	AND odd_snapshots_15 >= goal2_mins * @coverage_low			THEN 1
			--	WHEN goal2_mins > 40
			--	AND odd_snapshots_15 >= goal2_mins * @coverage_high			THEN 1
			--	ELSE 0
			--END 
			--,CASE
			--	WHEN goal3_mins IS NULL										THEN 1
			--	WHEN goal3_mins IN (1.0, 2.0) AND odd_snapshots_25 >= 0		THEN 1
			--	WHEN goal3_mins IN (3.0, 4.0) AND odd_snapshots_25 >= 1		THEN 1
			--	WHEN goal3_mins IN (5.0, 6.0) AND odd_snapshots_25 >= 3		THEN 1
			--	WHEN goal3_mins IN (7.0, 8.0) AND odd_snapshots_25 >= 4		THEN 1
			--	WHEN goal3_mins IN (9.0, 10.0) AND odd_snapshots_25 >= 6	THEN 1
			--	WHEN goal3_mins <= 20
			--	AND odd_snapshots_25 >= goal3_mins * @coverage_lowest		THEN 1
			--	WHEN goal3_mins <= 40
			--	AND odd_snapshots_25 >= goal3_mins * @coverage_low			THEN 1
			--	WHEN goal3_mins > 40
			--	AND odd_snapshots_25 >= goal3_mins * @coverage_high			THEN 1
			--	ELSE 0
			--END
			--,CASE
			--	WHEN goal4_mins IS NULL										THEN 1
			--	WHEN goal4_mins <= 40
			--	AND odd_snapshots_35 >= goal4_mins * @coverage_low			THEN 1
			--	WHEN goal4_mins > 40
			--	AND odd_snapshots_35 >= goal4_mins * @coverage_high			THEN 1
			--	ELSE 0
			--END
			--,CASE
			--	WHEN goal5_mins IS NULL										THEN 1
			--	WHEN goal5_mins <= 40
			--	AND odd_snapshots_45 >= goal5_mins * @coverage_low			THEN 1
			--	WHEN goal5_mins > 40
			--	AND odd_snapshots_45 >= goal5_mins * @coverage_high			THEN 1
			--	ELSE 0
			--END

FROM		#event_odds_coverage
WHERE		1 = 1
AND			CASE
				WHEN goal1_mins IS NULL									THEN 1
				WHEN goal1_mins IN (1.0, 2.0) AND odd_snapshots_05 >= 0 THEN 1
				WHEN goal1_mins IN (3.0, 4.0) AND odd_snapshots_05 >= 1 THEN 1
				WHEN goal1_mins IN (5.0, 6.0) AND odd_snapshots_05 >= 3 THEN 1
				WHEN goal1_mins IN (7.0, 8.0) AND odd_snapshots_05 >= 4 THEN 1
				WHEN goal1_mins <= 20
				AND odd_snapshots_05 >= goal1_mins * @coverage_lowest	THEN 1
				WHEN goal1_mins <= 40
				AND odd_snapshots_05 >= goal1_mins * @coverage_low		THEN 1
				WHEN goal1_mins > 40
				AND odd_snapshots_05 >= goal1_mins * @coverage_high		THEN 1
				ELSE 0
			END = 1
AND			CASE
				WHEN goal2_mins IS NULL										THEN 1
				WHEN goal2_mins IN (1.0, 2.0) AND odd_snapshots_15 >= 0		THEN 1
				WHEN goal2_mins IN (3.0, 4.0) AND odd_snapshots_15 >= 1		THEN 1
				WHEN goal2_mins IN (5.0, 6.0) AND odd_snapshots_15 >= 3		THEN 1
				WHEN goal2_mins IN (7.0, 8.0) AND odd_snapshots_15 >= 4		THEN 1
				WHEN goal2_mins IN (9.0, 10.0) AND odd_snapshots_15 >= 6	THEN 1
				WHEN goal2_mins <= 20
				AND odd_snapshots_15 >= goal2_mins * @coverage_lowest		THEN 1
				WHEN goal2_mins <= 40
				AND odd_snapshots_15 >= goal2_mins * @coverage_low			THEN 1
				WHEN goal2_mins > 40
				AND odd_snapshots_15 >= goal2_mins * @coverage_high			THEN 1
				ELSE 0
			END = 1 
AND			CASE
				WHEN goal3_mins IS NULL										THEN 1
				WHEN goal3_mins IN (1.0, 2.0) AND odd_snapshots_25 >= 0		THEN 1
				WHEN goal3_mins IN (3.0, 4.0) AND odd_snapshots_25 >= 1		THEN 1
				WHEN goal3_mins IN (5.0, 6.0) AND odd_snapshots_25 >= 3		THEN 1
				WHEN goal3_mins IN (7.0, 8.0) AND odd_snapshots_25 >= 4		THEN 1
				WHEN goal3_mins IN (9.0, 10.0) AND odd_snapshots_25 >= 6	THEN 1
				WHEN goal3_mins <= 20
				AND odd_snapshots_25 >= goal3_mins * @coverage_lowest		THEN 1
				WHEN goal3_mins <= 40
				AND odd_snapshots_25 >= goal3_mins * @coverage_low			THEN 1
				WHEN goal3_mins > 40
				AND odd_snapshots_25 >= goal3_mins * @coverage_high			THEN 1
				ELSE 0
			END = 1
AND			CASE
				WHEN goal4_mins IS NULL										THEN 1
				WHEN goal4_mins <= 40
				AND odd_snapshots_35 >= goal4_mins * @coverage_low			THEN 1
				WHEN goal4_mins > 40
				AND odd_snapshots_35 >= goal4_mins * @coverage_high			THEN 1
				ELSE 0
			END = 1
AND			CASE
				WHEN goal5_mins IS NULL										THEN 1
				WHEN goal5_mins <= 40
				AND odd_snapshots_45 >= goal5_mins * @coverage_low			THEN 1
				WHEN goal5_mins > 40
				AND odd_snapshots_45 >= goal5_mins * @coverage_high			THEN 1
				ELSE 0
			END = 1


/*

SELECT		*
FROM		dbo.event_goal_times
WHERE		event_id = 15551

SELECT		evt.event_id
			,evt.event_name
			,evt.market_time
			,egt.*
FROM		dbo.event_details		evt
			LEFT OUTER JOIN
			dbo.event_goal_times	egt
			ON evt.event_id = egt.event_id
WHERE		evt.league_name IN ('Italian Serie A'
								,'Spanish La Liga'
								,'French Ligue 1'
								,'English Premier League'
								,'German Bundesliga'
								)
AND			egt.event_id IS NULL

*/

-------------------------------------------------------------------------------------------------
-- End processing
-------------------------------------------------------------------------------------------------

END