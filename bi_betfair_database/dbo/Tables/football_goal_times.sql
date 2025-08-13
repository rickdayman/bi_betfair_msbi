CREATE TABLE [dbo].[football_goal_times] (
    [game_id]            BIGINT        NULL,
    [event_name]         VARCHAR (100) COLLATE Latin1_General_100_BIN2_UTF8 NULL,
    [game_date]          DATETIME      NULL,
    [game_season]        VARCHAR (15)  COLLATE Latin1_General_100_BIN2_UTF8 NULL,
    [league_name]        VARCHAR (22)  COLLATE Latin1_General_100_BIN2_UTF8 NULL,
    [running_home_goals] SMALLINT      NULL,
    [running_away_goals] SMALLINT      NULL,
    [goal_time]          INT           NULL,
    [home_team]          VARCHAR (100) COLLATE Latin1_General_100_BIN2_UTF8 NULL,
    [away_team]          VARCHAR (100) COLLATE Latin1_General_100_BIN2_UTF8 NULL,
    [game_score]         VARCHAR (5)   COLLATE Latin1_General_100_BIN2_UTF8 NULL,
    [home_score]         SMALLINT      NULL,
    [away_score]         SMALLINT      NULL,
    [derived_score]      VARCHAR (5)   COLLATE Latin1_General_100_BIN2_UTF8 NULL
);

