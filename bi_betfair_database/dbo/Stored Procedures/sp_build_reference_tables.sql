CREATE PROCEDURE [dbo].[sp_build_reference_tables]
AS
BEGIN

SET NOCOUNT ON

-------------------------------------------------------------------------------------------------
-- Processing
-------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS dbo.bet_spread_points

SELECT		1 AS bet_spread_point
INTO		dbo.bet_spread_points
UNION SELECT 2
UNION SELECT 3
UNION SELECT 4
UNION SELECT 5
UNION SELECT 6

-------------------------------------------------------------------------------------------------
-- End processing
-------------------------------------------------------------------------------------------------

END