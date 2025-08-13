CREATE TABLE [dbo].[event_match_odds] (
    [event_id]                INT            NOT NULL,
    [event_name]              VARCHAR (50)   COLLATE Latin1_General_100_BIN2_UTF8 NULL,
    [home_team]               VARCHAR (50)   COLLATE Latin1_General_100_BIN2_UTF8 NULL,
    [away_team]               VARCHAR (50)   COLLATE Latin1_General_100_BIN2_UTF8 NULL,
    [market_time]             DATETIME2 (0)  NULL,
    [match_odds_winner]       VARCHAR (50)   COLLATE Latin1_General_100_BIN2_UTF8 NULL,
    [country_code]            VARCHAR (5)    COLLATE Latin1_General_100_BIN2_UTF8 NULL,
    [league_name]             VARCHAR (50)   COLLATE Latin1_General_100_BIN2_UTF8 NULL,
    [bet_home]                NUMERIC (8, 2) NULL,
    [bet_draw]                NUMERIC (8, 2) NULL,
    [bet_away]                NUMERIC (8, 2) NULL,
    [lay_home]                NUMERIC (9, 2) NULL,
    [lay_draw]                NUMERIC (9, 2) NULL,
    [lay_away]                NUMERIC (9, 2) NULL,
    [pre_game_ticks]          BIGINT         NULL,
    [pre_kickoff_timestamps]  INT            NULL,
    [post_kickoff_timestamps] INT            NULL
);

