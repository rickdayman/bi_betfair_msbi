CREATE PROCEDURE [dbo].[sp_clean_stg_football_data]
AS
BEGIN

SET NOCOUNT ON

-------------------------------------------------------------------------------------------------
-- stage date and clean date and data types
-------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #stg_football_data

SELECT		league_code
			,game_date 
			,game_time
			,home_team
			,away_team
			,full_time_home_goals
			,full_time_away_goals
			,full_time_result
			,half_time_home_goals
			,half_time_away_goals
			,half_time_result
INTO		#stg_football_data
FROM		(
			SELECT		fbt.Div								COLLATE Latin1_General_100_BIN2_UTF8 AS league_code
						,CAST(RIGHT(fbt.Date, 4) + '-' + SUBSTRING(fbt.Date, 4, 2) + '-' + LEFT(fbt.Date, 2) AS DATETIME2(0)) AS game_date 
						,CAST(fbt.Time AS TIME(0))			AS game_time
						,LTRIM(RTRIM(fbt.HomeTeam))			COLLATE Latin1_General_100_BIN2_UTF8 AS home_team
						,LTRIM(RTRIM(fbt.AwayTeam))			COLLATE Latin1_General_100_BIN2_UTF8 AS away_team
						,CAST(fbt.FTHG AS SMALLINT)			AS full_time_home_goals
						,CAST(fbt.FTAG AS SMALLINT)			AS full_time_away_goals
						,CAST(fbt.FTR AS CHAR(1))			COLLATE Latin1_General_100_BIN2_UTF8 AS full_time_result
						,CAST(fbt.HTHG AS SMALLINT)			AS half_time_home_goals
						,CAST(fbt.HTAG AS SMALLINT)			AS half_time_away_goals
						,CAST(fbt.HTR AS CHAR(1))			COLLATE Latin1_General_100_BIN2_UTF8 AS half_time_result
			FROM		stg.football_data		fbt
			) d

-------------------------------------------------------------------------------------------------
-- Align team names with betfair data
-------------------------------------------------------------------------------------------------

UPDATE #stg_football_data SET home_team = 'AC Milan'	WHERE home_team = 'Milan'
UPDATE #stg_football_data SET home_team = 'AC Monza'	WHERE home_team = 'Monza'
UPDATE #stg_football_data SET home_team = 'Athletic Bilbao'	WHERE home_team = 'Ath Bilbao'
UPDATE #stg_football_data SET home_team = 'Atletico Madrid'	WHERE home_team = 'Ath Madrid'
UPDATE #stg_football_data SET home_team = 'Bristol Rovers'	WHERE home_team = 'Bristol Rvs'
UPDATE #stg_football_data SET home_team = 'Burton Albion'	WHERE home_team = 'Burton'
UPDATE #stg_football_data SET home_team = 'Cambridge Utd'	WHERE home_team = 'Cambridge'
UPDATE #stg_football_data SET home_team = 'Celta Vigo'	WHERE home_team = 'Celta'
UPDATE #stg_football_data SET home_team = 'Eintracht Frankfurt'	WHERE home_team = 'Ein Frankfurt'
UPDATE #stg_football_data SET home_team = 'Espanyol'	WHERE home_team = 'Espanol'
UPDATE #stg_football_data SET home_team = 'FC Heidenheim'	WHERE home_team = 'Heidenheim'
UPDATE #stg_football_data SET home_team = 'Man Utd'	WHERE home_team = 'Man United'
UPDATE #stg_football_data SET home_team = 'Mgladbach'	WHERE home_team = 'M''gladbach'
UPDATE #stg_football_data SET home_team = 'Nottm Forest'	WHERE home_team = 'Nott''m Forest'
UPDATE #stg_football_data SET home_team = 'Oxford Utd'	WHERE home_team = 'Oxford'
UPDATE #stg_football_data SET home_team = 'Paris St-G'	WHERE home_team = 'Paris SG'
UPDATE #stg_football_data SET home_team = 'Peterborough'	WHERE home_team = 'Peterboro'
UPDATE #stg_football_data SET home_team = 'Rayo Vallecano'	WHERE home_team = 'Vallecano'
UPDATE #stg_football_data SET home_team = 'Real Sociedad'	WHERE home_team = 'Sociedad'
UPDATE #stg_football_data SET home_team = 'Sheff Utd'	WHERE home_team = 'Sheffield United'
UPDATE #stg_football_data SET home_team = 'Sheff Wed'	WHERE home_team = 'Sheffield Weds'

