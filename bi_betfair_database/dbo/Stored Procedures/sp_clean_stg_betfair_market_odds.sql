CREATE PROCEDURE [dbo].[sp_clean_stg_betfair_market_odds]
AS
BEGIN

SET NOCOUNT ON

-------------------------------------------------------------------------------------------------
-- Delete Test, Womens, Reserves and Under 21 games
-------------------------------------------------------------------------------------------------

DELETE FROM stg.betfair_market_odds WHERE eventName LIKE 'Test %'
DELETE FROM stg.betfair_market_odds WHERE eventName LIKE '%(W)%'
DELETE FROM stg.betfair_market_odds WHERE eventName LIKE '%(Res)%'
DELETE FROM stg.betfair_market_odds WHERE eventName LIKE '%U21%'

-------------------------------------------------------------------------------------------------
-- Determine games that have valid results
-------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #VALIDCLOSED

SELECT		w.marketId
INTO		#VALIDCLOSED
FROM		(
			SELECT		DISTINCT
						marketId
			FROM		stg.betfair_market_odds
			WHERE		marketStatus = 'CLOSED'
			AND			runnerStatus = 'WINNER'
			) w
			INNER JOIN
			(
			SELECT		DISTINCT
						marketId
			FROM		stg.betfair_market_odds
			WHERE		marketStatus = 'CLOSED'
			AND			runnerStatus = 'LOSER'
			) l
			ON w.marketId = l.marketId

DELETE FROM stg.betfair_market_odds WHERE marketId NOT IN (SELECT marketId FROM #VALIDCLOSED);

-------------------------------------------------------------------------------------------------
-- Delete rows with missing odds
-------------------------------------------------------------------------------------------------

DELETE FROM stg.betfair_market_odds WHERE marketStatus IN ('OPEN') AND ISNULL(lastPriceTraded, '') = ''

-------------------------------------------------------------------------------------------------
-- Handle multiple market status = SUSPENDED at same timestamp for a market and runner
-------------------------------------------------------------------------------------------------

DELETE FROM stg.betfair_market_odds WHERE marketStatus IN ('SUSPENDED') AND ISNULL(lastPriceTraded, '') = ''

-------------------------------------------------------------------------------------------------
-- Delete markets that don't go in-play
-------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #ISINPLAY

SELECT		t.marketId
INTO		#ISINPLAY
FROM		(
			SELECT		DISTINCT
						marketId
			FROM		stg.betfair_market_odds
			WHERE		inPlay = 'True'
			) t
			INNER JOIN
			(
			SELECT		DISTINCT
						marketId
			FROM		stg.betfair_market_odds
			WHERE		inPlay = 'False'
			) f
			ON t.marketId = f.marketId

DELETE FROM stg.betfair_market_odds WHERE marketId NOT IN (SELECT marketId FROM #ISINPLAY);



-------------------------------------------------------------------------------------------------
-- End processing
-------------------------------------------------------------------------------------------------

END