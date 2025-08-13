CREATE PROCEDURE [dbo].[sp_build_dw]
AS
BEGIN

SET NOCOUNT ON

-------------------------------------------------------------------------------------------------
-- Processing
-------------------------------------------------------------------------------------------------

-- Remember to change 1 hour from 6

EXEC dbo.sp_build_bet_selection
EXEC dbo.sp_clean_stg_betfair_market_odds
EXEC dbo.sp_clean_stg_football_data

EXEC dbo.sp_build_bet_market_odds
EXEC dbo.sp_build_bet_markets
EXEC dbo.sp_build_bet_market_results
EXEC dbo.sp_build_event_goes_in_play
EXEC dbo.sp_build_event_details
EXEC dbo.sp_build_bet_trade_dates

EXEC dbo.sp_build_market_odds_hour_before_game @hours_before = 6
EXEC dbo.sp_build_event_odds
EXEC dbo.sp_build_bet_market_odds_drift_pre_kickoff

EXEC dbo.sp_build_event_goal_times
EXEC dbo.sp_build_bet_market_goals_close

EXEC dbo.sp_build_reference_tables
EXEC dbo.sp_build_table_indexes



-------------------------------------------------------------------------------------------------
-- End processing
-------------------------------------------------------------------------------------------------

END