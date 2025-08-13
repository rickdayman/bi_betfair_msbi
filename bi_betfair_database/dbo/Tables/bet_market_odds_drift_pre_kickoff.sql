CREATE TABLE [dbo].[bet_market_odds_drift_pre_kickoff] (
    [market_id]                INT              NOT NULL,
    [runner_id]                INT              NOT NULL,
    [runner_name]              VARCHAR (50)     COLLATE Latin1_General_100_BIN2_UTF8 NULL,
    [runner_name_display]      VARCHAR (50)     COLLATE Latin1_General_100_BIN2_UTF8 NULL,
    [event_id]                 INT              NULL,
    [market_8hrs_before_order] INT              NULL,
    [odds_opening]             NUMERIC (8, 2)   NULL,
    [odds_8hrs_before]         NUMERIC (8, 2)   NULL,
    [drift_desc]               VARCHAR (14)     NULL,
    [drift_percent]            NUMERIC (20, 11) NULL
);

