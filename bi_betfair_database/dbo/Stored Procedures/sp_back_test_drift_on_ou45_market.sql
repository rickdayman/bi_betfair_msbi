CREATE PROCEDURE [dbo].[sp_back_test_drift_on_ou45_market]
AS
BEGIN

SET NOCOUNT ON

-------------------------------------------------------------------------------------------------
-- Odds at start
-------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #odds_at_start;

SELECT		bmo.market_id
			,bmt.event_id
			,bmo.odds_price_traded
			,bmo.odds_timestamp
			,inp.goes_in_play
INTO		#odds_at_start
FROM		dbo.bet_market_odds		bmo
			INNER JOIN
			dbo.bet_markets			bmt
			ON bmo.market_id = bmt.market_id
			INNER JOIN
			dbo.event_goes_in_play	inp
			ON bmt.event_id = inp.event_id

			AND bmo.odds_timestamp = (SELECT		MIN(o.odds_timestamp)
										FROM		dbo.bet_market_odds		o
													INNER JOIN
													dbo.bet_markets			b
													ON o.market_id = b.market_id
													INNER JOIN
													dbo.event_goes_in_play	p
													ON b.event_id = p.event_id
										WHERE		o.market_id = bmo.market_id
										AND			o.runner_name = 'Under 4.5 Goals'
										AND			o.market_status = 'OPEN'
										AND			o.odds_timestamp >= p.goes_in_play
										)



WHERE		bmo.runner_name = 'Under 4.5 Goals'
--AND			bmo.market_id = 1224294131

--SELECT		*
--FROM		#odds_at_start
--WHERE		market_id = 1224294131
-------------------------------------------------------------------------------------------------
-- Odds at after 10 mins
-------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #odds_after_10_mins;

SELECT		bmo.market_id
			,bmt.event_id
			,bmo.odds_price_traded
			,bmo.odds_timestamp
			,inp.goes_in_play
INTO		#odds_after_10_mins
FROM		dbo.bet_market_odds		bmo
			INNER JOIN
			dbo.bet_markets			bmt
			ON bmo.market_id = bmt.market_id
			INNER JOIN
			dbo.event_goes_in_play	inp
			ON bmt.event_id = inp.event_id

			AND bmo.odds_timestamp = (SELECT		MIN(o.odds_timestamp)
										FROM		dbo.bet_market_odds		o
													INNER JOIN
													dbo.bet_markets			b
													ON o.market_id = b.market_id
													INNER JOIN
													dbo.event_goes_in_play	p
													ON b.event_id = p.event_id
										WHERE		o.market_id = bmo.market_id
										AND			o.runner_name = 'Under 4.5 Goals'
										AND			o.market_status = 'OPEN'
										AND			o.odds_timestamp >= DATEADD(MINUTE, 10, p.goes_in_play)
										)



WHERE		bmo.runner_name = 'Under 4.5 Goals'
--AND			bmo.market_id = 1224294131


--SELECT		*
--FROM		#odds_after_10_mins
--WHERE		market_id = 1224294131

-------------------------------------------------------------------------------------------------
-- Odds at after 15 mins
-------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #odds_after_15_mins;

SELECT		bmo.market_id
			,bmt.event_id
			,bmo.odds_price_traded
			,bmo.odds_timestamp
			,inp.goes_in_play
INTO		#odds_after_15_mins
FROM		dbo.bet_market_odds		bmo
			INNER JOIN
			dbo.bet_markets			bmt
			ON bmo.market_id = bmt.market_id
			INNER JOIN
			dbo.event_goes_in_play	inp
			ON bmt.event_id = inp.event_id

			AND bmo.odds_timestamp = (SELECT		MIN(o.odds_timestamp)
										FROM		dbo.bet_market_odds		o
													INNER JOIN
													dbo.bet_markets			b
													ON o.market_id = b.market_id
													INNER JOIN
													dbo.event_goes_in_play	p
													ON b.event_id = p.event_id
										WHERE		o.market_id = bmo.market_id
										AND			o.runner_name = 'Under 4.5 Goals'
										AND			o.market_status = 'OPEN'
										AND			o.odds_timestamp >= DATEADD(MINUTE, 15, p.goes_in_play)
										)
WHERE		bmo.runner_name = 'Under 4.5 Goals'


-------------------------------------------------------------------------------------------------
-- Odds at after 20 mins
-------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #odds_after_20_mins;

SELECT		bmo.market_id
			,bmt.event_id
			,bmo.odds_price_traded
			,bmo.odds_timestamp
			,inp.goes_in_play
INTO		#odds_after_20_mins
FROM		dbo.bet_market_odds		bmo
			INNER JOIN
			dbo.bet_markets			bmt
			ON bmo.market_id = bmt.market_id
			INNER JOIN
			dbo.event_goes_in_play	inp
			ON bmt.event_id = inp.event_id

			AND bmo.odds_timestamp = (SELECT		MIN(o.odds_timestamp)
										FROM		dbo.bet_market_odds		o
													INNER JOIN
													dbo.bet_markets			b
													ON o.market_id = b.market_id
													INNER JOIN
													dbo.event_goes_in_play	p
													ON b.event_id = p.event_id
										WHERE		o.market_id = bmo.market_id
										AND			o.runner_name = 'Under 4.5 Goals'
										AND			o.market_status = 'OPEN'
										AND			o.odds_timestamp >= DATEADD(MINUTE, 20, p.goes_in_play)
										)
