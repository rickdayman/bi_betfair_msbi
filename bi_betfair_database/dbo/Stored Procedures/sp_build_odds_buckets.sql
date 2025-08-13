CREATE PROCEDURE [dbo].[sp_build_odds_buckets] (@league_name VARCHAR(50) = NULL)
AS
BEGIN

SET NOCOUNT ON

-------------------------------------------------------------------------------------------------
-- Create odd_buckets
-------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS dbo.odds_buckets

;WITH ODDSBUCKET AS
(
SELECT		NTILE(7) OVER (ORDER BY Home, Draw, Away) AS bucket_number
			,ROW_NUMBER() OVER (ORDER BY Home, Draw, Away) AS odds_rank
			,Home
			,Draw
			,Away
FROM		(SELECT		DISTINCT
						Home
						,Draw
						,Away
			FROM		dbo.event_odds		odd
						INNER JOIN
						dbo.event_details	evt
						ON evt.event_id = odd.event_id
			WHERE		Home IS NOT NULL
			AND			Draw IS NOT NULL
			AND			Away IS NOT NULL
			AND			evt.league_name = ISNULL(@league_name, evt.league_name)
			) d
)

SELECT		bucket_number
			,odds_rank
			,Home
			,Draw
			,Away
			,CASE
				WHEN bucket_number = 1 THEN 'Home big favourite'
				WHEN bucket_number = 2 THEN 'Home favourite'
				WHEN bucket_number = 3 THEN 'Home small favourite'
				WHEN bucket_number = 4 THEN 'Even'
				WHEN bucket_number = 5 THEN 'Away small favourite'
				WHEN bucket_number = 6 THEN 'Away favourite'
				WHEN bucket_number = 7 THEN 'Away big favourite'
			END AS odds_bucket_desc
INTO		dbo.odds_buckets
FROM		ODDSBUCKET

-------------------------------------------------------------------------------------------------
-- End processing
-------------------------------------------------------------------------------------------------

END