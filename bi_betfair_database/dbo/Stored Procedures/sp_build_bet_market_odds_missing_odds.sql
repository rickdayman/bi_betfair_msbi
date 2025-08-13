CREATE PROCEDURE [dbo].[sp_build_bet_market_odds_missing_odds]
AS
BEGIN

SET NOCOUNT ON

-------------------------------------------------------------------------------------------------
-- find timestamp matches
-------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #overunder
CREATE TABLE #overunder(market_id			INT
						,odds_timestamp		DATETIME2(0)
						,odds_u				NUMERIC(8, 2)	
						,odds_o				NUMERIC(8, 2)
						)

INSERT INTO #overunder(market_id
						,odds_timestamp
						,odds_u
						,odds_o
						)
SELECT		market_id
			,odds_timestamp
			,MIN(CASE WHEN runner_name = 'Under 0.5 Goals' THEN odds_price_traded ELSE NULL END) AS odds_u
			,MIN(CASE WHEN runner_name = 'Over 0.5 Goals' THEN odds_price_traded ELSE NULL END) AS odds_o
FROM		dbo.bet_market_odds
WHERE		bet_selection_id IN (4, 5)
GROUP BY	market_id
			,odds_timestamp

INSERT INTO #overunder(market_id
						,odds_timestamp
						,odds_u
						,odds_o
						)
SELECT		market_id
			,odds_timestamp
			,MIN(CASE WHEN runner_name = 'Under 1.5 Goals' THEN odds_price_traded ELSE NULL END) AS odds_u
			,MIN(CASE WHEN runner_name = 'Over 1.5 Goals' THEN odds_price_traded ELSE NULL END) AS odds_o
FROM		dbo.bet_market_odds
WHERE		bet_selection_id IN (6, 7)
GROUP BY	market_id
			,odds_timestamp

INSERT INTO #overunder(market_id
						,odds_timestamp
						,odds_u
						,odds_o
						)
SELECT		market_id
			,odds_timestamp
			,MIN(CASE WHEN runner_name = 'Under 2.5 Goals' THEN odds_price_traded ELSE NULL END) AS odds_u
			,MIN(CASE WHEN runner_name = 'Over 2.5 Goals' THEN odds_price_traded ELSE NULL END) AS odds_o
FROM		dbo.bet_market_odds
WHERE		bet_selection_id IN (8, 9)
GROUP BY	market_id
			,odds_timestamp

INSERT INTO #overunder(market_id
						,odds_timestamp
						,odds_u
						,odds_o
						)
SELECT		market_id
			,odds_timestamp
			,MIN(CASE WHEN runner_name = 'Under 3.5 Goals' THEN odds_price_traded ELSE NULL END) AS odds_u
			,MIN(CASE WHEN runner_name = 'Over 3.5 Goals' THEN odds_price_traded ELSE NULL END) AS odds_o
FROM		dbo.bet_market_odds
WHERE		bet_selection_id IN (10, 11)
GROUP BY	market_id
			,odds_timestamp

INSERT INTO #overunder(market_id
						,odds_timestamp
						,odds_u
						,odds_o
						)
SELECT		market_id
			,odds_timestamp
			,MIN(CASE WHEN runner_name = 'Under 4.5 Goals' THEN odds_price_traded ELSE NULL END) AS odds_u
			,MIN(CASE WHEN runner_name = 'Over 4.5 Goals' THEN odds_price_traded ELSE NULL END) AS odds_o
FROM		dbo.bet_market_odds
WHERE		bet_selection_id IN (12, 13)
GROUP BY	market_id
			,odds_timestamp

