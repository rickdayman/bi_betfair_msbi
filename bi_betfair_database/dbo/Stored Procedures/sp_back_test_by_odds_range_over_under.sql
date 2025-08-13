CREATE PROCEDURE [dbo].[sp_back_test_by_odds_range_over_under]
AS
BEGIN

SET NOCOUNT ON

-------------------------------------------------------------------------------------------------
-- Create odds table with specified hours before
-------------------------------------------------------------------------------------------------

--EXEC dbo.sp_build_bet_market_odds_drift_pre_kickoff @drift_percent
EXEC dbo.sp_build_market_odds_hour_before_game @hours_before = 8
EXEC dbo.sp_build_event_odds

-------------------------------------------------------------------------------------------------
-- Processing
-------------------------------------------------------------------------------------------------

DECLARE @bet_amount DECIMAL(5, 2)
SET		@bet_amount = 10.00

DECLARE @commission DECIMAL(5, 2)
SET		@commission = 5.0
SET		@commission = (100.0 - @commission) / 100.0


DROP TABLE IF EXISTS #over_under_45
DROP TABLE IF EXISTS #over_under_35
DROP TABLE IF EXISTS #over_under_25


SELECT odd.[event_id]
      ,odd.[event_name]
      ,odd.[home_team]
      ,odd.[away_team]
      ,odd.[market_time]
	  ,evt.league_name
	  ,odd.Home
	  ,odd.Draw
	  ,odd.Away

      ,[over_under_45_winner]
      ,[under_45_goals]
      ,[over_45_goals]
      ,[under_45_goals_lay]

			,CASE
				WHEN [over_under_45_winner] = 'Under 4.5 Goals'
				THEN CAST(((@bet_amount * [under_45_goals]) - @bet_amount) * @commission AS DECIMAL(7, 2))
				ELSE -1 * @bet_amount
			END AS bet_under_45_goals_profit_loss
			,CASE
				WHEN [over_under_45_winner] = 'Over 4.5 Goals'
				THEN CAST(((@bet_amount * [over_45_goals]) - @bet_amount) * @commission AS DECIMAL(7, 2))
				ELSE -1 * @bet_amount
			END AS bet_over_45_goals_profit_loss
INTO	#over_under_45

  FROM [FOOTBALL].[dbo].[event_odds] odd
		INNER JOIN
		[dbo].[event_details]		evt
		ON odd.event_id = evt.event_id

  WHERE	[under_45_goals] IS NOT NULL
  AND [over_45_goals] IS NOT NULL




  

SELECT odd.[event_id]
      ,odd.[event_name]
      ,odd.[home_team]
      ,odd.[away_team]
      ,odd.[market_time]
	  ,evt.league_name
	  ,odd.Home
	  ,odd.Draw
	  ,odd.Away

      ,[over_under_25_winner]
      ,[under_25_goals]
      ,[over_25_goals]
      ,[under_25_goals_lay]

			,CASE
				WHEN [over_under_25_winner] = 'Under 2.5 Goals'
				THEN CAST(((@bet_amount * [under_25_goals]) - @bet_amount) * @commission AS DECIMAL(7, 2))
				ELSE -1 * @bet_amount
			END AS bet_under_25_goals_profit_loss
			,CASE
				WHEN [over_under_25_winner] = 'Over 2.5 Goals'
				THEN CAST(((@bet_amount * [over_25_goals]) - @bet_amount) * @commission AS DECIMAL(7, 2))
				ELSE -1 * @bet_amount
			END AS bet_over_25_goals_profit_loss
INTO	#over_under_25

  FROM [FOOTBALL].[dbo].[event_odds] odd
		INNER JOIN
		[dbo].[event_details]		evt
		ON odd.event_id = evt.event_id

  WHERE	[under_25_goals] IS NOT NULL
  AND [over_25_goals] IS NOT NULL


  
SELECT odd.[event_id]
      ,odd.[event_name]
      ,odd.[home_team]
      ,odd.[away_team]
      ,odd.[market_time]
	  ,evt.league_name
	  ,odd.Home
	  ,odd.Draw
	  ,odd.Away
      ,[over_under_35_winner]
      ,[under_35_goals]
      ,[over_35_goals]
      ,[under_35_goals_lay]

			,CASE
				WHEN [over_under_35_winner] = 'Under 3.5 Goals'
				THEN CAST(((@bet_amount * [under_35_goals]) - @bet_amount) * @commission AS DECIMAL(7, 2))
				ELSE -1 * @bet_amount
			END AS bet_under_35_goals_profit_loss
			,CASE
				WHEN [over_under_35_winner] = 'Over 3.5 Goals'
				THEN CAST(((@bet_amount * [over_35_goals]) - @bet_amount) * @commission AS DECIMAL(7, 2))
				ELSE -1 * @bet_amount
			END AS bet_over_35_goals_profit_loss
INTO	#over_under_35

  FROM [FOOTBALL].[dbo].[event_odds] odd
		INNER JOIN
		[dbo].[event_details]		evt
		ON odd.event_id = evt.event_id

  WHERE	[under_35_goals] IS NOT NULL
  AND [over_35_goals] IS NOT NULL


--------------------------------------------------------------------------------
-- 2.5 goals
--------------------------------------------------------------------------------

