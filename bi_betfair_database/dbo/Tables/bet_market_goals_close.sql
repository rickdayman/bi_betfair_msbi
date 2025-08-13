CREATE TABLE [dbo].[bet_market_goals_close] (
    [event_id]            INT           NULL,
    [market_id]           INT           NULL,
    [odds_timestamp]      DATETIME2 (0) NULL,
    [market_status]       VARCHAR (10)  NULL,
    [market_in_play]      VARCHAR (5)   NULL,
    [runner_id]           INT           NULL,
    [runner_name]         VARCHAR (50)  NULL,
    [runner_name_display] VARCHAR (50)  NULL,
    [bet_selection_id]    INT           NOT NULL,
    [runner_status]       VARCHAR (50)  NULL
);

