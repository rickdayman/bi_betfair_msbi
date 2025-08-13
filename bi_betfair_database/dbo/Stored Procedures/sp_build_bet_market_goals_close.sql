CREATE PROCEDURE [dbo].[sp_build_bet_market_goals_close]
AS
BEGIN

SET NOCOUNT ON

-------------------------------------------------------------------------------------------------
-- Processing
-------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS dbo.bet_market_goals_close

SELECT		bmt.event_id
			,CAST(CAST(marketId AS FLOAT) * 1000000000.0	AS INT)		AS market_id
			,MIN(CAST(publishTime AS DATETIME2(0)))						AS odds_timestamp
			,CAST(marketStatus AS VARCHAR(10))						AS market_status
			,CAST(inPlay AS VARCHAR(5))								AS market_in_play
			,CAST(runnerId AS INT)									AS runner_id
			,runnerName												AS runner_name
			,CASE
				WHEN marketType = 'MATCH_ODDS'
				AND sortPriority = '1'
				THEN 'Home'
				WHEN marketType = 'MATCH_ODDS'
				AND sortPriority = '2'
				THEN 'Away'
				ELSE runnerName
			END AS runner_name_display
			,CASE
				WHEN runnerName = LEFT(eventName, LEN(runnerName))
				THEN 1
				WHEN runnerName = 'The Draw'
				THEN 2
				WHEN runnerName = RIGHT(eventName, LEN(runnerName))
				THEN 3
				WHEN runnerName = 'Over 0.5 Goals'
				THEN 4
				WHEN runnerName = 'Under 0.5 Goals'
				THEN 5
				WHEN runnerName = 'Over 1.5 Goals'
				THEN 6
				WHEN runnerName = 'Under 1.5 Goals'
				THEN 7
				WHEN runnerName = 'Over 2.5 Goals'
				THEN 8
				WHEN runnerName = 'Under 2.5 Goals'
				THEN 9
				WHEN runnerName = 'Over 3.5 Goals'
				THEN 10
				WHEN runnerName = 'Under 3.5 Goals'
				THEN 11
				WHEN runnerName = 'Over 4.5 Goals'
				THEN 12
				WHEN runnerName = 'Under 4.5 Goals'
				THEN 13
				ELSE 0
			END 				AS bet_selection_id
			,bmo.runnerStatus	AS runner_status
INTO		dbo.bet_market_goals_close
FROM		stg.betfair_market_odds		bmo
			INNER JOIN
			dbo.bet_markets				bmt
			ON bmt.market_id = CAST(CAST(marketId AS FLOAT) * 1000000000.0	AS INT)
WHERE		marketStatus = 'CLOSED'
AND			runnerStatus <> 'REMOVED'
AND			runnerId IN (47972
						,1222344
						,1222347
						,1221385
						,5851482
						) -- Only Under markets
GROUP BY	bmt.event_id
			,CAST(CAST(marketId AS FLOAT) * 1000000000.0	AS INT)
			,CAST(marketStatus AS VARCHAR(10))
			,CAST(inPlay AS VARCHAR(5))
			,CAST(runnerId AS INT)
			,runnerName
			,CASE
				WHEN marketType = 'MATCH_ODDS'
				AND sortPriority = '1'
				THEN 'Home'
				WHEN marketType = 'MATCH_ODDS'
				AND sortPriority = '2'
				THEN 'Away'
				ELSE runnerName
			END
			,CASE
				WHEN runnerName = LEFT(eventName, LEN(runnerName))
				THEN 1
				WHEN runnerName = 'The Draw'
				THEN 2
				WHEN runnerName = RIGHT(eventName, LEN(runnerName))
				THEN 3
				WHEN runnerName = 'Over 0.5 Goals'
				THEN 4
				WHEN runnerName = 'Under 0.5 Goals'
				THEN 5
				WHEN runnerName = 'Over 1.5 Goals'
				THEN 6
				WHEN runnerName = 'Under 1.5 Goals'
				THEN 7
				WHEN runnerName = 'Over 2.5 Goals'
				THEN 8
				WHEN runnerName = 'Under 2.5 Goals'
				THEN 9
				WHEN runnerName = 'Over 3.5 Goals'
				THEN 10
				WHEN runnerName = 'Under 3.5 Goals'
				THEN 11
				WHEN runnerName = 'Over 4.5 Goals'
				THEN 12
				WHEN runnerName = 'Under 4.5 Goals'
				THEN 13
				ELSE 0
			END
			,bmo.runnerStatus

-------------------------------------------------------------------------------------------------
-- End processing
-------------------------------------------------------------------------------------------------

END