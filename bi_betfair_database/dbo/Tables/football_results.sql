CREATE TABLE [dbo].[football_results] (
    [event_id]                   INT           NULL,
    [league_code]                VARCHAR (50)  COLLATE Latin1_General_100_BIN2_UTF8 NULL,
    [game_date]                  DATETIME2 (0) NULL,
    [game_time]                  TIME (0)      NULL,
    [home_team]                  VARCHAR (50)  COLLATE Latin1_General_100_BIN2_UTF8 NULL,
    [away_team]                  VARCHAR (50)  COLLATE Latin1_General_100_BIN2_UTF8 NULL,
    [full_time_home_goals]       SMALLINT      NULL,
    [full_time_away_goals]       SMALLINT      NULL,
    [full_time_result]           CHAR (1)      COLLATE Latin1_General_100_BIN2_UTF8 NULL,
    [half_time_home_goals]       SMALLINT      NULL,
    [half_time_away_goals]       SMALLINT      NULL,
    [half_time_result]           CHAR (1)      COLLATE Latin1_General_100_BIN2_UTF8 NULL,
    [league_name]                VARCHAR (50)  COLLATE Latin1_General_100_BIN2_UTF8 NULL,
    [home_team_goals_from_prv_6] INT           NULL,
    [away_team_goals_from_prv_6] INT           NULL
);

