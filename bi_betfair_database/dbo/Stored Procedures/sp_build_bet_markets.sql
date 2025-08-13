CREATE PROCEDURE [dbo].[sp_build_bet_markets]
AS
BEGIN

SET NOCOUNT ON

-------------------------------------------------------------------------------------------------
-- Drop primary key
-------------------------------------------------------------------------------------------------

ALTER TABLE dbo.bet_markets DROP CONSTRAINT IF EXISTS pk_bet_markets_market_id;

-------------------------------------------------------------------------------------------------
-- Processing
-------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS dbo.bet_markets
CREATE TABLE dbo.bet_markets (market_id							INT NULL
								,market_type					VARCHAR(20) COLLATE Latin1_General_100_BIN2_UTF8 NULL
								,event_id						INT NULL
								,event_name						VARCHAR(50) COLLATE Latin1_General_100_BIN2_UTF8 NULL
								,country_code					VARCHAR(5) COLLATE Latin1_General_100_BIN2_UTF8 NULL
								,market_time					DATETIME2(0) NULL
								,home_team						VARCHAR(50) COLLATE Latin1_General_100_BIN2_UTF8 NULL
								,away_team						VARCHAR(50) COLLATE Latin1_General_100_BIN2_UTF8 NULL
								,market_open_timestamp			DATETIME2(0) NULL
								,market_inplay_timestamp		DATETIME2(0) NULL
								,pre_inplay_timestamp_count		INT NULL
								,is_open_24hrs_before_kickoff	INT NULL
								)

DROP TABLE IF EXISTS #stg_bet_markets

SELECT		CAST(CAST(marketId AS FLOAT) * 1000000000.0	AS INT)	AS market_id
			,CAST(marketType AS VARCHAR(20))					AS market_type
			,NULL												AS event_id
			,eventName											AS event_name
			,countryCode										AS country_code
			,MAX(CASE WHEN inPlay = 'True' THEN CAST(marketTime AS DATETIME2(0)) ELSE NULL END) AS market_time
			,CAST(PARSENAME(REPLACE([eventName], ' v ', '.'), 2) AS VARCHAR(50)) AS home_team
			,CAST(PARSENAME(REPLACE([eventName], ' v ', '.'), 1) AS VARCHAR(50)) AS away_team
			,CAST(NULL AS DATETIME2(0)) AS market_open_timestamp
			,CAST(NULL AS DATETIME2(0)) AS market_inplay_timestamp
			,CAST(NULL AS INT)		AS pre_inplay_timestamp_count
			,CAST(NULL AS INT)		AS is_open_24hrs_before_kickoff
INTO		#stg_bet_markets
FROM		stg.betfair_market_odds
GROUP BY	CAST(CAST(marketId AS FLOAT) * 1000000000.0	AS INT)
			,CAST(marketType AS VARCHAR(20))
			,eventName
			,countryCode


-------------------------------------------------------------------------------------------------
-- INSERT new data
-------------------------------------------------------------------------------------------------

INSERT INTO dbo.bet_markets (market_id
							,market_type
							,event_id
							,event_name
							,country_code
							,market_time
							,home_team
							,away_team
							,market_open_timestamp
							,market_inplay_timestamp
							,pre_inplay_timestamp_count
							,is_open_24hrs_before_kickoff)
SELECT		stg.market_id
			,stg.market_type
			,stg.event_id
			,stg.event_name
			,stg.country_code
			,stg.market_time
			,stg.home_team
			,stg.away_team
			,stg.market_open_timestamp
			,stg.market_inplay_timestamp
			,stg.pre_inplay_timestamp_count
			,stg.is_open_24hrs_before_kickoff
FROM		#stg_bet_markets	stg
			LEFT OUTER JOIN
			dbo.bet_markets		bmt
			ON stg.market_id = bmt.market_id
WHERE		bmt.market_id IS NULL


-------------------------------------------------------------------------------------------------
-- Create surrogate key for each game
-------------------------------------------------------------------------------------------------

;WITH UPDATE_EVENT_ID AS
(
SELECT		market_id
			,DENSE_RANK() OVER (PARTITION BY NULL ORDER BY event_name, market_time) AS event_id
FROM		dbo.bet_markets
)
UPDATE		dbo.bet_markets SET event_id = u.event_id
FROM		UPDATE_EVENT_ID u
			INNER JOIN
			dbo.bet_markets b
			ON u.market_id = b.market_id


-------------------------------------------------------------------------------------------------
-- Delete duplicates (deleting all of them including original, checked and they're not important)
-------------------------------------------------------------------------------------------------

DELETE FROM dbo.bet_markets WHERE market_id IN (SELECT		market_id
												FROM		dbo.bet_markets
												GROUP BY	market_id
												HAVING		COUNT(*) > 1
												)

-------------------------------------------------------------------------------------------------
-- Update market timestamps
-------------------------------------------------------------------------------------------------

;WITH MARKETTIMESTAMPS AS
(
SELECT		bmt.market_id
			,MIN(CASE WHEN bmo.market_status = 'OPEN' THEN bmo.odds_timestamp ELSE NULL END) AS market_open_timestamp
			,MIN(CASE WHEN bmo.market_status = 'OPEN' AND bmo.market_in_play = 'True' THEN bmo.odds_timestamp ELSE NULL END) AS market_inplay_timestamp
FROM		dbo.bet_markets			bmt
			INNER JOIN
			dbo.bet_market_odds		bmo
			ON bmt.market_id = bmo.market_id
GROUP BY	bmt.market_id
)
UPDATE	dbo.bet_markets
SET		market_open_timestamp = cte.market_open_timestamp
		,market_inplay_timestamp = cte.market_inplay_timestamp
FROM	MARKETTIMESTAMPS	cte
		INNER JOIN
		dbo.bet_markets		bmt
		ON cte.market_id = bmt.market_id

-------------------------------------------------------------------------------------------------
-- Update pre inplay timestamp counts
-------------------------------------------------------------------------------------------------

;WITH TIMESTAMPSCOUNT AS
(
SELECT		bmt.market_id
			,CASE WHEN bmt.market_open_timestamp < DATEADD(HOUR, -24, bmt.market_inplay_timestamp) THEN 1 ELSE 0 END AS is_open_24hrs_before_kickoff
			,SUM(CASE
					WHEN bmo.market_status = 'OPEN'
					AND bmo.odds_timestamp >= bmt.market_open_timestamp
					AND bmo.odds_timestamp < bmt.market_inplay_timestamp
					THEN 1
					ELSE 0
				END) AS pre_inplay_timestamp_count
FROM		dbo.bet_markets			bmt
			INNER JOIN
			dbo.bet_market_odds		bmo
			ON bmt.market_id = bmo.market_id
GROUP BY	bmt.market_id
			,CASE WHEN bmt.market_open_timestamp < DATEADD(HOUR, -24, bmt.market_inplay_timestamp) THEN 1 ELSE 0 END
)
UPDATE	dbo.bet_markets
SET		pre_inplay_timestamp_count = cte.pre_inplay_timestamp_count
		,is_open_24hrs_before_kickoff = cte.is_open_24hrs_before_kickoff
FROM	TIMESTAMPSCOUNT	cte
		INNER JOIN
		dbo.bet_markets		bmt
		ON cte.market_id = bmt.market_id


-------------------------------------------------------------------------------------------------
-- End processing
-------------------------------------------------------------------------------------------------

END