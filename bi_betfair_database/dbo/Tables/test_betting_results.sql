CREATE TABLE [dbo].[test_betting_results] (
    [test_proc_name] VARCHAR (50)   NULL,
    [bet_selection]  VARCHAR (20)   NULL,
    [after_x_mins]   INT            NULL,
    [league_name]    VARCHAR (50)   NULL,
    [odds_at_end]    DECIMAL (6, 2) NULL,
    [profit_loss]    DECIMAL (6, 2) NULL,
    [match_count]    INT            NULL,
    [win_count]      INT            NULL,
    [lose_count]     INT            NULL
);

