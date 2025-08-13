CREATE PROCEDURE [dbo].[sp_build_event_details]
AS
BEGIN

SET NOCOUNT ON

-------------------------------------------------------------------------------------------------
-- Create a mapping table of teams / leagues
-------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS stg.team_league;
CREATE TABLE stg.team_league (team_name		VARCHAR(50) COLLATE Latin1_General_100_BIN2_UTF8
							,league_name	VARCHAR(50) COLLATE Latin1_General_100_BIN2_UTF8
							)

INSERT INTO stg.team_league (team_name, league_name) VALUES ('Blackburn', 'English Championship')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Bristol City', 'English Championship')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Burnley', 'English Championship')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Cardiff', 'English Championship')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Coventry', 'English Championship')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Derby', 'English Championship')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Hull', 'English Championship')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Leeds', 'English Championship')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Luton', 'English Championship')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Middlesbrough', 'English Championship')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Millwall', 'English Championship')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Norwich', 'English Championship')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Oxford Utd', 'English Championship')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Plymouth', 'English Championship')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Portsmouth', 'English Championship')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Preston', 'English Championship')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('QPR', 'English Championship')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Sheff Utd', 'English Championship')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Sheff Wed', 'English Championship')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Stoke', 'English Championship')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Sunderland', 'English Championship')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Swansea', 'English Championship')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Watford', 'English Championship')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('West Brom', 'English Championship')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Barnsley', 'English League 1')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Birmingham', 'English League 1')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Blackpool', 'English League 1')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Bolton', 'English League 1')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Bristol Rovers', 'English League 1')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Burton Albion', 'English League 1')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Cambridge Utd', 'English League 1')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Charlton', 'English League 1')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Crawley Town', 'English League 1')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Exeter', 'English League 1')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Huddersfield', 'English League 1')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Leyton Orient', 'English League 1')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Lincoln', 'English League 1')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Mansfield', 'English League 1')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Northampton', 'English League 1')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Peterborough', 'English League 1')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Reading', 'English League 1')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Rotherham', 'English League 1')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Shrewsbury', 'English League 1')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Stevenage', 'English League 1')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Stockport', 'English League 1')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Wigan', 'English League 1')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Wrexham', 'English League 1')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Wycombe', 'English League 1')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Arsenal', 'English Premier League')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Aston Villa', 'English Premier League')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Bournemouth', 'English Premier League')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Brentford', 'English Premier League')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Brighton', 'English Premier League')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Chelsea', 'English Premier League')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Crystal Palace', 'English Premier League')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Everton', 'English Premier League')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Fulham', 'English Premier League')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Ipswich', 'English Premier League')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Leicester', 'English Premier League')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Liverpool', 'English Premier League')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Man City', 'English Premier League')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Man Utd', 'English Premier League')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Newcastle', 'English Premier League')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Nottm Forest', 'English Premier League')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Southampton', 'English Premier League')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Tottenham', 'English Premier League')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('West Ham', 'English Premier League')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Wolves', 'English Premier League')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Angers', 'French Ligue A')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Auxerre', 'French Ligue A')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Brest', 'French Ligue A')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Le Havre', 'French Ligue A')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Lens', 'French Ligue A')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Lille', 'French Ligue A')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Lyon', 'French Ligue A')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Marseille', 'French Ligue A')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Monaco', 'French Ligue A')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Montpellier', 'French Ligue A')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Nantes', 'French Ligue A')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Nice', 'French Ligue A')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Paris St-G', 'French Ligue A')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Reims', 'French Ligue A')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Rennes', 'French Ligue A')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('St Etienne', 'French Ligue A')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Strasbourg', 'French Ligue A')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Toulouse', 'French Ligue A')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Augsburg', 'German Bundesliga')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Bayern Munich', 'German Bundesliga')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Bochum', 'German Bundesliga')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Dortmund', 'German Bundesliga')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Eintracht Frankfurt', 'German Bundesliga')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('FC Heidenheim', 'German Bundesliga')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Freiburg', 'German Bundesliga')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Hoffenheim', 'German Bundesliga')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Holstein Kiel', 'German Bundesliga')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Leverkusen', 'German Bundesliga')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Mainz', 'German Bundesliga')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Mgladbach', 'German Bundesliga')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('RB Leipzig', 'German Bundesliga')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('St Pauli', 'German Bundesliga')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Stuttgart', 'German Bundesliga')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Union Berlin', 'German Bundesliga')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Werder Bremen', 'German Bundesliga')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Wolfsburg', 'German Bundesliga')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('AC Milan', 'Italian Serie A')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('AC Monza', 'Italian Serie A')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Atalanta', 'Italian Serie A')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Bologna', 'Italian Serie A')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Cagliari', 'Italian Serie A')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Como', 'Italian Serie A')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Empoli', 'Italian Serie A')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Fiorentina', 'Italian Serie A')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Genoa', 'Italian Serie A')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Inter', 'Italian Serie A')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Juventus', 'Italian Serie A')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Lazio', 'Italian Serie A')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Lecce', 'Italian Serie A')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Napoli', 'Italian Serie A')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Parma', 'Italian Serie A')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Roma', 'Italian Serie A')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Torino', 'Italian Serie A')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Udinese', 'Italian Serie A')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Venezia', 'Italian Serie A')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Verona', 'Italian Serie A')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Atlanta Utd', 'MLS')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Austin FC', 'MLS')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('CF Montreal', 'MLS')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Charlotte FC', 'MLS')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Chicago Fire', 'MLS')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Colorado', 'MLS')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Columbus', 'MLS')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('DC Utd', 'MLS')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('FC Cincinnati', 'MLS')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('FC Dallas', 'MLS')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Houston Dynamo', 'MLS')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Inter Miami CF', 'MLS')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Kansas City', 'MLS')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('LA Galaxy', 'MLS')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Los Angeles FC', 'MLS')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Minnesota Utd', 'MLS')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Nashville SC', 'MLS')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('New England', 'MLS')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('New York City', 'MLS')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('New York Red Bulls', 'MLS')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Orlando City', 'MLS')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Philadelphia', 'MLS')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Portland Timbers', 'MLS')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Real Salt Lake', 'MLS')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('San Diego FC', 'MLS')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('San Jose Earthquakes', 'MLS')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Seattle Sounders', 'MLS')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('St Louis City SC', 'MLS')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Toronto FC', 'MLS')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Vancouver Whitecaps', 'MLS')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Alaves', 'Spanish La Liga')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Athletic Bilbao', 'Spanish La Liga')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Atletico Madrid', 'Spanish La Liga')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Barcelona', 'Spanish La Liga')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Betis', 'Spanish La Liga')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Celta Vigo', 'Spanish La Liga')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Espanyol', 'Spanish La Liga')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Getafe', 'Spanish La Liga')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Girona', 'Spanish La Liga')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Las Palmas', 'Spanish La Liga')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Leganes', 'Spanish La Liga')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Mallorca', 'Spanish La Liga')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Osasuna', 'Spanish La Liga')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Rayo Vallecano', 'Spanish La Liga')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Real Madrid', 'Spanish La Liga')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Real Sociedad', 'Spanish La Liga')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Sevilla', 'Spanish La Liga')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Valencia', 'Spanish La Liga')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Valladolid', 'Spanish La Liga')
INSERT INTO stg.team_league (team_name, league_name) VALUES ('Villarreal', 'Spanish La Liga')