--SELECT		[under_25_goals]
--			,COUNT(*) AS bet_count
--			,SUM(bet_under_25_goals_profit_loss) AS bet_under_25_goals_profit_loss
--FROM		#over_under_25
----WHERE		[under_25_goals] BETWEEN 1.6 AND 1.8 
--GROUP BY	[under_25_goals]
--ORDER BY	[under_25_goals]


--SELECT		SUM(bet_under_25_goals_profit_loss) AS bet_under_25_goals_profit_loss
--FROM		#over_under_25
--WHERE		[under_25_goals] BETWEEN 1.6 AND 1.8 



--SELECT		[over_25_goals]
--			,SUM(bet_over_25_goals_profit_loss) AS bet_over_25_goals_profit_loss
--FROM		#over_under_25
----WHERE		[over_25_goals] BETWEEN 4.9 AND 6.2
--GROUP BY	[over_25_goals]
--ORDER BY	[over_25_goals]


----------------------------------------------------------------------------------
---- 3.5 goals
----------------------------------------------------------------------------------

--SELECT		[under_35_goals]
--			,SUM(bet_under_35_goals_profit_loss) AS bet_under_35_goals_profit_loss
--FROM		#over_under_35

--GROUP BY	[under_35_goals]
--ORDER BY	[under_35_goals]


--SELECT		SUM(bet_under_35_goals_profit_loss) AS bet_under_35_goals_profit_loss
--FROM		#over_under_35




--SELECT		[over_35_goals]
--			,SUM(bet_over_35_goals_profit_loss) AS bet_over_35_goals_profit_loss
--FROM		#over_under_35

--GROUP BY	[over_35_goals]
--ORDER BY	[over_35_goals]

--SELECT		SUM(bet_over_35_goals_profit_loss) AS bet_over_35_goals_profit_loss
--FROM		#over_under_35


--------------------------------------------------------------------------------
-- 4.5 goals
--------------------------------------------------------------------------------

--SELECT		[under_45_goals]
--			,SUM(bet_under_45_goals_profit_loss) AS bet_under_45_goals_profit_loss
--FROM		#over_under_45
--GROUP BY	[under_45_goals]
--ORDER BY	[under_45_goals]

--SELECT		SUM(bet_under_45_goals_profit_loss) AS bet_under_45_goals_profit_loss
--FROM		#over_under_45


--SELECT		[over_45_goals]
--			,SUM(bet_over_45_goals_profit_loss) AS bet_over_45_goals_profit_loss
--FROM		#over_under_45
--WHERE		[over_45_goals] BETWEEN 4.9 AND 6.2
--GROUP BY	[over_45_goals]
--ORDER BY	[over_45_goals]


SELECT		SUM(bet_over_45_goals_profit_loss) AS bet_over_45_goals_profit_loss
			,SUM(CASE WHEN bet_over_45_goals_profit_loss > 0 THEN 1 ELSE 0 END)		AS win_count
			,SUM(CASE WHEN bet_over_45_goals_profit_loss <= 0 THEN 1 ELSE 0 END)	AS lose_count
			,COUNT(*)																AS bet_count
FROM		#over_under_45
--WHERE		[over_45_goals] BETWEEN 4.9 AND 6.2
WHERE		[over_45_goals] BETWEEN 4.0 AND 6.0
AND			[Home] BETWEEN 1.55 AND 1.95

SELECT		league_name
			,SUM(bet_over_45_goals_profit_loss) AS bet_over_45_goals_profit_loss
			,SUM(CASE WHEN bet_over_45_goals_profit_loss > 0 THEN 1 ELSE 0 END)		AS win_count
			,SUM(CASE WHEN bet_over_45_goals_profit_loss <= 0 THEN 1 ELSE 0 END)	AS lose_count
			,COUNT(*)																AS bet_count
FROM		#over_under_45
--WHERE		[over_45_goals] BETWEEN 4.9 AND 6.2
WHERE		[over_45_goals] BETWEEN 4.0 AND 6.0
AND			[Home] BETWEEN 1.55 AND 1.95
GROUP BY	league_name



--SELECT		market_time
--			,SUM(bet_over_45_goals_profit_loss) AS bet_over_45_goals_profit_loss
--			,SUM(CASE WHEN bet_over_45_goals_profit_loss > 0 THEN 1 ELSE 0 END)		AS win_count
--			,SUM(CASE WHEN bet_over_45_goals_profit_loss <= 0 THEN 1 ELSE 0 END)	AS lose_count
--			,COUNT(*)																AS bet_count
--FROM		#over_under_45
----WHERE		[over_45_goals] BETWEEN 4.9 AND 6.2
--WHERE		[over_45_goals] BETWEEN 4.0 AND 6.0
--AND			[Home] BETWEEN 1.55 AND 1.95
--GROUP BY	market_time
--ORDER BY	market_time


-- ###########################################################################
-- ###########################################################################
-- High odds only bet $1 or 1% (can lose 10+ times in a row)
-- If Home odds between 1.55 AND 1.95
-- Bet on Over 4.5 goals between 4.0 AND 6.0
-- ###########################################################################
-- ###########################################################################


--SELECT		[Home]
--			,SUM(bet_over_45_goals_profit_loss) AS bet_over_45_goals_profit_loss
--FROM		#over_under_45


--WHERE		[over_45_goals] BETWEEN 4.0 AND 6.0

--AND			[Home] BETWEEN 1.55 AND 1.95

--GROUP BY	[Home]
--ORDER BY	[Home]

-------------------------------------------------------------------------------------------------
-- End processing
-------------------------------------------------------------------------------------------------

END