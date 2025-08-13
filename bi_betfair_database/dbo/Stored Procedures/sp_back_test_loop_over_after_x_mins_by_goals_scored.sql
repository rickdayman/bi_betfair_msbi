CREATE PROCEDURE [dbo].[sp_back_test_loop_over_after_x_mins_by_goals_scored]
AS
BEGIN

SET NOCOUNT ON

-------------------------------------------------------------------------------------------------
-- Odds at start
-------------------------------------------------------------------------------------------------


DROP TABLE IF EXISTS dbo.back_test_loop_over_after_x_mins_by_goals_scored;
CREATE TABLE dbo.back_test_loop_over_after_x_mins_by_goals_scored (test_proc_name		VARCHAR(50)
																	,bet_selection		VARCHAR(20)
																	,after_x_mins		INT
																	,goals_at_x_mins	INT
																	,profit_loss		NUMERIC(8, 2)
																	,match_count		INT
																	,win_count			INT
																	,lose_count			INT
																	,profit_per_game	NUMERIC(8, 2)
																	)




DROP TABLE IF EXISTS #test_procs;
SELECT 'sp_back_test_after_x_mins_by_goals_scored' AS test_procs
INTO #test_procs

DROP TABLE IF EXISTS #bet_selection;
SELECT 'Under 0.5 Goals' AS bet_selection
INTO #bet_selection
UNION SELECT 'Under 1.5 Goals'
UNION SELECT 'Under 2.5 Goals'
UNION SELECT 'Under 3.5 Goals'
UNION SELECT 'Under 4.5 Goals'

DROP TABLE IF EXISTS #after_x_mins;
SELECT 70 AS after_x_mins
INTO #after_x_mins
UNION SELECT 65
UNION SELECT 60
UNION SELECT 75
UNION SELECT 80
UNION SELECT 85

UNION SELECT 0
UNION SELECT 5
UNION SELECT 10
UNION SELECT 15
UNION SELECT 20
UNION SELECT 25
UNION SELECT 35
UNION SELECT 40
UNION SELECT 45



----------------------------------------------------------------------------------------
-- Loop over combos
----------------------------------------------------------------------------------------

DECLARE @loop_bet_selection		VARCHAR(20)
DECLARE @loop_test_procs		VARCHAR(50)
DECLARE @loop_after_x_mins		VARCHAR(50)
DECLARE @exec_sql				VARCHAR(1000)


DECLARE db_cursor CURSOR FOR	SELECT		test_procs
											,bet_selection
											,after_x_mins
								FROM		#bet_selection
											CROSS JOIN
											#test_procs
											CROSS JOIN
											#after_x_mins



OPEN db_cursor  
FETCH NEXT FROM db_cursor INTO @loop_test_procs
								,@loop_bet_selection
								,@loop_after_x_mins

WHILE @@FETCH_STATUS = 0  
BEGIN  

	--PRINT(@loop_test_procs)

	SET @exec_sql = 'INSERT INTO dbo.back_test_loop_over_after_x_mins_by_goals_scored (test_proc_name
																						,bet_selection
																						,after_x_mins
																						,goals_at_x_mins
																						,profit_loss
																						,match_count
																						,win_count
																						,lose_count
																						,profit_per_game
																						)
						EXEC dbo.' + @loop_test_procs + ' @bet_selection = ''' + @loop_bet_selection + ''', @after_x_mins = ' + @loop_after_x_mins

	--PRINT(@exec_sql)
	EXEC(@exec_sql)

	FETCH NEXT FROM db_cursor INTO @loop_test_procs
									,@loop_bet_selection
									,@loop_after_x_mins
END 

CLOSE db_cursor  
DEALLOCATE db_cursor


-- https://github.com/schochastics/football-data


SELECT		*
FROM		dbo.back_test_loop_over_after_x_mins_by_goals_scored
WHERE		bet_selection IN ('Under 4.5 Goals')
--AND			goals_at_x_mins = 4
ORDER BY	profit_per_game DESC

SELECT		bet_selection
			,after_x_mins
			,SUM(profit_loss)	AS profit_loss
			,SUM(match_count)	AS match_count
			,SUM(win_count)		AS win_count
			,SUM(lose_count)	AS lose_count
			,SUM(profit_loss) / (SUM(match_count))	AS proft_per_bet
FROM		dbo.back_test_loop_over_after_x_mins_by_goals_scored
WHERE		bet_selection IN ('Under 4.5 Goals')
GROUP BY	bet_selection
			,after_x_mins
ORDER BY	proft_per_bet DESC



-------------------------------------------------------------------------------------------------
-- End processing
-------------------------------------------------------------------------------------------------

END