CREATE TABLE [dbo].[back_test_loop_over_after_x_mins_by_goals_scored] (
    [test_proc_name]  VARCHAR (50)   NULL,
    [bet_selection]   VARCHAR (20)   NULL,
    [after_x_mins]    INT            NULL,
    [goals_at_x_mins] INT            NULL,
    [profit_loss]     NUMERIC (8, 2) NULL,
    [match_count]     INT            NULL,
    [win_count]       INT            NULL,
    [lose_count]      INT            NULL,
    [profit_per_game] NUMERIC (8, 2) NULL
);

