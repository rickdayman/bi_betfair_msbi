CREATE TABLE [dbo].[bet_selection] (

	[bet_selection_id] smallint NULL, 
	[market_type] varchar(20) NULL, 
	[selection_desc] varchar(15) NULL, 
	[is_drift_down] smallint NULL, 
	[is_drift_up] smallint NULL
);