-------------------------------------------------------------------------------------------------
-- Create event leagues table only for main european leagues
-------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS dbo.event_details

SELECT		bmt.event_id
			,bmt.event_name
			,bmt.market_time
			,YEAR(bmt.market_time) * 100 + MONTH(bmt.market_time) AS market_date_month_year
			,bmt.country_code
			,bmt.home_team
			,bmt.away_team
			,CASE
				WHEN rmo.runner_name = bmt.home_team THEN 'Home'
				WHEN rmo.runner_name = bmt.away_team THEN 'Away'
				ELSE rmo.runner_name
			END						AS match_odds_winner
			,CASE
				WHEN res.league_name IS NOT NULL
				THEN res.league_name

				WHEN hom.league_name = 'MLS'
				AND awy.league_name = 'MLS'
				THEN hom.league_name

				WHEN hom.team_name IS NOT NULL
				AND awy.team_name IS NOT NULL
				THEN 'Other Competitions'
			END AS league_name
			,res.home_team_goals_from_prv_6
			,res.away_team_goals_from_prv_6

			,MIN(bmt.market_inplay_timestamp)	AS event_goes_in_play
INTO		dbo.event_details
FROM		dbo.bet_markets		bmt
			LEFT OUTER JOIN
			stg.team_league		hom
			ON bmt.home_team = hom.team_name
			LEFT OUTER JOIN
			stg.team_league		awy
			ON bmt.away_team = awy.team_name
			LEFT OUTER JOIN
			dbo.football_results		res
			ON res.home_team = bmt.home_team
			AND res.away_team = bmt.away_team
			AND res.game_date = CAST(bmt.market_time AS DATE)
			INNER JOIN
			dbo.bet_market_results	rmo
			ON bmt.market_id = rmo.market_id
			AND rmo.market_result = 'WINNER'
			AND bmt.market_type = 'MATCH_ODDS'
