CREATE TABLE [dbo].[odds_buckets] (
    [bucket_number]    BIGINT         NULL,
    [odds_rank]        BIGINT         NULL,
    [Home]             NUMERIC (8, 2) NULL,
    [Draw]             NUMERIC (8, 2) NULL,
    [Away]             NUMERIC (8, 2) NULL,
    [odds_bucket_desc] VARCHAR (20)   NULL
);

