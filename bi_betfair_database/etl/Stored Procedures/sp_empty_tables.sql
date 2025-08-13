CREATE PROCEDURE [etl].[sp_empty_tables]
AS
BEGIN

SET NOCOUNT ON

-------------------------------------------------------------------------------------------------
-- Processing
-------------------------------------------------------------------------------------------------

TRUNCATE TABLE [dbo].[bet_market_odds]
TRUNCATE TABLE [dbo].[bet_markets]
TRUNCATE TABLE [dbo].[bet_market_results]
TRUNCATE TABLE [dbo].[bet_selection]
TRUNCATE TABLE [dbo].[event_details]
--TRUNCATE TABLE [dbo].[event_goal_times]
TRUNCATE TABLE [dbo].[event_goes_in_play]
TRUNCATE TABLE [dbo].[event_match_odds]
TRUNCATE TABLE [dbo].[event_odds]
TRUNCATE TABLE [dbo].[market_dates]
TRUNCATE TABLE [dbo].[bet_trade_dates]
TRUNCATE TABLE [dbo].[market_odds_hour_before_game]

-------------------------------------------------------------------------------------------------
-- End processing
-------------------------------------------------------------------------------------------------

END