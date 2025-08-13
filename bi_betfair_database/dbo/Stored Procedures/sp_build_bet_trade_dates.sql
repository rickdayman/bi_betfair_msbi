CREATE PROCEDURE [dbo].[sp_build_bet_trade_dates]
AS
BEGIN

SET NOCOUNT ON

-------------------------------------------------------------------------------------------------
-- Processing
-------------------------------------------------------------------------------------------------

DECLARE @min_datetime DATETIME;
DECLARE @max_datetime DATETIME;

SET @min_datetime = (SELECT MIN(odds_timestamp_display) FROM dbo.bet_market_odds);
SET @max_datetime = (SELECT MAX(odds_timestamp_display) FROM dbo.bet_market_odds);

-- Drop the table if it exists
DROP TABLE IF EXISTS dbo.bet_trade_dates;

-- Create the persistent table to store the minute increments
CREATE TABLE dbo.bet_trade_dates (bet_trade_date_id			BIGINT
									,bet_trade_date			DATETIME2(0)
									,date_year				INT
									,date_month_number		INT
									,date_month_year		INT
									,date_month_desc_short	CHAR(3)		COLLATE Latin1_General_100_BIN2_UTF8
									,date_month_desc_long	VARCHAR(15)	COLLATE Latin1_General_100_BIN2_UTF8
									,date_month_year_desc	VARCHAR(10)	COLLATE Latin1_General_100_BIN2_UTF8
									);

-- Generate a sequence of numbers to cover the minute range
WITH NumberSequence AS
(
SELECT		TOP (DATEDIFF(MINUTE, @min_datetime, @max_datetime) + 1)
			ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS n
FROM		dbo.bet_market_odds
)
INSERT INTO dbo.bet_trade_dates (bet_trade_date_id
								,bet_trade_date
								,date_year
								,date_month_number
								,date_month_year
								,date_month_desc_short
								,date_month_desc_long
								,date_month_year_desc
								)
SELECT		(CAST(YEAR(DATEADD(MINUTE, n, @min_datetime)) AS BIGINT) * 100000000) +
			(MONTH(DATEADD(MINUTE, n, @min_datetime)) * 1000000) +
			(DAY(DATEADD(MINUTE, n, @min_datetime)) * 10000) +
			(DATEPART(HOUR, DATEADD(MINUTE, n, @min_datetime)) * 100) +
			DATEPART(MINUTE, DATEADD(MINUTE, n, @min_datetime))																	AS bet_trade_date_id
			,DATEADD(MINUTE, n, @min_datetime)																					AS bet_trade_date
			,YEAR(DATEADD(MINUTE, n, @min_datetime))																			AS date_year
			,MONTH(DATEADD(MINUTE, n, @min_datetime))																			AS date_month_number
			,YEAR(DATEADD(MINUTE, n, @min_datetime)) * 100 + MONTH(DATEADD(MINUTE, n, @min_datetime))							AS date_month_year
			,FORMAT(DATEADD(MINUTE, n, @min_datetime), 'MMM')																	AS date_month_desc_short
			,FORMAT(DATEADD(MINUTE, n, @min_datetime), 'MMMM')																	AS date_month_desc_long
			,FORMAT(DATEADD(MINUTE, n, @min_datetime), 'MMM') + '-' + CAST(YEAR(DATEADD(MINUTE, n, @min_datetime)) AS CHAR(4))	AS date_month_year_desc
FROM		NumberSequence;

-------------------------------------------------------------------------------------------------
-- Create market_dates
-------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS dbo.market_dates;
CREATE TABLE dbo.market_dates (market_date_month_year			INT
								,market_date_month_year_desc	VARCHAR(15)	COLLATE Latin1_General_100_BIN2_UTF8
								);

INSERT INTO dbo.market_dates (market_date_month_year
								,market_date_month_year_desc
								)
SELECT		DISTINCT
			YEAR(market_time) * 100 + MONTH(market_time) AS market_date_month_year
			,FORMAT(market_time, 'MMM') + '-' + CAST(YEAR(market_time) AS CHAR(4))	AS market_date_month_year_desc
FROM		dbo.event_details
WHERE		event_id IN (SELECT event_id FROM dbo.event_details WHERE league_name NOT IN ('Lower leagues', 'Other Competitions'))

-------------------------------------------------------------------------------------------------
-- End processing
-------------------------------------------------------------------------------------------------

END