GROUP BY	bmt.event_id
			,bmt.event_name
			,bmt.market_time
			,bmt.country_code
			,bmt.home_team
			,bmt.away_team
			,CASE
				WHEN rmo.runner_name = bmt.home_team THEN 'Home'
				WHEN rmo.runner_name = bmt.away_team THEN 'Away'
				ELSE rmo.runner_name
			END
			,CASE
				WHEN res.league_name IS NOT NULL
				THEN res.league_name

				WHEN hom.league_name = 'MLS'
				AND awy.league_name = 'MLS'
				THEN hom.league_name

				WHEN hom.team_name IS NOT NULL
				AND awy.team_name IS NOT NULL
				THEN 'Other Competitions'
			END
			,res.home_team_goals_from_prv_6
			,res.away_team_goals_from_prv_6




--DELETE FROM dbo.event_details WHERE league_name IS NULL


UPDATE dbo.event_details SET league_name = 'Lower leagues - GB' WHERE league_name IS NULL AND country_code = 'GB'
UPDATE dbo.event_details SET league_name = 'Lower leagues - ES' WHERE league_name IS NULL AND country_code = 'ES'
UPDATE dbo.event_details SET league_name = 'Lower leagues - DE' WHERE league_name IS NULL AND country_code = 'DE'
UPDATE dbo.event_details SET league_name = 'Lower leagues - IT' WHERE league_name IS NULL AND country_code = 'IT'
UPDATE dbo.event_details SET league_name = 'Lower leagues - FR' WHERE league_name IS NULL AND country_code = 'FR'
UPDATE dbo.event_details SET league_name = 'Lower leagues - US' WHERE league_name IS NULL AND country_code = 'US'


DROP TABLE IF EXISTS stg.team_league

-------------------------------------------------------------------------------------------------
-- Update event_id in football_results
-------------------------------------------------------------------------------------------------

UPDATE	dbo.football_results
SET		event_id = evt.event_id
FROM	dbo.event_details			evt
		INNER JOIN
		dbo.football_results		res
		ON res.home_team = evt.home_team
		AND res.away_team = evt.away_team
		AND res.game_date = CAST(evt.market_time AS DATE)



/*
SELECT		*
FROM		dbo.football_results		res
WHERE		res.event_id = 18794


SELECT		*
FROM		dbo.event_details		res
WHERE		res.event_id = 18794

*/

-------------------------------------------------------------------------------------------------
-- End processing
-------------------------------------------------------------------------------------------------

END