WHERE		bmo.runner_name = 'Under 4.5 Goals'


-------------------------------------------------------------------------------------------------
-- Caluclate odds drift
-------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #events




SELECT		evo.*
			,lge.league_name

			,bmt.market_id

INTO		#events
FROM		dbo.event_odds			evo
			INNER JOIN
			dbo.event_details		lge
			ON evo.event_id = lge.event_id
			INNER JOIN
			dbo.bet_markets			bmt
			ON bmt.event_id = evo.event_id
			AND bmt.market_type = 'OVER_UNDER_45'

DROP TABLE IF EXISTS #drifts

SELECT		evt.event_id
			,evt.market_id
			,evt.event_name
			,evt.home_team
			,evt.away_team
			,evt.league_name
			,evt.market_time
			,evt.over_under_45_winner
			,evt.Under_4_5_Goals
			,evt.Over_4_5_Goals
			,m00.goes_in_play
			,m00.odds_price_traded	AS odds_at_00
			,m10.odds_price_traded	AS odds_at_10

			,m00.odds_price_traded - m10.odds_price_traded AS drift_10


			,m15.odds_price_traded	AS odds_at_15
			,m20.odds_price_traded	AS odds_at_20


			--,evt.over_under_35_winner
			--,evt.Under_3_5_Goals
			--,evt.Over_3_5_Goals
INTO		#drifts
FROM		#events					evt


			LEFT OUTER JOIN
			#odds_at_start			m00
			ON m00.event_id = evt.event_id
			LEFT OUTER JOIN
			#odds_after_10_mins		m10
			ON m10.event_id = evt.event_id
			LEFT OUTER JOIN
			#odds_after_15_mins		m15
			ON m15.event_id = evt.event_id
			LEFT OUTER JOIN
			#odds_after_20_mins		m20
			ON m20.event_id = evt.event_id


--WHERE		evt.event_id = 1275




SELECT		drift_10
			,SUM(CASE WHEN over_under_45_winner = 'Under 4.5 Goals' THEN 1 ELSE 0 END) AS under_count
			,SUM(CASE WHEN over_under_45_winner = 'Over 4.5 Goals' THEN 1 ELSE 0 END) AS over_count
			,COUNT(*) AS freq
-- SELECT	TOP 10 *
FROM		#drifts
GROUP BY	drift_10
ORDER BY	drift_10


--SELECT		bmo.*
--FROM		dbo.bet_market_odds		bmo
--			INNER JOIN
--			dbo.bet_markets			bmt
--			ON bmo.market_id = bmt.market_id
--			INNER JOIN
--			dbo.event_goes_in_play	inp
--			ON bmt.event_id = inp.event_id

--WHERE		bmo.runner_name = 'Under 4.5 Goals'
--AND			bmt.event_id = 12576

--ORDER BY	bmo.odds_timestamp



DECLARE @spread_percent DECIMAL(4, 2)
SET		@spread_percent = 0.75

DECLARE @bet_amount DECIMAL(5, 2)
SET		@bet_amount = 10.00

DECLARE @commission DECIMAL(5, 2)
SET		@commission = 5.0
SET		@commission = (100.0 - @commission) / 100.0

DROP TABLE IF EXISTS #scalper;

SELECT		evt.event_id
			,evt.market_id
			,evt.event_name
			,evt.home_team
			,evt.away_team
			,evt.league_name
			,evt.market_time
			,evt.over_under_45_winner
			,evt.Under_4_5_Goals
			,CAST(1 + ROUND(CEILING(((evt.Under_4_5_Goals) - 1) * @spread_percent * 100) / 100, 2) AS DECIMAL(4, 2)) AS lay_under_45

			,(SELECT	MIN(b.odds_price_traded)
			  FROM		dbo.bet_market_odds		b
			  WHERE		b.runner_name = 'Under 4.5 Goals'
			  AND		b.market_id = evt.market_id)	AS lowest_lay_value



INTO		#scalper
FROM		#events					evt



SELECT		scp.*

			,CASE
				WHEN lowest_lay_value > lay_under_45
				AND over_under_45_winner = 'Under 4.5 Goals'
				THEN (Under_4_5_Goals - 1.0) * @bet_amount

				WHEN lowest_lay_value > lay_under_45
				AND over_under_45_winner = 'Over 4.5 Goals'
				THEN -1 * @bet_amount

				--WHEN lowest_lay_value <= lay_under_45
				--AND over_under_45_winner = 'Under 4.5 Goals'
				--THEN (Under_4_5_Goals - 1.0) * @bet_amount

				WHEN lowest_lay_value <= lay_under_45
				AND over_under_45_winner = 'Over 4.5 Goals'
				THEN 0.0


			END AS profit



FROM		#scalper			scp









/*
SELECT		bmo.*
FROM		dbo.bet_market_odds		bmo
WHERE		bmo.runner_name = 'Under 4.5 Goals'
AND			bmo.market_id = 1242019626
ORDER BY	odds_timestamp
*/

-------------------------------------------------------------------------------------------------
-- End processing
-------------------------------------------------------------------------------------------------

END