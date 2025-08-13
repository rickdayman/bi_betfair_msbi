CREATE PROCEDURE [dbo].[sp_back_test_loop_over_tests]
AS
BEGIN

SET NOCOUNT ON

-------------------------------------------------------------------------------------------------
-- Odds at start
-------------------------------------------------------------------------------------------------


DROP TABLE IF EXISTS dbo.test_betting_results;
CREATE TABLE dbo.test_betting_results (test_proc_name		VARCHAR(50)
										,bet_selection		VARCHAR(20)
										,after_x_mins		INT
										,league_name		VARCHAR(50)
										,odds_at_end		DECIMAL(6, 2)
										,profit_loss		DECIMAL(6, 2)
										,match_count		INT
										,win_count			INT
										,lose_count			INT
										)

DROP TABLE IF EXISTS #odds_at_end;

SELECT 1.03 AS odds_at_end
INTO #odds_at_end
UNION SELECT 1.04
UNION SELECT 1.05
UNION SELECT 1.06
UNION SELECT 1.07
UNION SELECT 1.08
UNION SELECT 1.09

UNION SELECT 1.10
UNION SELECT 1.11
UNION SELECT 1.12
UNION SELECT 1.13
UNION SELECT 1.14
UNION SELECT 1.15
UNION SELECT 1.16
UNION SELECT 1.17
UNION SELECT 1.18
UNION SELECT 1.19

UNION SELECT 1.20
UNION SELECT 1.21
UNION SELECT 1.22
UNION SELECT 1.23
UNION SELECT 1.24
UNION SELECT 1.25
UNION SELECT 1.26
UNION SELECT 1.27
UNION SELECT 1.28
UNION SELECT 1.29

UNION SELECT 1.30
UNION SELECT 1.31
UNION SELECT 1.32
UNION SELECT 1.33
UNION SELECT 1.34
UNION SELECT 1.35
UNION SELECT 1.36
UNION SELECT 1.37
UNION SELECT 1.38
UNION SELECT 1.39

UNION SELECT 1.40
UNION SELECT 1.41
UNION SELECT 1.42
UNION SELECT 1.43
UNION SELECT 1.44
UNION SELECT 1.45
UNION SELECT 1.46
UNION SELECT 1.47
UNION SELECT 1.48
UNION SELECT 1.49

UNION SELECT 1.50
UNION SELECT 1.51
UNION SELECT 1.52
UNION SELECT 1.53
UNION SELECT 1.54
UNION SELECT 1.55
UNION SELECT 1.56
UNION SELECT 1.57
UNION SELECT 1.58
UNION SELECT 1.59

UNION SELECT 1.60
UNION SELECT 1.61
UNION SELECT 1.62
UNION SELECT 1.63
UNION SELECT 1.64
UNION SELECT 1.65
UNION SELECT 1.66
UNION SELECT 1.67
UNION SELECT 1.68
UNION SELECT 1.69

UNION SELECT 1.70
UNION SELECT 1.71
UNION SELECT 1.72
UNION SELECT 1.73
UNION SELECT 1.74
UNION SELECT 1.75
UNION SELECT 1.76
UNION SELECT 1.77
UNION SELECT 1.78
UNION SELECT 1.79

--UNION SELECT 1.80
--UNION SELECT 1.81
--UNION SELECT 1.82
--UNION SELECT 1.83
--UNION SELECT 1.84
--UNION SELECT 1.85
--UNION SELECT 1.86
--UNION SELECT 1.87
--UNION SELECT 1.88
--UNION SELECT 1.89

--UNION SELECT 1.90
--UNION SELECT 1.91
--UNION SELECT 1.92
--UNION SELECT 1.93
--UNION SELECT 1.94
--UNION SELECT 1.95
--UNION SELECT 1.96
--UNION SELECT 1.97
--UNION SELECT 1.98
--UNION SELECT 1.99

--UNION SELECT 2.00
--UNION SELECT 2.01
--UNION SELECT 2.02
--UNION SELECT 2.03
--UNION SELECT 2.04
--UNION SELECT 2.05
--UNION SELECT 2.06
--UNION SELECT 2.07
--UNION SELECT 2.08
--UNION SELECT 2.09

--UNION SELECT 2.10
--UNION SELECT 2.11
--UNION SELECT 2.12
--UNION SELECT 2.13
--UNION SELECT 2.14
--UNION SELECT 2.15
--UNION SELECT 2.16
--UNION SELECT 2.17
--UNION SELECT 2.18
--UNION SELECT 2.19

--UNION SELECT 2.20
--UNION SELECT 2.21
--UNION SELECT 2.22
--UNION SELECT 2.23
--UNION SELECT 2.24
--UNION SELECT 2.25
--UNION SELECT 2.26
--UNION SELECT 2.27
--UNION SELECT 2.28
--UNION SELECT 2.29

DROP TABLE IF EXISTS #test_procs;
SELECT 'sp_back_test_draw_from_odds_value' AS test_procs
INTO #test_procs

DROP TABLE IF EXISTS #bet_selection;


--SELECT 'Away' AS bet_selection
--INTO #bet_selection


--SELECT 'Home' AS bet_selection
--INTO #bet_selection
--UNION SELECT 'The Draw'
--UNION SELECT 'Away'
----UNION SELECT 'Over 2.5 Goals'
--UNION SELECT 'Under 2.5 Goals'
----UNION SELECT 'Over 3.5 Goals'
--UNION SELECT 'Under 3.5 Goals'
----UNION SELECT 'Over 4.5 Goals'
--UNION SELECT 'Under 4.5 Goals'


