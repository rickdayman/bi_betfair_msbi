CREATE PROCEDURE [dbo].[sp_build_bet_selection]
AS
BEGIN

SET NOCOUNT ON

-------------------------------------------------------------------------------------------------
-- Processing
-------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS dbo.bet_selection
CREATE TABLE dbo.bet_selection (bet_selection_id		SMALLINT
								,market_type			VARCHAR(20)
								,selection_desc			VARCHAR(15)
								,is_drift_down			SMALLINT
								,is_drift_up			SMALLINT
								)

INSERT INTO dbo.bet_selection (bet_selection_id, market_type, selection_desc, is_drift_down, is_drift_up) VALUES (1, 'MATCH_ODDS', 'Home', 0, 1)
INSERT INTO dbo.bet_selection (bet_selection_id, market_type, selection_desc, is_drift_down, is_drift_up) VALUES (2, 'MATCH_ODDS', 'The Draw', 1, 0)
INSERT INTO dbo.bet_selection (bet_selection_id, market_type, selection_desc, is_drift_down, is_drift_up) VALUES (3, 'MATCH_ODDS', 'Away', 0, 1)

INSERT INTO dbo.bet_selection (bet_selection_id, market_type, selection_desc, is_drift_down, is_drift_up) VALUES (4, 'OVER_UNDER_05', 'Over 0.5 Goals', 0, 1)
INSERT INTO dbo.bet_selection (bet_selection_id, market_type, selection_desc, is_drift_down, is_drift_up) VALUES (5, 'OVER_UNDER_05', 'Under 0.5 Goals', 1, 0)

INSERT INTO dbo.bet_selection (bet_selection_id, market_type, selection_desc, is_drift_down, is_drift_up) VALUES (6, 'OVER_UNDER_15', 'Over 1.5 Goals', 0, 1)
INSERT INTO dbo.bet_selection (bet_selection_id, market_type, selection_desc, is_drift_down, is_drift_up) VALUES (7, 'OVER_UNDER_15', 'Under 1.5 Goals', 1, 0)
																										
INSERT INTO dbo.bet_selection (bet_selection_id, market_type, selection_desc, is_drift_down, is_drift_up) VALUES (8, 'OVER_UNDER_25', 'Over 2.5 Goals', 0, 1)
INSERT INTO dbo.bet_selection (bet_selection_id, market_type, selection_desc, is_drift_down, is_drift_up) VALUES (9, 'OVER_UNDER_25', 'Under 2.5 Goals', 1, 0)
																									
INSERT INTO dbo.bet_selection (bet_selection_id, market_type, selection_desc, is_drift_down, is_drift_up) VALUES (10, 'OVER_UNDER_35', 'Over 3.5 Goals', 0, 1)
INSERT INTO dbo.bet_selection (bet_selection_id, market_type, selection_desc, is_drift_down, is_drift_up) VALUES (11, 'OVER_UNDER_35', 'Under 3.5 Goals', 1, 0)
																								
INSERT INTO dbo.bet_selection (bet_selection_id, market_type, selection_desc, is_drift_down, is_drift_up) VALUES (12, 'OVER_UNDER_45', 'Over 4.5 Goals', 0, 1)
INSERT INTO dbo.bet_selection (bet_selection_id, market_type, selection_desc, is_drift_down, is_drift_up) VALUES (13, 'OVER_UNDER_45', 'Under 4.5 Goals', 1, 0)


/*
SELECT		*
FROM		dbo.bet_selection

*/

-------------------------------------------------------------------------------------------------
-- End processing
-------------------------------------------------------------------------------------------------

END