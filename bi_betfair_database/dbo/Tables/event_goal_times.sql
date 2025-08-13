CREATE TABLE [dbo].[event_goal_times] (
    [event_id]      INT           NULL,
    [event_name]    VARCHAR (50)  COLLATE Latin1_General_100_BIN2_UTF8 NULL,
    [league_name]   VARCHAR (50)  COLLATE Latin1_General_100_BIN2_UTF8 NULL,
    [market_time]   DATETIME2 (0) NULL,
    [odd_snapshots] INT           NULL,
    [game_start]    DATETIME      NULL,
    [game_end]      DATETIME      NULL,
    [goal1]         DATETIME2 (3) NULL,
    [goal2]         DATETIME2 (3) NULL,
    [goal3]         DATETIME2 (3) NULL,
    [goal4]         DATETIME2 (3) NULL,
    [goal5]         DATETIME2 (3) NULL,
    [event_goals]   INT           NULL
);