--DROP TABLE IF EXISTS #after_x_mins;
--SELECT 70 AS after_x_mins
--INTO #after_x_mins
--UNION SELECT 65
--UNION SELECT 60
--UNION SELECT 75
--UNION SELECT 80
--UNION SELECT 85

----------------------------------------------------------------------------------------
-- best markets
----------------------------------------------------------------------------------------

-- Best markets
SELECT 'The Draw' AS bet_selection
INTO #bet_selection
UNION SELECT 'Under 2.5 Goals'
UNION SELECT 'Under 3.5 Goals'
-- Try others
UNION SELECT 'Home'
UNION SELECT 'Away'
UNION SELECT 'Under 4.5 Goals'

DROP TABLE IF EXISTS #after_x_mins;
SELECT 85 AS after_x_mins
INTO #after_x_mins





----------------------------------------------------------------------------------------
-- Loop over combos
----------------------------------------------------------------------------------------

DECLARE @loop_odds_at_end		VARCHAR(5)
DECLARE @loop_bet_selection		VARCHAR(20)
DECLARE @loop_test_procs		VARCHAR(50)
DECLARE @loop_after_x_mins		VARCHAR(50)
DECLARE @exec_sql				VARCHAR(1000)


DECLARE db_cursor CURSOR FOR	SELECT		test_procs
											,bet_selection
											,odds_at_end
											,after_x_mins
								FROM		#odds_at_end
											CROSS JOIN
											#bet_selection
											CROSS JOIN
											#test_procs
											CROSS JOIN
											#after_x_mins



OPEN db_cursor  
FETCH NEXT FROM db_cursor INTO @loop_test_procs
								,@loop_bet_selection
								,@loop_odds_at_end
								,@loop_after_x_mins

WHILE @@FETCH_STATUS = 0  
BEGIN  

	--PRINT(@loop_test_procs)

	SET @exec_sql = 'INSERT INTO dbo.test_betting_results (test_proc_name
															,bet_selection
															,after_x_mins
															,league_name
															,odds_at_end
															,profit_loss
															,match_count
															,win_count
															,lose_count
															)
						EXEC dbo.' + @loop_test_procs + ' @odds_at_end = ' + @loop_odds_at_end  + ', @bet_selection = ''' + @loop_bet_selection + ''', @after_x_mins = ' + @loop_after_x_mins

	--PRINT(@exec_sql)
	EXEC(@exec_sql)

	FETCH NEXT FROM db_cursor INTO @loop_test_procs
									,@loop_bet_selection
									,@loop_odds_at_end 
									,@loop_after_x_mins
END 

CLOSE db_cursor  
DEALLOCATE db_cursor





SELECT		*
			,CAST(profit_loss / match_count AS DECIMAL(4, 2)) AS win_per_bet
FROM		dbo.test_betting_results


/*
SELECT		bet_selection
			,odds_at_end
			,after_x_mins
			,SUM(profit_loss)	AS profit_loss
			,SUM(match_count)	AS match_count
			,SUM(win_count)		AS win_count
			,CAST(SUM(win_count * 1.0) / SUM(match_count) AS DECIMAL(3, 2))		AS win_percent
			,COUNT(league_name)													AS league_count
			,SUM(CASE WHEN profit_loss > 0 THEN 1 ELSE 0 END)					AS league_win_count
FROM		dbo.test_betting_results

--WHERE		bet_selection = 'Home'
WHERE		bet_selection = 'Under 4.5 Goals'

GROUP BY	bet_selection
			,odds_at_end
			,after_x_mins
ORDER BY	bet_selection
			,odds_at_end


SELECT		odds_at_end
			,[Home]
			,[The Draw]
			,[Away]
			,[Under 2.5 Goals]
			--,[Over 2.5 Goals]
			,[Under 3.5 Goals]
			--,[Over 3.5 Goals]
			,[Under 4.5 Goals]
			--,[Over 4.5 Goals]
FROM		(
			SELECT		bet_selection
						,odds_at_end
						,profit_loss
			FROM		dbo.test_betting_results
			) AS tbl
			PIVOT
			(
			SUM(profit_loss)
			FOR bet_selection IN ([Home], [The Draw], [Away], [Under 2.5 Goals], [Over 2.5 Goals], [Under 3.5 Goals], [Over 3.5 Goals], [Under 4.5 Goals], [Over 4.5 Goals])
			) AS piv
ORDER BY	odds_at_end
*/

-- Strategy
-- After 85 min, wait for Draw to 1.09
-- After 85 min, wait for Under 4.5 goals to 1.45
-- After 85 min, wait for Under 3.5 goals to 1.45
-- After 85 min, wait for Under 2.5 goals to 1.45

/*
EXEC [dbo].[sp_back_test_draw_from_odds_value] @odds_at_end = 1.09, @bet_selection = 'The Draw', @after_x_mins = 85
EXEC [dbo].[sp_back_test_draw_from_odds_value] @odds_at_end = 1.45, @bet_selection = 'Under 4.5 Goals', @after_x_mins = 85
EXEC [dbo].[sp_back_test_draw_from_odds_value] @odds_at_end = 1.45, @bet_selection = 'Under 3.5 Goals', @after_x_mins = 85
EXEC [dbo].[sp_back_test_draw_from_odds_value] @odds_at_end = 1.45, @bet_selection = 'Under 2.5 Goals', @after_x_mins = 85
*/


-------------------------------------------------------------------------------------------------
-- End processing
-------------------------------------------------------------------------------------------------

END