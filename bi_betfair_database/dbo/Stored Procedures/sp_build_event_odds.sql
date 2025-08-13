CREATE PROCEDURE [dbo].[sp_build_event_odds]
AS
BEGIN

SET NOCOUNT ON

-------------------------------------------------------------------------------------------------
-- Processing
-------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS dbo.event_odds

;WITH FLATTERN AS
(
SELECT		bmt.event_id
			,bmt.event_name
			,bmt.home_team
			,bmt.away_team
			,bmt.market_time
			,CASE
				WHEN bmt.market_type = 'MATCH_ODDS' AND bmt.home_team = odd.runner_name THEN 'Home'
				WHEN bmt.market_type = 'MATCH_ODDS' AND bmt.away_team = odd.runner_name THEN 'Away'
				WHEN bmt.market_type IN ('OVER_UNDER_45', 'OVER_UNDER_35', 'OVER_UNDER_25')
				THEN LOWER(REPLACE(REPLACE(odd.runner_name, '.', ''), ' ', '_'))
				ELSE 'Draw'
			END AS selection
			,CASE
				WHEN rmo.runner_name = bmt.home_team THEN 'Home'
				WHEN rmo.runner_name = bmt.away_team THEN 'Away'
				ELSE rmo.runner_name
			END						AS match_odds_winner
			,r25.runner_name		AS over_under_25_winner
			,r35.runner_name		AS over_under_35_winner
			,r45.runner_name		AS over_under_45_winner
			,odd.odds_hour_before
-- SELECT
FROM		dbo.bet_markets						bmt
			INNER JOIN
			dbo.market_odds_hour_before_game	odd
			ON bmt.market_id = odd.market_id

			INNER JOIN
			dbo.event_details					evt
			ON bmt.event_id = evt.event_id

			LEFT OUTER JOIN
			dbo.bet_markets			mto
			ON bmt.event_id = mto.event_id
			AND mto.market_type = 'MATCH_ODDS'
			LEFT OUTER JOIN
			dbo.bet_market_results	rmo
			ON mto.market_id = rmo.market_id
			AND rmo.market_result = 'WINNER'
			LEFT OUTER JOIN
			dbo.bet_markets			o25
			ON bmt.event_id = o25.event_id
			AND o25.market_type = 'OVER_UNDER_25'
			LEFT OUTER JOIN
			dbo.bet_market_results	r25
			ON o25.market_id = r25.market_id
			AND r25.market_result = 'WINNER'
			LEFT OUTER JOIN
			dbo.bet_markets			o35
			ON bmt.event_id = o35.event_id
			AND o35.market_type = 'OVER_UNDER_35'
			LEFT OUTER JOIN
			dbo.bet_market_results	r35
			ON o35.market_id = r35.market_id
			AND r35.market_result = 'WINNER'
			LEFT OUTER JOIN
			dbo.bet_markets			o45
			ON bmt.event_id = o45.event_id
			AND o45.market_type = 'OVER_UNDER_45'
			LEFT OUTER JOIN
			dbo.bet_market_results	r45
			ON o45.market_id = r45.market_id
			AND r45.market_result = 'WINNER'

WHERE		1 = 1

)
SELECT		event_id
			,event_name
			,home_team
			,away_team
			,market_time
			,match_odds_winner
			,Home
			,Draw
			,Away

			,CASE
				WHEN Home BETWEEN 1.01 AND 1.99 THEN Home + 0.01
				WHEN Home BETWEEN 2.00 AND 2.98 THEN Home + 0.02
				WHEN Home BETWEEN 3.00 AND 3.95 THEN Home + 0.05
				WHEN Home BETWEEN 4.00 AND 5.90 THEN Home + 0.10
				WHEN Home BETWEEN 6.00 AND 9.80 THEN Home + 0.20
				WHEN Home BETWEEN 10.00 AND 19.5 THEN Home + 0.50
				WHEN Home BETWEEN 20.00 AND 29.00 THEN Home + 1.00
				WHEN Home BETWEEN 30.00 AND 48.00 THEN Home + 2.00
				WHEN Home BETWEEN 50.00 AND 95.00 THEN Home + 5.00
				WHEN Home BETWEEN 100.00 AND 1000.0 THEN Home + 10.00
			END AS home_lay
			,CASE
				WHEN Draw BETWEEN 1.01 AND 1.99 THEN Draw + 0.01
				WHEN Draw BETWEEN 2.00 AND 2.98 THEN Draw + 0.02
				WHEN Draw BETWEEN 3.00 AND 3.95 THEN Draw + 0.05
				WHEN Draw BETWEEN 4.00 AND 5.90 THEN Draw + 0.10
				WHEN Draw BETWEEN 6.00 AND 9.80 THEN Draw + 0.20
				WHEN Draw BETWEEN 10.00 AND 19.5 THEN Draw + 0.50
				WHEN Draw BETWEEN 20.00 AND 29.00 THEN Draw + 1.00
				WHEN Draw BETWEEN 30.00 AND 48.00 THEN Draw + 2.00
				WHEN Draw BETWEEN 50.00 AND 95.00 THEN Draw + 5.00
				WHEN Draw BETWEEN 100.00 AND 1000.0 THEN Draw + 10.00
			END AS draw_lay
			,CASE
				WHEN Away BETWEEN 1.01 AND 1.99 THEN Away + 0.01
				WHEN Away BETWEEN 2.00 AND 2.98 THEN Away + 0.02
				WHEN Away BETWEEN 3.00 AND 3.95 THEN Away + 0.05
				WHEN Away BETWEEN 4.00 AND 5.90 THEN Away + 0.10
				WHEN Away BETWEEN 6.00 AND 9.80 THEN Away + 0.20
				WHEN Away BETWEEN 10.00 AND 19.5 THEN Away + 0.50
				WHEN Away BETWEEN 20.00 AND 29.00 THEN Away + 1.00
				WHEN Away BETWEEN 30.00 AND 48.00 THEN Away + 2.00
				WHEN Away BETWEEN 50.00 AND 95.00 THEN Away + 5.00
				WHEN Away BETWEEN 100.00 AND 1000.0 THEN Away + 10.00
			END AS away_lay

			,over_under_25_winner
			,under_25_goals
			,over_25_goals
			,CASE
				WHEN under_25_goals BETWEEN 1.01 AND 1.99 THEN under_25_goals + 0.01
				WHEN under_25_goals BETWEEN 2.00 AND 2.98 THEN under_25_goals + 0.02
				WHEN under_25_goals BETWEEN 3.00 AND 3.95 THEN under_25_goals + 0.05
				WHEN under_25_goals BETWEEN 4.00 AND 5.90 THEN under_25_goals + 0.10
				WHEN under_25_goals BETWEEN 6.00 AND 9.80 THEN under_25_goals + 0.20
				WHEN under_25_goals BETWEEN 10.00 AND 19.5 THEN under_25_goals + 0.50
				WHEN under_25_goals BETWEEN 20.00 AND 29.00 THEN under_25_goals + 1.00
				WHEN under_25_goals BETWEEN 30.00 AND 48.00 THEN under_25_goals + 2.00
				WHEN under_25_goals BETWEEN 50.00 AND 95.00 THEN under_25_goals + 5.00
				WHEN under_25_goals BETWEEN 100.00 AND 1000.0 THEN under_25_goals + 10.00
			END AS under_25_goals_lay
			,over_under_35_winner
			,under_35_goals
			,over_35_goals
			,CASE
				WHEN under_35_goals BETWEEN 1.01 AND 1.99 THEN under_35_goals + 0.01
				WHEN under_35_goals BETWEEN 2.00 AND 2.98 THEN under_35_goals + 0.02
				WHEN under_35_goals BETWEEN 3.00 AND 3.95 THEN under_35_goals + 0.05
				WHEN under_35_goals BETWEEN 4.00 AND 5.90 THEN under_35_goals + 0.10
				WHEN under_35_goals BETWEEN 6.00 AND 9.80 THEN under_35_goals + 0.20
				WHEN under_35_goals BETWEEN 10.00 AND 19.5 THEN under_35_goals + 0.50
				WHEN under_35_goals BETWEEN 20.00 AND 29.00 THEN under_35_goals + 1.00
				WHEN under_35_goals BETWEEN 30.00 AND 48.00 THEN under_35_goals + 2.00
				WHEN under_35_goals BETWEEN 50.00 AND 95.00 THEN under_35_goals + 5.00
				WHEN under_35_goals BETWEEN 100.00 AND 1000.0 THEN under_35_goals + 10.00
			END AS under_35_goals_lay
			,over_under_45_winner
			,under_45_goals
			,over_45_goals
			,CASE
				WHEN under_45_goals BETWEEN 1.01 AND 1.99 THEN under_45_goals + 0.01
				WHEN under_45_goals BETWEEN 2.00 AND 2.98 THEN under_45_goals + 0.02
				WHEN under_45_goals BETWEEN 3.00 AND 3.95 THEN under_45_goals + 0.05
				WHEN under_45_goals BETWEEN 4.00 AND 5.90 THEN under_45_goals + 0.10
				WHEN under_45_goals BETWEEN 6.00 AND 9.80 THEN under_45_goals + 0.20
				WHEN under_45_goals BETWEEN 10.00 AND 19.5 THEN under_45_goals + 0.50
				WHEN under_45_goals BETWEEN 20.00 AND 29.00 THEN under_45_goals + 1.00
				WHEN under_45_goals BETWEEN 30.00 AND 48.00 THEN under_45_goals + 2.00
				WHEN under_45_goals BETWEEN 50.00 AND 95.00 THEN under_45_goals + 5.00
				WHEN under_45_goals BETWEEN 100.00 AND 1000.0 THEN under_45_goals + 10.00
			END AS under_45_goals_lay
INTO		dbo.event_odds
FROM		FLATTERN
PIVOT
(
MIN(odds_hour_before)
FOR selection IN (Home, Draw, Away, under_25_goals, over_25_goals, under_35_goals, over_35_goals, under_45_goals, over_45_goals)
) AS piv;


-------------------------------------------------------------------------------------------------
-- Delete games where market isn't liquid (no bets an hour before game)
-------------------------------------------------------------------------------------------------

--DELETE FROM dbo.event_odds	WHERE	Under_2_5_Goals IS NULL
--							OR		Over_2_5_Goals IS NULL
--							OR		Under_3_5_Goals IS NULL
--							OR		Over_3_5_Goals IS NULL
--							OR		Under_4_5_Goals IS NULL
--							OR		Over_4_5_Goals IS NULL





/*
SELECT		*
FROM		dbo.event_odds
*/

-------------------------------------------------------------------------------------------------
-- End processing
-------------------------------------------------------------------------------------------------

END