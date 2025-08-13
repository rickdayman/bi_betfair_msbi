CREATE TABLE [dbo].[bet_market_odds] (
    [bet_market_odds_id]        BIGINT         NULL,
    [market_id]                 INT            NOT NULL,
    [odds_timestamp]            DATETIME       NOT NULL,
    [odds_timestamp_display_id] BIGINT         NULL,
    [odds_timestamp_display]    DATETIME2 (0)  NULL,
    [market_status]             VARCHAR (10)   COLLATE Latin1_General_100_BIN2_UTF8 NULL,
    [market_in_play]            VARCHAR (5)    COLLATE Latin1_General_100_BIN2_UTF8 NULL,
    [runner_id]                 INT            NOT NULL,
    [runner_name]               VARCHAR (50)   COLLATE Latin1_General_100_BIN2_UTF8 NULL,
    [runner_name_display]       VARCHAR (15)   COLLATE Latin1_General_100_BIN2_UTF8 NULL,
    [bet_selection_id]          INT            NOT NULL,
    [odds_price_traded]         NUMERIC (8, 2) NULL,
    [odds_price_traded_lay]     NUMERIC (9, 2) NULL,
    [matched_bets_order]        INT            NULL,
    [market_result]             VARCHAR (10)   NULL,
    [odds_source]               CHAR (1)       NULL,
    CONSTRAINT [pk_bet_market_odds_market_id_runner_id_odds_timestamp] PRIMARY KEY CLUSTERED ([market_id] ASC, [runner_id] ASC, [odds_timestamp] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_bet_market_odds_market_in_play]
    ON [dbo].[bet_market_odds]([market_in_play] ASC);


GO
CREATE NONCLUSTERED INDEX [ix_bet_market_odds_bet_selection_id]
    ON [dbo].[bet_market_odds]([bet_selection_id] ASC);

