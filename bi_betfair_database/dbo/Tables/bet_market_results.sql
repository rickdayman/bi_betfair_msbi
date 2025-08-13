CREATE TABLE [dbo].[bet_market_results] (
    [market_id]     INT          NOT NULL,
    [runner_id]     INT          NOT NULL,
    [runner_name]   VARCHAR (50) COLLATE Latin1_General_100_BIN2_UTF8 NULL,
    [market_type]   VARCHAR (15) COLLATE Latin1_General_100_BIN2_UTF8 NULL,
    [market_result] VARCHAR (10) COLLATE Latin1_General_100_BIN2_UTF8 NULL,
    CONSTRAINT [pk_bet_market_results_market_id_runner_id] PRIMARY KEY CLUSTERED ([market_id] ASC, [runner_id] ASC)
);

