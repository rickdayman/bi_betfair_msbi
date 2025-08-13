CREATE PROCEDURE [dbo].[sp_build_table_indexes]
AS
BEGIN

SET NOCOUNT ON

-------------------------------------------------------------------------------------------------
-- bet_markets
-------------------------------------------------------------------------------------------------

EXEC('
ALTER TABLE dbo.bet_markets ALTER COLUMN market_id INT NOT NULL
')

EXEC('
IF NOT EXISTS (SELECT * FROM sys.key_constraints WHERE [type] = ''PK'' AND OBJECT_NAME(parent_object_id) = ''bet_markets'')
	BEGIN
		ALTER TABLE dbo.bet_markets ADD CONSTRAINT pk_bet_markets_market_id PRIMARY KEY (market_id);
	END
')

-------------------------------------------------------------------------------------------------
-- bet_market_results
-------------------------------------------------------------------------------------------------

EXEC('
ALTER TABLE dbo.bet_market_results ALTER COLUMN market_id INT NOT NULL;
ALTER TABLE dbo.bet_market_results ALTER COLUMN runner_id INT NOT NULL;
')

EXEC('
IF NOT EXISTS (SELECT * FROM sys.key_constraints WHERE [type] = ''PK'' AND OBJECT_NAME(parent_object_id) = ''bet_market_results'')
	BEGIN
		ALTER TABLE dbo.bet_market_results ADD CONSTRAINT pk_bet_market_results_market_id_runner_id PRIMARY KEY (market_id, runner_id);
	END
')



-------------------------------------------------------------------------------------------------
-- bet_market_results
-------------------------------------------------------------------------------------------------

EXEC('
ALTER TABLE dbo.bet_market_odds ALTER COLUMN market_id INT NOT NULL;
ALTER TABLE dbo.bet_market_odds ALTER COLUMN runner_id INT NOT NULL;
ALTER TABLE dbo.bet_market_odds ALTER COLUMN odds_timestamp DATETIME NOT NULL;
')

EXEC('
IF NOT EXISTS (SELECT * FROM sys.key_constraints WHERE [type] = ''PK'' AND OBJECT_NAME(parent_object_id) = ''bet_market_odds'')
	BEGIN
		ALTER TABLE dbo.bet_market_odds ADD CONSTRAINT pk_bet_market_odds_market_id_runner_id_odds_timestamp PRIMARY KEY (market_id, runner_id, odds_timestamp);
	END
')


IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name = 'ix_bet_market_odds_bet_selection_id' AND object_id = OBJECT_ID('bet_market_odds'))
BEGIN
    CREATE INDEX ix_bet_market_odds_bet_selection_id ON dbo.bet_market_odds(bet_selection_id);
END

IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name = 'ix_bet_market_odds_market_in_play' AND object_id = OBJECT_ID('bet_market_odds'))
BEGIN
    CREATE INDEX ix_bet_market_odds_market_in_play ON dbo.bet_market_odds(market_in_play);
END

-------------------------------------------------------------------------------------------------
-- event_details
-------------------------------------------------------------------------------------------------

EXEC('
ALTER TABLE dbo.event_details ALTER COLUMN event_id INT NOT NULL;
')

EXEC('
IF NOT EXISTS (SELECT * FROM sys.key_constraints WHERE [type] = ''PK'' AND OBJECT_NAME(parent_object_id) = ''event_details'')
	BEGIN
		ALTER TABLE dbo.event_details ADD CONSTRAINT pk_event_details_event_id PRIMARY KEY (event_id);
	END
')

-------------------------------------------------------------------------------------------------
-- End processing
-------------------------------------------------------------------------------------------------

END