UPDATE #stg_football_data SET away_team = 'AC Milan'	WHERE away_team = 'Milan'
UPDATE #stg_football_data SET away_team = 'AC Monza'	WHERE away_team = 'Monza'
UPDATE #stg_football_data SET away_team = 'Athletic Bilbao'	WHERE away_team = 'Ath Bilbao'
UPDATE #stg_football_data SET away_team = 'Atletico Madrid'	WHERE away_team = 'Ath Madrid'
UPDATE #stg_football_data SET away_team = 'Bristol Rovers'	WHERE away_team = 'Bristol Rvs'
UPDATE #stg_football_data SET away_team = 'Burton Albion'	WHERE away_team = 'Burton'
UPDATE #stg_football_data SET away_team = 'Cambridge Utd'	WHERE away_team = 'Cambridge'
UPDATE #stg_football_data SET away_team = 'Celta Vigo'	WHERE away_team = 'Celta'
UPDATE #stg_football_data SET away_team = 'Eintracht Frankfurt'	WHERE away_team = 'Ein Frankfurt'
UPDATE #stg_football_data SET away_team = 'Espanyol'	WHERE away_team = 'Espanol'
UPDATE #stg_football_data SET away_team = 'FC Heidenheim'	WHERE away_team = 'Heidenheim'
UPDATE #stg_football_data SET away_team = 'Man Utd'	WHERE away_team = 'Man United'
UPDATE #stg_football_data SET away_team = 'Mgladbach'	WHERE away_team = 'M''gladbach'
UPDATE #stg_football_data SET away_team = 'Nottm Forest'	WHERE away_team = 'Nott''m Forest'
UPDATE #stg_football_data SET away_team = 'Oxford Utd'	WHERE away_team = 'Oxford'
UPDATE #stg_football_data SET away_team = 'Paris St-G'	WHERE away_team = 'Paris SG'
UPDATE #stg_football_data SET away_team = 'Peterborough'	WHERE away_team = 'Peterboro'
UPDATE #stg_football_data SET away_team = 'Rayo Vallecano'	WHERE away_team = 'Vallecano'
UPDATE #stg_football_data SET away_team = 'Real Sociedad'	WHERE away_team = 'Sociedad'
UPDATE #stg_football_data SET away_team = 'Sheff Utd'	WHERE away_team = 'Sheffield United'
UPDATE #stg_football_data SET away_team = 'Sheff Wed'	WHERE away_team = 'Sheffield Weds'


UPDATE #stg_football_data SET away_team = 'SV Darmstadt'	WHERE away_team = 'Darmstadt'
UPDATE #stg_football_data SET away_team = 'Hamburger SV'	WHERE away_team = 'Hamburg'
UPDATE #stg_football_data SET away_team = 'Hertha Berlin'	WHERE away_team = 'Hertha'
UPDATE #stg_football_data SET away_team = 'FC Magdeburg'	WHERE away_team = 'Magdeburg'
UPDATE #stg_football_data SET away_team = 'VfL Osnabruck'	WHERE away_team = 'Osnabruck'
UPDATE #stg_football_data SET away_team = 'Preussen Munster'	WHERE away_team = 'PreuÃŸen MÃ¼nster'
UPDATE #stg_football_data SET away_team = 'Jahn Regensburg'	WHERE away_team = 'Regensburg'
UPDATE #stg_football_data SET away_team = 'SSV Ulm'	WHERE away_team = 'Ulm'
UPDATE #stg_football_data SET away_team = 'Wehen Wiesbaden'	WHERE away_team = 'Wehen'
UPDATE #stg_football_data SET away_team = 'AC Ajaccio'	WHERE away_team = 'Ajaccio'
UPDATE #stg_football_data SET away_team = 'Pau'	WHERE away_team = 'Pau FC'
UPDATE #stg_football_data SET away_team = 'ESTAC Troyes'	WHERE away_team = 'Troyes'
UPDATE #stg_football_data SET away_team = 'SSD Bari'	WHERE away_team = 'Bari'
UPDATE #stg_football_data SET away_team = 'US Cremonese'	WHERE away_team = 'Cremonese'
UPDATE #stg_football_data SET away_team = 'Feralpisalo'	WHERE away_team = 'FeralpiSalo'
UPDATE #stg_football_data SET away_team = 'Dundee Utd'	WHERE away_team = 'Dundee United'
UPDATE #stg_football_data SET away_team = 'Ross Co'	WHERE away_team = 'Ross County'
UPDATE #stg_football_data SET away_team = 'Andorra CF'	WHERE away_team = 'Andorra'
UPDATE #stg_football_data SET away_team = 'FC Cartagena'	WHERE away_team = 'Cartagena'
UPDATE #stg_football_data SET away_team = 'CD Castellon'	WHERE away_team = 'Castellon'
UPDATE #stg_football_data SET away_team = 'Racing de Ferrol'	WHERE away_team = 'Ferrol'
UPDATE #stg_football_data SET away_team = 'Deportivo'	WHERE away_team = 'La Coruna'
UPDATE #stg_football_data SET away_team = 'Racing Santander'	WHERE away_team = 'Santander'
UPDATE #stg_football_data SET away_team = 'Sporting Gijon'	WHERE away_team = 'Sp Gijon'

