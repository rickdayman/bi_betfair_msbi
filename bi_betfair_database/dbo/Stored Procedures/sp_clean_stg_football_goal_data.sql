CREATE PROCEDURE [dbo].[sp_clean_stg_football_goal_data]
AS
BEGIN

SET NOCOUNT ON

-------------------------------------------------------------------------------------------------
-- stage date and clean date and data types
-------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #stg_football_goal_data

SELECT		DENSE_RANK() OVER (ORDER BY [date], game)	AS game_id
			,game					COLLATE Latin1_General_100_BIN2_UTF8 AS event_name
			,[date]					AS game_date
			,season					COLLATE Latin1_General_100_BIN2_UTF8 AS game_season
			,CASE
				WHEN league_name = 'C:\bi_projects\bi_data\football-goal-times\bundesliga.csv'				THEN 'German Bundesliga'
				WHEN league_name = 'C:\bi_projects\bi_data\football-goal-times\esp-primera-division.csv'	THEN 'Spanish La Liga'
				WHEN league_name = 'C:\bi_projects\bi_data\football-goal-times\fra-ligue-1.csv'				THEN 'French Ligue 1'
				WHEN league_name = 'C:\bi_projects\bi_data\football-goal-times\eng-premier-league.csv'		THEN 'English Premier League'
				WHEN league_name = 'C:\bi_projects\bi_data\football-goal-times\ita-serie-a.csv'				THEN 'Italian Serie A'
			END COLLATE Latin1_General_100_BIN2_UTF8 AS league_name
			,GH	AS running_home_goals
			,GA	AS running_away_goals
			,CASE
				WHEN [time] LIKE '45+%'		THEN 45
				WHEN [time] LIKE '90+%'		THEN 90
				WHEN [time] NOT LIKE '45+%'
				AND [time] NOT LIKE '90+%'
				AND [time] LIKE '%+%'		THEN CAST(SUBSTRING([time], 1, CHARINDEX('+', [time]) - 1) AS INT)
				WHEN [time] IN ('91', '92', '93', '94', '95')
				THEN 90
				ELSE CAST([time] AS INT)
			END AS goal_time
			,CASE 
				WHEN [game] LIKE '% vs. %[0-9]%:[0-9]%' 
				THEN TRIM(SUBSTRING([game], 1, CHARINDEX(' vs. ', [game]) - 1)) 
				ELSE NULL 
			END COLLATE Latin1_General_100_BIN2_UTF8 AS home_team
			,CASE 
				WHEN [game] LIKE '% vs. %[0-9]%:[0-9]%' 
				THEN TRIM(SUBSTRING([game], 
									CHARINDEX(' vs. ', [game]) + 5, 
									LEN([game]) - CHARINDEX(' ', REVERSE([game])) + 1 - CHARINDEX(' vs. ', [game]) - 5)) 
				ELSE NULL 
			END COLLATE Latin1_General_100_BIN2_UTF8 AS away_team
			,TRIM(SUBSTRING([game], PATINDEX('%:[0-9]%', [game]) - 2, 5)) COLLATE Latin1_General_100_BIN2_UTF8 AS game_score
			,gls.home_score
			,gls.away_score
			,CAST(gls.home_score AS VARCHAR(2)) + ':' + CAST(gls.away_score AS VARCHAR(2)) COLLATE Latin1_General_100_BIN2_UTF8 AS derived_score
INTO		#stg_football_goal_data
FROM		stg.football_goal_data			dat
			INNER JOIN
			(
			SELECT		game			AS max_game
						,MAX(GH)		AS home_score
						,MAX(GA)		AS away_score
			FROM		stg.football_goal_data
			GROUP BY	game
			) gls
			ON dat.game = gls.max_game
WHERE		season >= '1990-1991'









---------------------------------------------------------------------------------------------------
---- Align team names with betfair data
---------------------------------------------------------------------------------------------------

