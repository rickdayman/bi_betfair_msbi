CREATE TABLE [dbo].[market_odds_hour_before_game] (
    [market_id]        INT            NOT NULL,
    [market_type]      VARCHAR (20)   COLLATE Latin1_General_100_BIN2_UTF8 NULL,
    [runner_id]        INT            NOT NULL,
    [runner_name]      VARCHAR (50)   COLLATE Latin1_General_100_BIN2_UTF8 NULL,
    [hour_before]      DATETIME2 (0)  NULL,
    [odds_hour_before] NUMERIC (8, 2) NULL
);

