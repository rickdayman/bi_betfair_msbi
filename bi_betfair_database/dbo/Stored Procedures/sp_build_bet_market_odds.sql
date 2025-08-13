CREATE PROCEDURE [dbo].[sp_build_bet_market_odds]
AS
BEGIN

SET NOCOUNT ON

-------------------------------------------------------------------------------------------------
-- Drop primary key
-------------------------------------------------------------------------------------------------

ALTER TABLE dbo.bet_market_odds DROP CONSTRAINT IF EXISTS pk_bet_market_odds_market_id_runner_id_odds_timestamp;

-------------------------------------------------------------------------------------------------
-- Get results for semantic model
-------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #stg_bet_market_results

SELECT		DISTINCT
			marketId											AS market_id
			,CAST(runnerId AS INT)								AS runner_id
			,runnerName											AS runner_name
			,CAST(marketType AS VARCHAR(15))					AS market_type
			,CAST(runnerStatus AS VARCHAR(10))					AS market_result
INTO		#stg_bet_market_results
FROM		stg.betfair_market_odds
WHERE		marketStatus = 'CLOSED'
AND			runnerStatus IN ('WINNER', 'LOSER')

-------------------------------------------------------------------------------------------------
-- Processing
-------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #bet_market_odds

SELECT		CAST(CAST(marketId AS FLOAT) * 1000000000.0	AS INT)		AS market_id
			,CAST(publishTime AS DATETIME2(0))						AS odds_timestamp
			,CASE
				WHEN CAST(publishTime AS DATETIME2(0)) <= DATEADD(HOUR, -1, CAST(marketTime AS DATETIME2(0)))
				THEN CAST(FORMAT(CAST(publishTime AS DATETIME2(0)), 'yyyy-MM-dd HH:00') AS DATETIME2(0))
				ELSE CAST(FORMAT(CAST(publishTime AS DATETIME2(0)), 'yyyy-MM-dd HH:mm') AS DATETIME2(0))
			END														AS odds_timestamp_display
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
				WHEN runnerName = LEFT(eventName, LEN(runnerName))	THEN 1
				WHEN runnerName = 'The Draw'						THEN 2
				WHEN runnerName = RIGHT(eventName, LEN(runnerName))	THEN 3
				WHEN runnerName = 'Over 0.5 Goals'					THEN 4
				WHEN runnerName = 'Under 0.5 Goals'					THEN 5
				WHEN runnerName = 'Over 1.5 Goals'					THEN 6
				WHEN runnerName = 'Under 1.5 Goals'					THEN 7
				WHEN runnerName = 'Over 2.5 Goals'					THEN 8
				WHEN runnerName = 'Under 2.5 Goals'					THEN 9
				WHEN runnerName = 'Over 3.5 Goals'					THEN 10
				WHEN runnerName = 'Under 3.5 Goals'					THEN 11
				WHEN runnerName = 'Over 4.5 Goals'					THEN 12
				WHEN runnerName = 'Under 4.5 Goals'					THEN 13
				ELSE 0
			END 													AS bet_selection_id
			,TRY_PARSE(lastPriceTraded AS DECIMAL(8, 2))			AS odds_price_traded -- TRY_PARSE since blank when market_status = SUSPENDED
			,CAST(0 AS INT) AS matched_bets_order
			,res.market_result
INTO		#bet_market_odds
FROM		stg.betfair_market_odds		bmo
			INNER JOIN
			#stg_bet_market_results		res
			ON bmo.marketId = res.market_id
			AND bmo.runnerId = res.runner_id
WHERE		marketStatus <> 'CLOSED'

-------------------------------------------------------------------------------------------------
-- Delete undetermined selections
-------------------------------------------------------------------------------------------------

DELETE FROM #bet_market_odds WHERE bet_selection_id = 0

-------------------------------------------------------------------------------------------------
-- INSERT new data and create lay odds and odds_timestamp_display_id
-------------------------------------------------------------------------------------------------

--DROP TABLE IF EXISTS dbo.bet_market_odds

