CREATE TABLE [dbo].[event_over_under_odds] (
    [event_id]             INT            NOT NULL,
    [event_name]           VARCHAR (50)   COLLATE Latin1_General_100_BIN2_UTF8 NULL,
    [home_team]            VARCHAR (50)   COLLATE Latin1_General_100_BIN2_UTF8 NULL,
    [away_team]            VARCHAR (50)   COLLATE Latin1_General_100_BIN2_UTF8 NULL,
    [market_time]          DATETIME2 (0)  NULL,
    [league_name]          VARCHAR (50)   COLLATE Latin1_General_100_BIN2_UTF8 NULL,
    [over_under_25_winner] VARCHAR (50)   COLLATE Latin1_General_100_BIN2_UTF8 NULL,
    [bet_over_25]          NUMERIC (8, 2) NULL,
    [bet_under_25]         NUMERIC (8, 2) NULL,
    [lay_over_25]          NUMERIC (9, 2) NULL,
    [lay_under_25]         NUMERIC (9, 2) NULL,
    [over_under_35_winner] VARCHAR (50)   COLLATE Latin1_General_100_BIN2_UTF8 NULL,
    [bet_over_35]          NUMERIC (8, 2) NULL,
    [bet_under_35]         NUMERIC (8, 2) NULL,
    [lay_over_35]          NUMERIC (9, 2) NULL,
    [lay_under_35]         NUMERIC (9, 2) NULL,
    [over_under_45_winner] VARCHAR (50)   COLLATE Latin1_General_100_BIN2_UTF8 NULL,
    [bet_over_45]          NUMERIC (8, 2) NULL,
    [bet_under_45]         NUMERIC (8, 2) NULL,
    [lay_over_45]          NUMERIC (9, 2) NULL,
    [lay_under_45]         NUMERIC (9, 2) NULL
);