-------------------------------------------------------------------------------------------------
-- Insert missing under odds
-------------------------------------------------------------------------------------------------

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
SELECT		0									AS bet_market_odds_id
			,bmo.market_id
			,bmo.odds_timestamp
			,bmo.odds_timestamp_display_id
			,bmo.odds_timestamp_display
			,bmo.market_status
			,bmo.market_in_play
			,CASE
				WHEN bmo.runner_id = 5851483	THEN 5851482
				WHEN bmo.runner_id = 5851482	THEN 5851483
				WHEN bmo.runner_id = 1221386	THEN 1221385
				WHEN bmo.runner_id = 1221385	THEN 1221386
				WHEN bmo.runner_id = 47973		THEN 47972
				WHEN bmo.runner_id = 47972		THEN 47973
				WHEN bmo.runner_id = 1222345	THEN 1222344
				WHEN bmo.runner_id = 1222344	THEN 1222345
				WHEN bmo.runner_id = 1222346	THEN 1222347
				WHEN bmo.runner_id = 1222347	THEN 1222346
			END									AS runner_id
			,CASE
				WHEN bmo.runner_name LIKE 'Under%' THEN REPLACE(bmo.runner_name, 'Under', 'Over')
				WHEN bmo.runner_name LIKE 'Over%' THEN REPLACE(bmo.runner_name, 'Over', 'Under')
			END									AS runner_name
			,CASE
				WHEN bmo.runner_name_display LIKE 'Under%' THEN REPLACE(bmo.runner_name_display, 'Under', 'Over')
				WHEN bmo.runner_name_display LIKE 'Over%' THEN REPLACE(bmo.runner_name_display, 'Over', 'Under')
			END									AS runner_name_display
			,CASE
				WHEN bmo.bet_selection_id = 4 THEN 5
				WHEN bmo.bet_selection_id = 5 THEN 4
				WHEN bmo.bet_selection_id = 6 THEN 7
				WHEN bmo.bet_selection_id = 7 THEN 6
				WHEN bmo.bet_selection_id = 8 THEN 9
				WHEN bmo.bet_selection_id = 9 THEN 8
				WHEN bmo.bet_selection_id = 10 THEN 11
				WHEN bmo.bet_selection_id = 11 THEN 10
				WHEN bmo.bet_selection_id = 12 THEN 13
				WHEN bmo.bet_selection_id = 13 THEN 12
			END									AS bet_selection_id
			,CAST(1.0 / (1.0 - (1.0 / odds_o)) AS NUMERIC(8, 2)) AS odds_price_traded
			,CASE
				WHEN CAST(1.0 / (1.0 - (1.0 / odds_o)) AS NUMERIC(8, 2)) BETWEEN 1.01 AND 1.99 THEN CAST(1.0 / (1.0 - (1.0 / odds_o)) AS NUMERIC(8, 2)) + 0.01
				WHEN CAST(1.0 / (1.0 - (1.0 / odds_o)) AS NUMERIC(8, 2)) BETWEEN 2.00 AND 2.98 THEN CAST(1.0 / (1.0 - (1.0 / odds_o)) AS NUMERIC(8, 2)) + 0.02
				WHEN CAST(1.0 / (1.0 - (1.0 / odds_o)) AS NUMERIC(8, 2)) BETWEEN 3.00 AND 3.95 THEN CAST(1.0 / (1.0 - (1.0 / odds_o)) AS NUMERIC(8, 2)) + 0.05
				WHEN CAST(1.0 / (1.0 - (1.0 / odds_o)) AS NUMERIC(8, 2)) BETWEEN 4.00 AND 5.90 THEN CAST(1.0 / (1.0 - (1.0 / odds_o)) AS NUMERIC(8, 2)) + 0.10
				WHEN CAST(1.0 / (1.0 - (1.0 / odds_o)) AS NUMERIC(8, 2)) BETWEEN 6.00 AND 9.80 THEN CAST(1.0 / (1.0 - (1.0 / odds_o)) AS NUMERIC(8, 2)) + 0.20
				WHEN CAST(1.0 / (1.0 - (1.0 / odds_o)) AS NUMERIC(8, 2)) BETWEEN 10.00 AND 19.5 THEN CAST(1.0 / (1.0 - (1.0 / odds_o)) AS NUMERIC(8, 2)) + 0.50
				WHEN CAST(1.0 / (1.0 - (1.0 / odds_o)) AS NUMERIC(8, 2)) BETWEEN 20.00 AND 29.00 THEN CAST(1.0 / (1.0 - (1.0 / odds_o)) AS NUMERIC(8, 2)) + 1.00
				WHEN CAST(1.0 / (1.0 - (1.0 / odds_o)) AS NUMERIC(8, 2)) BETWEEN 30.00 AND 48.00 THEN CAST(1.0 / (1.0 - (1.0 / odds_o)) AS NUMERIC(8, 2)) + 2.00
				WHEN CAST(1.0 / (1.0 - (1.0 / odds_o)) AS NUMERIC(8, 2)) BETWEEN 50.00 AND 95.00 THEN CAST(1.0 / (1.0 - (1.0 / odds_o)) AS NUMERIC(8, 2)) + 5.00
				WHEN CAST(1.0 / (1.0 - (1.0 / odds_o)) AS NUMERIC(8, 2)) BETWEEN 100.00 AND 1000.0 THEN CAST(1.0 / (1.0 - (1.0 / odds_o)) AS NUMERIC(8, 2)) + 10.00
			END AS odds_price_traded_lay
			,0									AS matched_bets_order
			,CASE
				WHEN bmo.market_result = 'WINNER' THEN 'LOSER'
				WHEN bmo.market_result = 'LOSER' THEN 'WINNER'
			END									AS market_result
			,'I'	AS odds_source
