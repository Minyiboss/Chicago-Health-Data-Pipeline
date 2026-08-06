CREATE OR REFRESH MATERIALIZED VIEW bronze_health
COMMENT "Raw health data from data.gov"
AS
SELECT *
FROM read_files(
    "/Volumes/personal_projects/chicago_health_data/chicago_raw_data",
    format => "csv",
    header => true
);