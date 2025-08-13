CREATE PROCEDURE [dbo].[sp_build_bet_market_results]
AS
BEGIN

SET NOCOUNT ON

-------------------------------------------------------------------------------------------------
-- Drop primary key
-------------------------------------------------------------------------------------------------

ALTER TABLE dbo.bet_market_results DROP CONSTRAINT IF EXISTS pk_bet_market_results_market_id_runner_id;

-------------------------------------------------------------------------------------------------
-- Processing
-------------------------------------------------------------------------------------------------

--DROP TABLE IF EXISTS dbo.bet_market_results
--CREATE TABLE dbo.bet_market_results	(market_id		INT NULL
--									,runner_id		INT NULL
--									,runner_name	VARCHAR(50) COLLATE Latin1_General_100_BIN2_UTF8 NULL
--									,market_type	VARCHAR(15) COLLATE Latin1_General_100_BIN2_UTF8 NULL
--									,market_result	VARCHAR(10) COLLATE Latin1_General_100_BIN2_UTF8 NULL
--									)

DROP TABLE IF EXISTS #stg_bet_market_results

SELECT		DISTINCT
			CAST(CAST(marketId AS FLOAT) * 1000000000.0	AS INT)	AS market_id
			,CAST(runnerId AS INT)								AS runner_id
			,runnerName											AS runner_name
			,CAST(marketType AS VARCHAR(15))					AS market_type
			,CAST(runnerStatus AS VARCHAR(10))					AS market_result
INTO		#stg_bet_market_results
FROM		stg.betfair_market_odds
WHERE		marketStatus = 'CLOSED'
AND			runnerStatus IN ('WINNER', 'LOSER')


INSERT INTO dbo.bet_market_results (market_id
									,runner_id
									,runner_name
									,market_type
									,market_result)
SELECT		stg.market_id
			,stg.runner_id
			,stg.runner_name
			,stg.market_type
			,stg.market_result
FROM		#stg_bet_market_results stg
			LEFT OUTER JOIN
			dbo.bet_market_results	bmr
			ON stg.market_id = bmr.market_id
			AND stg.runner_id = bmr.runner_id
WHERE		bmr.market_id IS NULL

-------------------------------------------------------------------------------------------------
-- Delete duplicates
-------------------------------------------------------------------------------------------------

DELETE FROM dbo.bet_market_results WHERE market_id IN (SELECT		market_id
														FROM		dbo.bet_market_results
														GROUP BY	market_id
																	,runner_id
														HAVING		COUNT(*) > 1
														)



-------------------------------------------------------------------------------------------------
-- End processing
-------------------------------------------------------------------------------------------------

END