FROM		#overunder				odd
			INNER JOIN
			dbo.bet_market_odds		bmo
			ON odd.market_id = bmo.market_id
			AND odd.odds_timestamp = bmo.odds_timestamp
WHERE		odds_u IS NULL

-------------------------------------------------------------------------------------------------
-- Insert missing over odds
-------------------------------------------------------------------------------------------------

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
SELECT		0									AS bet_market_odds_id
			,bmo.market_id
			,bmo.odds_timestamp
			,bmo.odds_timestamp_display_id
			,bmo.odds_timestamp_display
			,bmo.market_status
			,bmo.market_in_play
			,CASE
				WHEN bmo.runner_id = 5851483	THEN 5851482
				WHEN bmo.runner_id = 5851482	THEN 5851483
				WHEN bmo.runner_id = 1221386	THEN 1221385
				WHEN bmo.runner_id = 1221385	THEN 1221386
				WHEN bmo.runner_id = 47973		THEN 47972
				WHEN bmo.runner_id = 47972		THEN 47973
				WHEN bmo.runner_id = 1222345	THEN 1222344
				WHEN bmo.runner_id = 1222344	THEN 1222345
				WHEN bmo.runner_id = 1222346	THEN 1222347
				WHEN bmo.runner_id = 1222347	THEN 1222346
			END									AS runner_id
			,CASE
				WHEN bmo.runner_name LIKE 'Under%' THEN REPLACE(bmo.runner_name, 'Under', 'Over')
				WHEN bmo.runner_name LIKE 'Over%' THEN REPLACE(bmo.runner_name, 'Over', 'Under')
			END									AS runner_name
			,CASE
				WHEN bmo.runner_name_display LIKE 'Under%' THEN REPLACE(bmo.runner_name_display, 'Under', 'Over')
				WHEN bmo.runner_name_display LIKE 'Over%' THEN REPLACE(bmo.runner_name_display, 'Over', 'Under')
			END									AS runner_name_display
			,CASE
				WHEN bmo.bet_selection_id = 4 THEN 5
				WHEN bmo.bet_selection_id = 5 THEN 4
				WHEN bmo.bet_selection_id = 6 THEN 7
				WHEN bmo.bet_selection_id = 7 THEN 6
				WHEN bmo.bet_selection_id = 8 THEN 9
				WHEN bmo.bet_selection_id = 9 THEN 8
				WHEN bmo.bet_selection_id = 10 THEN 11
				WHEN bmo.bet_selection_id = 11 THEN 10
				WHEN bmo.bet_selection_id = 12 THEN 13
				WHEN bmo.bet_selection_id = 13 THEN 12
			END									AS bet_selection_id
			,CAST(1.0 / (1.0 - (1.0 / odds_u)) AS NUMERIC(8, 2)) AS odds_price_traded
			,CASE
				WHEN CAST(1.0 / (1.0 - (1.0 / odds_u)) AS NUMERIC(8, 2)) BETWEEN 1.01 AND 1.99 THEN CAST(1.0 / (1.0 - (1.0 / odds_u)) AS NUMERIC(8, 2)) + 0.01
				WHEN CAST(1.0 / (1.0 - (1.0 / odds_u)) AS NUMERIC(8, 2)) BETWEEN 2.00 AND 2.98 THEN CAST(1.0 / (1.0 - (1.0 / odds_u)) AS NUMERIC(8, 2)) + 0.02
				WHEN CAST(1.0 / (1.0 - (1.0 / odds_u)) AS NUMERIC(8, 2)) BETWEEN 3.00 AND 3.95 THEN CAST(1.0 / (1.0 - (1.0 / odds_u)) AS NUMERIC(8, 2)) + 0.05
				WHEN CAST(1.0 / (1.0 - (1.0 / odds_u)) AS NUMERIC(8, 2)) BETWEEN 4.00 AND 5.90 THEN CAST(1.0 / (1.0 - (1.0 / odds_u)) AS NUMERIC(8, 2)) + 0.10
				WHEN CAST(1.0 / (1.0 - (1.0 / odds_u)) AS NUMERIC(8, 2)) BETWEEN 6.00 AND 9.80 THEN CAST(1.0 / (1.0 - (1.0 / odds_u)) AS NUMERIC(8, 2)) + 0.20
				WHEN CAST(1.0 / (1.0 - (1.0 / odds_u)) AS NUMERIC(8, 2)) BETWEEN 10.00 AND 19.5 THEN CAST(1.0 / (1.0 - (1.0 / odds_u)) AS NUMERIC(8, 2)) + 0.50
				WHEN CAST(1.0 / (1.0 - (1.0 / odds_u)) AS NUMERIC(8, 2)) BETWEEN 20.00 AND 29.00 THEN CAST(1.0 / (1.0 - (1.0 / odds_u)) AS NUMERIC(8, 2)) + 1.00
				WHEN CAST(1.0 / (1.0 - (1.0 / odds_u)) AS NUMERIC(8, 2)) BETWEEN 30.00 AND 48.00 THEN CAST(1.0 / (1.0 - (1.0 / odds_u)) AS NUMERIC(8, 2)) + 2.00
				WHEN CAST(1.0 / (1.0 - (1.0 / odds_u)) AS NUMERIC(8, 2)) BETWEEN 50.00 AND 95.00 THEN CAST(1.0 / (1.0 - (1.0 / odds_u)) AS NUMERIC(8, 2)) + 5.00
				WHEN CAST(1.0 / (1.0 - (1.0 / odds_u)) AS NUMERIC(8, 2)) BETWEEN 100.00 AND 1000.0 THEN CAST(1.0 / (1.0 - (1.0 / odds_u)) AS NUMERIC(8, 2)) + 10.00
			END AS odds_price_traded_lay
			,0									AS matched_bets_order
			,CASE
				WHEN bmo.market_result = 'WINNER' THEN 'LOSER'
				WHEN bmo.market_result = 'LOSER' THEN 'WINNER'
			END									AS market_result
			,'I'	AS odds_source
FROM		#overunder				odd
			INNER JOIN
			dbo.bet_market_odds		bmo
			ON odd.market_id = bmo.market_id
			AND odd.odds_timestamp = bmo.odds_timestamp
WHERE		odds_o IS NULL


-------------------------------------------------------------------------------------------------
-- End processing
-------------------------------------------------------------------------------------------------

END