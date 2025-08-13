CREATE PROCEDURE [dbo].[sp_build_market_odds_hour_before_game] (@hours_before		INT = 8)
AS
BEGIN

SET NOCOUNT ON

-------------------------------------------------------------------------------------------------
-- Processing
-------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS dbo.market_odds_hour_before_game
CREATE TABLE dbo.market_odds_hour_before_game (market_id			INT NOT NULL
												,market_type		VARCHAR(20) COLLATE Latin1_General_100_BIN2_UTF8 NULL
												,runner_id			INT NOT NULL
												,runner_name		VARCHAR(50) COLLATE Latin1_General_100_BIN2_UTF8 NULL
												,hour_before		DATETIME2(0) NULL
												,odds_hour_before	NUMERIC(8, 2) NULL
												)

;WITH ODDSHOURBEFORE AS
(
SELECT		bmo.market_id
			,bet.market_type
			,bmo.runner_id
			,bmo.runner_name
			,MAX(bmo.odds_timestamp) AS hour_before
			,SUM(CASE WHEN bmo.odds_timestamp < DATEADD(HOUR, -1 * @hours_before, gip.event_goes_in_play) THEN 1 ELSE 0 END) AS pre_market_timestamps

FROM		dbo.bet_market_odds		bmo
			INNER JOIN
			dbo.bet_markets			bet
			ON bmo.market_id = bet.market_id
			INNER JOIN
			dbo.event_details		gip
			ON bet.event_id = gip.event_id
--WHERE		CASE WHEN bmo.odds_timestamp > DATEADD(HOUR, -2, gip.event_goes_in_play) THEN 0 ELSE 1 END = 1
WHERE		CASE WHEN bmo.odds_timestamp > DATEADD(HOUR, -1 * @hours_before, gip.event_goes_in_play) THEN 0 ELSE 1 END = 1
AND			bmo.odds_price_traded IS NOT NULL
GROUP BY	bmo.market_id
			,bet.market_type
			,bmo.runner_id
			,bmo.runner_name
)
INSERT INTO dbo.market_odds_hour_before_game (market_id
												,market_type
												,runner_id
												,runner_name
												,hour_before
												,odds_hour_before
												)
SELECT		hrb.market_id
			,hrb.market_type
			,hrb.runner_id
			,hrb.runner_name
			,hrb.hour_before
			,bmo.odds_price_traded	AS odds_hour_before
FROM		dbo.bet_market_odds		bmo
			INNER JOIN
			ODDSHOURBEFORE			hrb
			ON bmo.market_id = hrb.market_id
			AND bmo.runner_id = hrb.runner_id
			AND bmo.odds_timestamp = hrb.hour_before

-------------------------------------------------------------------------------------------------
-- End processing
-------------------------------------------------------------------------------------------------

END