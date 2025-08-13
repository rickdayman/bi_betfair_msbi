CREATE TABLE [dbo].[bet_trade_dates] (
    [bet_trade_date_id]     BIGINT        NULL,
    [bet_trade_date]        DATETIME2 (0) NULL,
    [date_year]             INT           NULL,
    [date_month_number]     INT           NULL,
    [date_month_year]       INT           NULL,
    [date_month_desc_short] CHAR (3)      COLLATE Latin1_General_100_BIN2_UTF8 NULL,
    [date_month_desc_long]  VARCHAR (15)  COLLATE Latin1_General_100_BIN2_UTF8 NULL,
    [date_month_year_desc]  VARCHAR (10)  COLLATE Latin1_General_100_BIN2_UTF8 NULL
);