UPDATE #stg_football_data SET home_team = 'SV Darmstadt'	WHERE home_team = 'Darmstadt'
UPDATE #stg_football_data SET home_team = 'Hamburger SV'	WHERE home_team = 'Hamburg'
UPDATE #stg_football_data SET home_team = 'Hertha Berlin'	WHERE home_team = 'Hertha'
UPDATE #stg_football_data SET home_team = 'FC Magdeburg'	WHERE home_team = 'Magdeburg'
UPDATE #stg_football_data SET home_team = 'VfL Osnabruck'	WHERE home_team = 'Osnabruck'
UPDATE #stg_football_data SET home_team = 'Preussen Munster'	WHERE home_team = 'PreuÃŸen MÃ¼nster'
UPDATE #stg_football_data SET home_team = 'Jahn Regensburg'	WHERE home_team = 'Regensburg'
UPDATE #stg_football_data SET home_team = 'SSV Ulm'	WHERE home_team = 'Ulm'
UPDATE #stg_football_data SET home_team = 'Wehen Wiesbaden'	WHERE home_team = 'Wehen'
UPDATE #stg_football_data SET home_team = 'AC Ajaccio'	WHERE home_team = 'Ajaccio'
UPDATE #stg_football_data SET home_team = 'Pau'	WHERE home_team = 'Pau FC'
UPDATE #stg_football_data SET home_team = 'ESTAC Troyes'	WHERE home_team = 'Troyes'
UPDATE #stg_football_data SET home_team = 'SSD Bari'	WHERE home_team = 'Bari'
UPDATE #stg_football_data SET home_team = 'US Cremonese'	WHERE home_team = 'Cremonese'
UPDATE #stg_football_data SET home_team = 'Feralpisalo'	WHERE home_team = 'FeralpiSalo'
UPDATE #stg_football_data SET home_team = 'Dundee Utd'	WHERE home_team = 'Dundee United'
UPDATE #stg_football_data SET home_team = 'Ross Co'	WHERE home_team = 'Ross County'
UPDATE #stg_football_data SET home_team = 'Andorra CF'	WHERE home_team = 'Andorra'
UPDATE #stg_football_data SET home_team = 'FC Cartagena'	WHERE home_team = 'Cartagena'
UPDATE #stg_football_data SET home_team = 'CD Castellon'	WHERE home_team = 'Castellon'
UPDATE #stg_football_data SET home_team = 'Racing de Ferrol'	WHERE home_team = 'Ferrol'
UPDATE #stg_football_data SET home_team = 'Deportivo'	WHERE home_team = 'La Coruna'
UPDATE #stg_football_data SET home_team = 'Racing Santander'	WHERE home_team = 'Santander'
UPDATE #stg_football_data SET home_team = 'Sporting Gijon'	WHERE home_team = 'Sp Gijon'

-------------------------------------------------------------------------------------------------
-- Check names that don't match
-------------------------------------------------------------------------------------------------

--DROP TABLE IF EXISTS #betfair_team_names

--SELECT		evt.home_team	AS betfair_team_name
--INTO		#betfair_team_names
--FROM		dbo.event_details		evt
--WHERE		evt.league_name <> 'MLS'
--UNION
--SELECT		evt.away_team
--FROM		dbo.event_details		evt
--WHERE		evt.league_name <> 'MLS'

--DROP TABLE IF EXISTS #football_data_team_names

--SELECT		home_team	AS football_data_team_name
--INTO		#football_data_team_names
--FROM		#stg_football_data
--WHERE		league_code IN ('D1', 'E0', 'E1', 'E2', 'F1', 'I1', 'SP1')
--UNION
--SELECT		away_team
--FROM		#stg_football_data
--WHERE		league_code IN ('D1', 'E0', 'E1', 'E2', 'F1', 'I1', 'SP1')

--SELECT		DISTINCT
--			away_team
--FROM		dbo.event_details
--WHERE		home_team = 'Racing de Ferrol'
--ORDER BY	away_team


--SELECT		fdn.football_data_team_name
--			,btn.betfair_team_name
--			,fdn.league_code
----INTO		#names_that_match
--FROM		#betfair_team_names		btn
--			RIGHT JOIN
--			#football_data_team_names fdn
--			ON btn.betfair_team_name = fdn.football_data_team_name
--WHERE		league_code IN ('D2', 'F2', 'I2', 'SC0', 'SP2')
--ORDER BY	league_code
--			,btn.betfair_team_name
--			,fdn.football_data_team_name

-------------------------------------------------------------------------------------------------
-- Calcaulte goals from previous 6 matches
-------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #goals_history;