--UPDATE #stg_football_data SET home_team = 'AC Milan'	WHERE home_team = 'Milan'
--UPDATE #stg_football_data SET home_team = 'AC Monza'	WHERE home_team = 'Monza'
--UPDATE #stg_football_data SET home_team = 'Athletic Bilbao'	WHERE home_team = 'Ath Bilbao'
--UPDATE #stg_football_data SET home_team = 'Atletico Madrid'	WHERE home_team = 'Ath Madrid'
--UPDATE #stg_football_data SET home_team = 'Bristol Rovers'	WHERE home_team = 'Bristol Rvs'
--UPDATE #stg_football_data SET home_team = 'Burton Albion'	WHERE home_team = 'Burton'
--UPDATE #stg_football_data SET home_team = 'Cambridge Utd'	WHERE home_team = 'Cambridge'
--UPDATE #stg_football_data SET home_team = 'Celta Vigo'	WHERE home_team = 'Celta'
--UPDATE #stg_football_data SET home_team = 'Eintracht Frankfurt'	WHERE home_team = 'Ein Frankfurt'
--UPDATE #stg_football_data SET home_team = 'Espanyol'	WHERE home_team = 'Espanol'
--UPDATE #stg_football_data SET home_team = 'FC Heidenheim'	WHERE home_team = 'Heidenheim'
--UPDATE #stg_football_data SET home_team = 'Man Utd'	WHERE home_team = 'Man United'
--UPDATE #stg_football_data SET home_team = 'Mgladbach'	WHERE home_team = 'M''gladbach'
--UPDATE #stg_football_data SET home_team = 'Nottm Forest'	WHERE home_team = 'Nott''m Forest'
--UPDATE #stg_football_data SET home_team = 'Oxford Utd'	WHERE home_team = 'Oxford'
--UPDATE #stg_football_data SET home_team = 'Paris St-G'	WHERE home_team = 'Paris SG'
--UPDATE #stg_football_data SET home_team = 'Peterborough'	WHERE home_team = 'Peterboro'
--UPDATE #stg_football_data SET home_team = 'Rayo Vallecano'	WHERE home_team = 'Vallecano'
--UPDATE #stg_football_data SET home_team = 'Real Sociedad'	WHERE home_team = 'Sociedad'
--UPDATE #stg_football_data SET home_team = 'Sheff Utd'	WHERE home_team = 'Sheffield United'
--UPDATE #stg_football_data SET home_team = 'Sheff Wed'	WHERE home_team = 'Sheffield Weds'

--UPDATE #stg_football_data SET away_team = 'AC Milan'	WHERE away_team = 'Milan'
--UPDATE #stg_football_data SET away_team = 'AC Monza'	WHERE away_team = 'Monza'
--UPDATE #stg_football_data SET away_team = 'Athletic Bilbao'	WHERE away_team = 'Ath Bilbao'
--UPDATE #stg_football_data SET away_team = 'Atletico Madrid'	WHERE away_team = 'Ath Madrid'
--UPDATE #stg_football_data SET away_team = 'Bristol Rovers'	WHERE away_team = 'Bristol Rvs'
--UPDATE #stg_football_data SET away_team = 'Burton Albion'	WHERE away_team = 'Burton'
--UPDATE #stg_football_data SET away_team = 'Cambridge Utd'	WHERE away_team = 'Cambridge'
--UPDATE #stg_football_data SET away_team = 'Celta Vigo'	WHERE away_team = 'Celta'
--UPDATE #stg_football_data SET away_team = 'Eintracht Frankfurt'	WHERE away_team = 'Ein Frankfurt'
--UPDATE #stg_football_data SET away_team = 'Espanyol'	WHERE away_team = 'Espanol'
--UPDATE #stg_football_data SET away_team = 'FC Heidenheim'	WHERE away_team = 'Heidenheim'
--UPDATE #stg_football_data SET away_team = 'Man Utd'	WHERE away_team = 'Man United'
--UPDATE #stg_football_data SET away_team = 'Mgladbach'	WHERE away_team = 'M''gladbach'
--UPDATE #stg_football_data SET away_team = 'Nottm Forest'	WHERE away_team = 'Nott''m Forest'
--UPDATE #stg_football_data SET away_team = 'Oxford Utd'	WHERE away_team = 'Oxford'
--UPDATE #stg_football_data SET away_team = 'Paris St-G'	WHERE away_team = 'Paris SG'
--UPDATE #stg_football_data SET away_team = 'Peterborough'	WHERE away_team = 'Peterboro'
--UPDATE #stg_football_data SET away_team = 'Rayo Vallecano'	WHERE away_team = 'Vallecano'
--UPDATE #stg_football_data SET away_team = 'Real Sociedad'	WHERE away_team = 'Sociedad'
--UPDATE #stg_football_data SET away_team = 'Sheff Utd'	WHERE away_team = 'Sheffield United'
--UPDATE #stg_football_data SET away_team = 'Sheff Wed'	WHERE away_team = 'Sheffield Weds'


