CREATE PROCEDURE [dbo].[sp_build_event_goes_in_play]
AS
BEGIN

SET NOCOUNT ON

-------------------------------------------------------------------------------------------------
-- Processing
-------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS dbo.event_goes_in_play;

SELECT		bet.event_id
			,MIN(bmo.odds_timestamp) AS goes_in_play
INTO		dbo.event_goes_in_play
FROM		dbo.bet_market_odds		bmo
			INNER JOIN
			dbo.bet_markets			bet
			ON bmo.market_id = bet.market_id
WHERE		bmo.market_in_play = 'True'
GROUP BY	bet.event_id

-------------------------------------------------------------------------------------------------
-- End processing
-------------------------------------------------------------------------------------------------

END