--CREATE TABLE dbo.bet_market_odds (bet_market_odds_id			BIGINT NULL
--									,market_id					INT NOT NULL
--									,odds_timestamp				DATETIME2(0) NULL
--									,odds_timestamp_display_id	BIGINT NULL
--									,odds_timestamp_display		DATETIME2(0) NULL
--									,market_status				VARCHAR(10) COLLATE Latin1_General_100_BIN2_UTF8 NULL
--									,market_in_play				VARCHAR(5) COLLATE Latin1_General_100_BIN2_UTF8 NULL
--									,runner_id					INT NOT NULL
--									,runner_name				VARCHAR(50) COLLATE Latin1_General_100_BIN2_UTF8 NULL
--									,runner_name_display		VARCHAR(15) COLLATE Latin1_General_100_BIN2_UTF8 NULL
--									,bet_selection_id			INT NOT NULL
--									,odds_price_traded			NUMERIC(8, 2) NULL
--									,odds_price_traded_lay		NUMERIC(9, 2) NULL
--									,matched_bets_order			INT NULL
--									,market_result				VARCHAR(10)
--									,odds_source				CHAR(1)
--									)



INSERT INTO dbo.bet_market_odds (bet_market_odds_id
								,market_id
								,odds_timestamp
								,odds_timestamp_display_id
								,odds_timestamp_display
								,market_status
								,market_in_play
								,runner_id
								,runner_name
								,runner_name_display
								,bet_selection_id
								,odds_price_traded
								,odds_price_traded_lay
								,matched_bets_order
								,market_result
								,odds_source)
SELECT		0 AS bet_market_odds_id
			--,ROW_NUMBER() OVER (PARTITION BY NULL ORDER BY stg.market_id, stg.runner_id, stg.odds_timestamp) AS bet_market_odds_id	
			,ISNULL(stg.market_id, 0)				AS market_id -- ISNULL forces column as NOT NULL
			,ISNULL(stg.odds_timestamp, GETDATE())	AS odds_timestamp -- ISNULL forces column as NOT NULL
			,(CAST(YEAR(stg.odds_timestamp_display) AS BIGINT) * 100000000) +
				(MONTH(stg.odds_timestamp_display) * 1000000) +
				(DAY(stg.odds_timestamp_display) * 10000) +
				(DATEPART(HOUR, stg.odds_timestamp_display) * 100) +
				 DATEPART(MINUTE, stg.odds_timestamp_display) AS odds_timestamp_display_id
			,stg.odds_timestamp_display
			,stg.market_status
			,stg.market_in_play
			,ISNULL(stg.runner_id, 0)  AS runner_id -- ISNULL forces column as NOT NULL
			,stg.runner_name
			,stg.runner_name_display
			,stg.bet_selection_id
			,stg.odds_price_traded
			,CASE
				WHEN stg.odds_price_traded BETWEEN 1.01 AND 1.99 THEN stg.odds_price_traded + 0.01
				WHEN stg.odds_price_traded BETWEEN 2.00 AND 2.98 THEN stg.odds_price_traded + 0.02
				WHEN stg.odds_price_traded BETWEEN 3.00 AND 3.95 THEN stg.odds_price_traded + 0.05
				WHEN stg.odds_price_traded BETWEEN 4.00 AND 5.90 THEN stg.odds_price_traded + 0.10
				WHEN stg.odds_price_traded BETWEEN 6.00 AND 9.80 THEN stg.odds_price_traded + 0.20
				WHEN stg.odds_price_traded BETWEEN 10.00 AND 19.5 THEN stg.odds_price_traded + 0.50
				WHEN stg.odds_price_traded BETWEEN 20.00 AND 29.00 THEN stg.odds_price_traded + 1.00
				WHEN stg.odds_price_traded BETWEEN 30.00 AND 48.00 THEN stg.odds_price_traded + 2.00
				WHEN stg.odds_price_traded BETWEEN 50.00 AND 95.00 THEN stg.odds_price_traded + 5.00
				WHEN stg.odds_price_traded BETWEEN 100.00 AND 1000.0 THEN stg.odds_price_traded + 10.00
			END AS odds_price_traded_lay 
			,CAST(NULL AS INT) AS matched_bets_order
			,stg.market_result
			,'R'	AS odds_source -- odds from betfair
FROM		#bet_market_odds		stg
			LEFT OUTER JOIN
			dbo.bet_market_odds		bmo
			ON stg.market_id = bmo.market_id
			AND stg.runner_id = bmo.runner_id
			AND stg.odds_timestamp = bmo.odds_timestamp
WHERE		bmo.market_id IS NULL


-------------------------------------------------------------------------------------------------
-- Fill in missing odds
-------------------------------------------------------------------------------------------------



EXEC [dbo].[sp_build_bet_market_odds_missing_odds]