;WITH GOALSSCORED AS
(
SELECT		event_id
			,league_code
			,game_date
			,game_time
			,home_team				AS team_name
			,'H'					AS game_location
			,full_time_home_goals	AS goals_scored
			,full_time_result
			,league_name
FROM		dbo.football_results
UNION ALL
SELECT		event_id
			,league_code
			,game_date
			,game_time
			,away_team				AS team_name
			,'A'					AS game_location
			,full_time_away_goals	AS goals_scored
			,full_time_result
			,league_name
FROM		dbo.football_results
)
SELECT		glh.event_id
			,glh.league_code
			,glh.game_date
			,glh.game_time
			,glh.team_name
			,glh.game_location
			,glh.goals_scored
			,glh.full_time_result
			,glh.league_name
			,SUM(glh.goals_scored) OVER (PARTITION BY glh.team_name ORDER BY glh.game_date ASC ROWS BETWEEN 6 PRECEDING AND 1 PRECEDING) AS goals_from_prv_6
INTO		#goals_history
FROM		GOALSSCORED	glh

-------------------------------------------------------------------------------------------------
-- Calcaulte goals from previous 6 matches
-------------------------------------------------------------------------------------------------


DROP TABLE IF EXISTS dbo.football_results
CREATE TABLE dbo.football_results(event_id						INT NULL
									,league_code				VARCHAR(50) COLLATE Latin1_General_100_BIN2_UTF8 NULL
									,game_date					DATETIME2(0) NULL
									,game_time					TIME(0) NULL
									,home_team					VARCHAR(50) COLLATE Latin1_General_100_BIN2_UTF8 NULL
									,away_team					VARCHAR(50) COLLATE Latin1_General_100_BIN2_UTF8 NULL
									,full_time_home_goals		SMALLINT NULL
									,full_time_away_goals		SMALLINT NULL
									,full_time_result			CHAR(1) COLLATE Latin1_General_100_BIN2_UTF8 NULL
									,half_time_home_goals		SMALLINT NULL
									,half_time_away_goals		SMALLINT NULL
									,half_time_result			CHAR(1) COLLATE Latin1_General_100_BIN2_UTF8 NULL
									,league_name				VARCHAR(50) COLLATE Latin1_General_100_BIN2_UTF8 NULL
									,home_team_goals_from_prv_6	INT NULL
									,away_team_goals_from_prv_6	INT NULL
									)



INSERT INTO dbo.football_results (event_id
									,league_code
									,game_date
									,game_time
									,home_team
									,away_team
									,full_time_home_goals
									,full_time_away_goals
									,full_time_result
									,half_time_home_goals
									,half_time_away_goals
									,half_time_result
									,league_name
									,home_team_goals_from_prv_6
									,away_team_goals_from_prv_6
									)
SELECT		CAST(NULL AS INT)	AS event_id
			,stg.league_code
			,stg.game_date
			,stg.game_time
			,stg.home_team
			,stg.away_team
			,stg.full_time_home_goals
			,stg.full_time_away_goals
			,stg.full_time_result
			,stg.half_time_home_goals
			,stg.half_time_away_goals
			,stg.half_time_result
			,CASE
				WHEN stg.league_code = 'D1' THEN 'German Bundesliga'
				WHEN stg.league_code = 'E0' THEN 'English Premier League'
				WHEN stg.league_code = 'E1' THEN 'English Championship'
				WHEN stg.league_code = 'E2' THEN 'English League 1'
				WHEN stg.league_code = 'F1' THEN 'French Ligue 1'
				WHEN stg.league_code = 'I1' THEN 'Italian Serie A'
				WHEN stg.league_code = 'SP1' THEN 'Spanish La Liga'

				WHEN stg.league_code = 'D2' THEN 'German Bundesliga 2'
				WHEN stg.league_code = 'SC0' THEN 'Scottish Premier League'
				WHEN stg.league_code = 'F2' THEN 'French Ligue 2'
				WHEN stg.league_code = 'I2' THEN 'Italian Serie B'
				WHEN stg.league_code = 'SP2' THEN 'Spanish La Liga 2'

				WHEN stg.league_code = 'N1' THEN 'Dutch Eredivisie'
				WHEN stg.league_code = 'P1' THEN 'Portugal Primeira Liga'
			END AS league_name
			,hom.goals_from_prv_6		AS home_team_goals_from_prv_6
			,awy.goals_from_prv_6		AS away_team_goals_from_prv_6
FROM		#stg_football_data		stg
			LEFT OUTER JOIN
			#goals_history				hom
			ON stg.home_team = hom.team_name
			AND hom.game_date = stg.game_date
			LEFT OUTER JOIN
			#goals_history				awy
			ON stg.away_team = awy.team_name
			AND awy.game_date = stg.game_date



-------------------------------------------------------------------------------------------------
-- End processing
-------------------------------------------------------------------------------------------------

END
GO