--UPDATE #stg_football_data SET away_team = 'SV Darmstadt'	WHERE away_team = 'Darmstadt'
--UPDATE #stg_football_data SET away_team = 'Hamburger SV'	WHERE away_team = 'Hamburg'
--UPDATE #stg_football_data SET away_team = 'Hertha Berlin'	WHERE away_team = 'Hertha'
--UPDATE #stg_football_data SET away_team = 'FC Magdeburg'	WHERE away_team = 'Magdeburg'
--UPDATE #stg_football_data SET away_team = 'VfL Osnabruck'	WHERE away_team = 'Osnabruck'
--UPDATE #stg_football_data SET away_team = 'Preussen Munster'	WHERE away_team = 'PreuÃŸen MÃ¼nster'
--UPDATE #stg_football_data SET away_team = 'Jahn Regensburg'	WHERE away_team = 'Regensburg'
--UPDATE #stg_football_data SET away_team = 'SSV Ulm'	WHERE away_team = 'Ulm'
--UPDATE #stg_football_data SET away_team = 'Wehen Wiesbaden'	WHERE away_team = 'Wehen'
--UPDATE #stg_football_data SET away_team = 'AC Ajaccio'	WHERE away_team = 'Ajaccio'
--UPDATE #stg_football_data SET away_team = 'Pau'	WHERE away_team = 'Pau FC'
--UPDATE #stg_football_data SET away_team = 'ESTAC Troyes'	WHERE away_team = 'Troyes'
--UPDATE #stg_football_data SET away_team = 'SSD Bari'	WHERE away_team = 'Bari'
--UPDATE #stg_football_data SET away_team = 'US Cremonese'	WHERE away_team = 'Cremonese'
--UPDATE #stg_football_data SET away_team = 'Feralpisalo'	WHERE away_team = 'FeralpiSalo'
--UPDATE #stg_football_data SET away_team = 'Dundee Utd'	WHERE away_team = 'Dundee United'
--UPDATE #stg_football_data SET away_team = 'Ross Co'	WHERE away_team = 'Ross County'
--UPDATE #stg_football_data SET away_team = 'Andorra CF'	WHERE away_team = 'Andorra'
--UPDATE #stg_football_data SET away_team = 'FC Cartagena'	WHERE away_team = 'Cartagena'
--UPDATE #stg_football_data SET away_team = 'CD Castellon'	WHERE away_team = 'Castellon'
--UPDATE #stg_football_data SET away_team = 'Racing de Ferrol'	WHERE away_team = 'Ferrol'
--UPDATE #stg_football_data SET away_team = 'Deportivo'	WHERE away_team = 'La Coruna'
--UPDATE #stg_football_data SET away_team = 'Racing Santander'	WHERE away_team = 'Santander'
--UPDATE #stg_football_data SET away_team = 'Sporting Gijon'	WHERE away_team = 'Sp Gijon'

--UPDATE #stg_football_data SET home_team = 'SV Darmstadt'	WHERE home_team = 'Darmstadt'
--UPDATE #stg_football_data SET home_team = 'Hamburger SV'	WHERE home_team = 'Hamburg'
--UPDATE #stg_football_data SET home_team = 'Hertha Berlin'	WHERE home_team = 'Hertha'
--UPDATE #stg_football_data SET home_team = 'FC Magdeburg'	WHERE home_team = 'Magdeburg'
--UPDATE #stg_football_data SET home_team = 'VfL Osnabruck'	WHERE home_team = 'Osnabruck'
--UPDATE #stg_football_data SET home_team = 'Preussen Munster'	WHERE home_team = 'PreuÃŸen MÃ¼nster'
--UPDATE #stg_football_data SET home_team = 'Jahn Regensburg'	WHERE home_team = 'Regensburg'
--UPDATE #stg_football_data SET home_team = 'SSV Ulm'	WHERE home_team = 'Ulm'
--UPDATE #stg_football_data SET home_team = 'Wehen Wiesbaden'	WHERE home_team = 'Wehen'
--UPDATE #stg_football_data SET home_team = 'AC Ajaccio'	WHERE home_team = 'Ajaccio'
--UPDATE #stg_football_data SET home_team = 'Pau'	WHERE home_team = 'Pau FC'
--UPDATE #stg_football_data SET home_team = 'ESTAC Troyes'	WHERE home_team = 'Troyes'
--UPDATE #stg_football_data SET home_team = 'SSD Bari'	WHERE home_team = 'Bari'
--UPDATE #stg_football_data SET home_team = 'US Cremonese'	WHERE home_team = 'Cremonese'
--UPDATE #stg_football_data SET home_team = 'Feralpisalo'	WHERE home_team = 'FeralpiSalo'
--UPDATE #stg_football_data SET home_team = 'Dundee Utd'	WHERE home_team = 'Dundee United'
--UPDATE #stg_football_data SET home_team = 'Ross Co'	WHERE home_team = 'Ross County'
--UPDATE #stg_football_data SET home_team = 'Andorra CF'	WHERE home_team = 'Andorra'
--UPDATE #stg_football_data SET home_team = 'FC Cartagena'	WHERE home_team = 'Cartagena'
--UPDATE #stg_football_data SET home_team = 'CD Castellon'	WHERE home_team = 'Castellon'
--UPDATE #stg_football_data SET home_team = 'Racing de Ferrol'	WHERE home_team = 'Ferrol'
--UPDATE #stg_football_data SET home_team = 'Deportivo'	WHERE home_team = 'La Coruna'
--UPDATE #stg_football_data SET home_team = 'Racing Santander'	WHERE home_team = 'Santander'
--UPDATE #stg_football_data SET home_team = 'Sporting Gijon'	WHERE home_team = 'Sp Gijon'


DROP TABLE IF EXISTS dbo.football_goal_times




SELECT		game_id
			,event_name
			,game_date
			,game_season
			,league_name
			,running_home_goals
			,running_away_goals
			,goal_time
			,home_team
			,away_team
			,game_score
			,home_score
			,away_score
			,derived_score
INTO		dbo.football_goal_times
FROM		#stg_football_goal_data


-------------------------------------------------------------------------------------------------
-- End processing
-------------------------------------------------------------------------------------------------

END