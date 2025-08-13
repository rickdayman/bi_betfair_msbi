



CREATE VIEW [pbi].[bet_market_odds]
AS

-------------------------------------------------------------------------------------------------
-- Processing
-------------------------------------------------------------------------------------------------

SELECT		bmo.bet_market_odds_id
			,bmo.market_id
			,bmo.odds_timestamp
			,bmo.odds_timestamp_display_id
			,bmo.odds_timestamp_display
			,bmo.market_status
			,bmo.market_in_play
			,bmo.bet_selection_id
			,bmo.runner_id
			,bmo.runner_name
			,CASE
				WHEN bmo.runner_name = evt.home_team THEN 'Home'
				WHEN bmo.runner_name = evt.away_team THEN 'Away'
				ELSE bmo.runner_name
			END AS runner_name_display
			,bmo.odds_price_traded
			,bmo.odds_price_traded_lay
			,bmo.matched_bets_order
			,bmr.market_result
-- SELECT COUNT(*)
FROM		dbo.bet_market_odds		bmo
			INNER JOIN
			dbo.bet_markets			bmt
			ON bmo.market_id = bmt.market_id
			INNER JOIN
			dbo.event_details		evt
			ON bmt.event_id = evt.event_id
			INNER JOIN
			dbo.bet_market_results	bmr
			ON bmo.market_id = bmr.market_id
			AND bmo.runner_id = bmr.runner_id
WHERE		bmo.market_status <> 'SUSPENDED'
AND			evt.league_name NOT IN ('Lower leagues', 'Other Competitions')

-------------------------------------------------------------------------------------------------
-- End
-------------------------------------------------------------------------------------------------
