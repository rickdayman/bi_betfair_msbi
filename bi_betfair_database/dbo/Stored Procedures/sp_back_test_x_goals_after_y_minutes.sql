CREATE PROCEDURE [dbo].[sp_back_test_x_goals_after_y_minutes] (@x_goals				SMALLINT = 3
																,@before_y_minutes	SMALLINT = 35
																)
AS
BEGIN

SET NOCOUNT ON

-------------------------------------------------------------------------------------------------
-- find games with x goals before y minutes
-------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #games_with_x_goals_before_y_minutes

SELECT		game_id
			,SUM(CASE WHEN goal_time <= @before_y_minutes THEN 1 ELSE 0 END) AS goals_before
			,SUM(CASE WHEN goal_time > @before_y_minutes THEN 1 ELSE 0 END) AS goals_after
INTO		#games_with_x_goals_before_y_minutes
FROM		dbo.football_goal_times

WHERE		game_date >= '2023-07-01'

GROUP BY	game_id
HAVING		SUM(CASE WHEN goal_time <= @before_y_minutes THEN 1 ELSE 0 END) = @x_goals

-------------------------------------------------------------------------------------------------
-- total goals at end
-------------------------------------------------------------------------------------------------

;WITH GOALFREQ AS
(
SELECT		goals_before
			,goals_after
			,SUM(1.0) AS freq
FROM		#games_with_x_goals_before_y_minutes
GROUP BY	goals_before
			,goals_after
)
SELECT		goals_before
			,goals_after
			,freq
			,SUM(freq) OVER (ORDER BY (SELECT NULL)) AS total_games
FROM		GOALFREQ
ORDER BY	goals_before
			,goals_after


SELECT		fgt.game_id
			,fgt.event_name
			,fgt.game_date
			,COUNT(*) AS goals

FROM		dbo.football_goal_times					fgt
			INNER JOIN
			#games_with_x_goals_before_y_minutes	gxy
			ON fgt.game_id = gxy.game_id
GROUP BY	fgt.game_id
			,fgt.event_name
			,fgt.game_date
ORDER BY	event_name

-------------------------------------------------------------------------------------------------
-- End processing
-------------------------------------------------------------------------------------------------

END