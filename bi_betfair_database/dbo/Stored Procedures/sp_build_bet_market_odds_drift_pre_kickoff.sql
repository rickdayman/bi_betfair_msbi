CREATE PROCEDURE [dbo].[sp_build_bet_market_odds_drift_pre_kickoff] (@drift_percent DECIMAL(4, 2) = 1.01)
AS
BEGIN

SET NOCOUNT ON

-------------------------------------------------------------------------------------------------
-- Determine order ids of set timestamps
-------------------------------------------------------------------------------------------------


DROP TABLE IF EXISTS #pre_inplay_order_ids

SELECT		bmo.market_id
			,bmo.runner_id
			,bmo.runner_name

			,CASE
				WHEN bmo.runner_name = evt.home_team THEN 'Home'
				WHEN bmo.runner_name = evt.away_team THEN 'Away'
				ELSE bmo.runner_name
			END AS runner_name_display

			,bmt.event_id
			,1									AS market_open_order
			-- minus-ing 1 since data incomplete, when inplay changes to True it can be 1-12 mins into the game where a goal has been scored and the odds have changed
			,MAX(bmo.matched_bets_order) - 1	AS market_inplay_order 
			,MAX(CASE
					WHEN bmo.odds_timestamp < DATEADD(HOUR, -8, bmt.market_inplay_timestamp)
					THEN bmo.matched_bets_order
					ELSE 1
				END) AS market_8hrs_before_order
			,MAX(CASE
					WHEN bmo.odds_timestamp < DATEADD(HOUR, -1, bmt.market_inplay_timestamp)
					THEN bmo.matched_bets_order
					ELSE 1
				END) AS market_1hr_before_order
INTO		#pre_inplay_order_ids
FROM		dbo.bet_market_odds			bmo
			INNER JOIN
			dbo.bet_markets				bmt
			ON bmo.market_id = bmt.market_id
			-- join to event_details to ensure top leagues
			INNER JOIN
			dbo.event_details			evt
			ON bmt.event_id = evt.event_id
WHERE		1 = 1
AND			bmo.market_status = 'OPEN'
AND			bmo.odds_timestamp >= bmt.market_open_timestamp
AND			bmo.odds_timestamp <= bmt.market_inplay_timestamp
GROUP BY	bmo.market_id
			,bmo.runner_id
			,bmo.runner_name
			,bmt.event_id
			,CASE
				WHEN bmo.runner_name = evt.home_team THEN 'Home'
				WHEN bmo.runner_name = evt.away_team THEN 'Away'
				ELSE bmo.runner_name
			END

-------------------------------------------------------------------------------------------------
-- Alter market_inplay_order when equals 0 (only one row before inplay)
-------------------------------------------------------------------------------------------------

UPDATE #pre_inplay_order_ids SET market_inplay_order = 1 WHERE market_inplay_order = 0

-------------------------------------------------------------------------------------------------
-- Create an ordering of market odds timestamps
-------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS dbo.bet_market_odds_drift_pre_kickoff

SELECT		pre.market_id
			,pre.runner_id
			,pre.runner_name
			,pre.runner_name_display
			,pre.event_id
			--,pre.market_open_order
			--,pre.market_inplay_order
			,pre.market_8hrs_before_order
			--,pre.market_1hr_before_order
			,opn.odds_price_traded		AS odds_opening
			,hr8.odds_price_traded		AS odds_8hrs_before
			--,hr1.odds_price_traded		AS odds_1hr_before
			--,inp.odds_price_traded		AS odds_inplay
			--,CAST((inp.odds_price_traded - opn.odds_price_traded) / opn.odds_price_traded AS DECIMAL(6, 3))	AS open_to_inplay_drift
			--,CAST((inp.odds_price_traded - hr6.odds_price_traded) / hr6.odds_price_traded AS DECIMAL(6, 3))	AS hrs6_to_inplay_drift
			--,CAST((inp.odds_price_traded - hr1.odds_price_traded) / hr1.odds_price_traded AS DECIMAL(6, 3))	AS hr1_to_inplay_drift

			,CASE
				WHEN opn.odds_price_traded BETWEEN (hr8.odds_price_traded * 1.0/@drift_percent) AND (hr8.odds_price_traded * @drift_percent)
				THEN 'Not much drift'
				WHEN opn.odds_price_traded > hr8.odds_price_traded * @drift_percent
				THEN 'Drift down'
				WHEN opn.odds_price_traded < hr8.odds_price_traded * 1.0/@drift_percent
				THEN 'Drift up'
			END AS drift_desc
			,(hr8.odds_price_traded - opn.odds_price_traded) / opn.odds_price_traded AS drift_percent


INTO		dbo.bet_market_odds_drift_pre_kickoff
FROM		#pre_inplay_order_ids		pre
			LEFT OUTER JOIN
			dbo.bet_market_odds			opn
			ON pre.market_id = opn.market_id
			AND pre.runner_id = opn.runner_id
			AND pre.market_open_order = opn.matched_bets_order
			LEFT OUTER JOIN
			dbo.bet_market_odds			inp
			ON pre.market_id = inp.market_id
			AND pre.runner_id = inp.runner_id
			AND pre.market_inplay_order = inp.matched_bets_order
			LEFT OUTER JOIN
			dbo.bet_market_odds			hr8
			ON pre.market_id = hr8.market_id
			AND pre.runner_id = hr8.runner_id
			AND pre.market_8hrs_before_order = hr8.matched_bets_order
			LEFT OUTER JOIN
			dbo.bet_market_odds			hr1
			ON pre.market_id = hr1.market_id
			AND pre.runner_id = hr1.runner_id
			AND pre.market_1hr_before_order = hr1.matched_bets_order

-------------------------------------------------------------------------------------------------
-- End processing
-------------------------------------------------------------------------------------------------



--SELECT		*
--FROM		dbo.bet_market_odds_drift_pre_kickoff






END