CREATE TABLE [dbo].[event_details] (
    [event_id]                   INT           NOT NULL,
    [event_name]                 VARCHAR (50)  COLLATE Latin1_General_100_BIN2_UTF8 NULL,
    [market_time]                DATETIME2 (0) NULL,
    [market_date_month_year]     INT           NULL,
    [country_code]               VARCHAR (5)   COLLATE Latin1_General_100_BIN2_UTF8 NULL,
    [home_team]                  VARCHAR (50)  COLLATE Latin1_General_100_BIN2_UTF8 NULL,
    [away_team]                  VARCHAR (50)  COLLATE Latin1_General_100_BIN2_UTF8 NULL,
    [match_odds_winner]          VARCHAR (50)  COLLATE Latin1_General_100_BIN2_UTF8 NULL,
    [league_name]                VARCHAR (50)  COLLATE Latin1_General_100_BIN2_UTF8 NULL,
    [home_team_goals_from_prv_6] INT           NULL,
    [away_team_goals_from_prv_6] INT           NULL,
    [event_goes_in_play]         DATETIME2 (0) NULL,
    CONSTRAINT [pk_event_details_event_id] PRIMARY KEY CLUSTERED ([event_id] ASC)
);

