CREATE TABLE [dbo].[bet_markets] (
    [market_id]                    INT           NOT NULL,
    [market_type]                  VARCHAR (20)  COLLATE Latin1_General_100_BIN2_UTF8 NULL,
    [event_id]                     INT           NULL,
    [event_name]                   VARCHAR (50)  COLLATE Latin1_General_100_BIN2_UTF8 NULL,
    [country_code]                 VARCHAR (5)   COLLATE Latin1_General_100_BIN2_UTF8 NULL,
    [market_time]                  DATETIME2 (0) NULL,
    [home_team]                    VARCHAR (50)  COLLATE Latin1_General_100_BIN2_UTF8 NULL,
    [away_team]                    VARCHAR (50)  COLLATE Latin1_General_100_BIN2_UTF8 NULL,
    [market_open_timestamp]        DATETIME2 (0) NULL,
    [market_inplay_timestamp]      DATETIME2 (0) NULL,
    [pre_inplay_timestamp_count]   INT           NULL,
    [is_open_24hrs_before_kickoff] INT           NULL,
    CONSTRAINT [pk_bet_markets_market_id] PRIMARY KEY CLUSTERED ([market_id] ASC)
);