-------------------------------------------------------------------------------------------------
-- Update primary key column
-------------------------------------------------------------------------------------------------

;WITH PK_ID AS
(
SELECT		bet_market_odds_id
			,ROW_NUMBER() OVER (ORDER BY market_id, runner_id, odds_timestamp) AS row_num
FROM		dbo.bet_market_odds
)
UPDATE PK_ID
SET bet_market_odds_id = row_num;

-------------------------------------------------------------------------------------------------
-- Create an ordering of market odds timestamps
-------------------------------------------------------------------------------------------------

;WITH MATCHORDER AS
(
SELECT		bmo.bet_market_odds_id
			,ROW_NUMBER() OVER (PARTITION BY market_id, runner_id ORDER BY odds_timestamp) AS matched_bets_order
FROM		dbo.bet_market_odds		bmo
WHERE		bmo.market_status = 'OPEN'
)
UPDATE	dbo.bet_market_odds
SET		matched_bets_order = cte.matched_bets_order
FROM	MATCHORDER	cte
		INNER JOIN
		dbo.bet_market_odds		bmt
		ON cte.bet_market_odds_id = bmt.bet_market_odds_id

-------------------------------------------------------------------------------------------------
-- Delete duplicates over market_id, runner_id and odds_timestamp
-------------------------------------------------------------------------------------------------

;WITH DELETEDUPLICATES AS
(
SELECT		market_id
			,runner_id
			,odds_timestamp
			,ROW_NUMBER() OVER(PARTITION BY market_id, runner_id, odds_timestamp ORDER BY matched_bets_order) AS [rn]
FROM		dbo.bet_market_odds		bmo
)
DELETE FROM DELETEDUPLICATES WHERE [rn] > 1

-------------------------------------------------------------------------------------------------
-- Add in missing data for a WINNER
-------------------------------------------------------------------------------------------------

INSERT INTO dbo.bet_market_odds(bet_market_odds_id
							   ,market_id
							   ,odds_timestamp
							   ,odds_timestamp_display_id
							   ,odds_timestamp_display
							   ,market_status
							   ,market_in_play
							   ,runner_id
							   ,runner_name
							   ,runner_name_display
							   ,bet_selection_id
							   ,odds_price_traded
							   ,odds_price_traded_lay
							   ,matched_bets_order
							   ,market_result
							   )
SELECT		bmo.bet_market_odds_id * -1 AS bet_market_odds_id
			,bmo.market_id
			,DATEADD(SECOND, 1, bmo.odds_timestamp)			AS odds_timestamp
			,bmo.odds_timestamp_display_id					AS odds_timestamp_display_id -- might be an issue with .999 adding to the next display id
			,DATEADD(SECOND, 1, bmo.odds_timestamp_display)	AS odds_timestamp_display
			,bmo.market_status
			,bmo.market_in_play
			,bmo.runner_id
			,bmo.runner_name
			,bmo.runner_name_display
			,bmo.bet_selection_id
			,1.01 AS odds_price_traded
			,1.02 AS odds_price_traded_lay
			,bmo.matched_bets_order + 1 AS matched_bets_order
			,bmr.market_result
FROM		dbo.bet_market_odds		bmo
			INNER JOIN
			dbo.bet_markets			bmt
			ON bmo.market_id = bmt.market_id
			INNER JOIN
			dbo.event_details		evt
			ON bmt.event_id = evt.event_id
			INNER JOIN
			dbo.bet_market_results	bmr
			ON bmo.market_id = bmr.market_id
			AND bmo.runner_id = bmr.runner_id
WHERE		1 = 1
AND			bmo.market_status <> 'SUSPENDED'
AND			bmr.market_result = 'WINNER'
AND			bmo.odds_price_traded <> 1.01
AND			bmo.matched_bets_order = (SELECT	MAX(o.matched_bets_order)
										FROM	dbo.bet_market_odds o
												INNER JOIN
												dbo.bet_market_results	r
												ON o.market_id = r.market_id
												AND o.runner_id = r.runner_id
										WHERE	o.market_id = bmo.market_id
										AND		o.runner_id = bmo.runner_id
										AND		o.market_in_play = 'True'
										AND		r.market_result = 'WINNER'
										AND		o.market_status <> 'SUSPENDED'
										)

-------------------------------------------------------------------------------------------------
-- End processing
-------------------------------------------------------------------------------------------------

END