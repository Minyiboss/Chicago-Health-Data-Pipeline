CREATE OR REFRESH MATERIALIZED VIEW silver_health(
    event_year INT COMMENT "Year of medical event",
    event_month INT COMMENT "Month of medical event",
    event_week INT COMMENT "Week of medical event",
    season STRING COMMENT "Season of medical event",
    data_source STRING COMMENT "Source of data",
    essence_category STRING COMMENT "Surveillance definition used to classify the health event",
    respiratory_category STRING COMMENT "Classification of respiratory diagnosis category",
    visit_type STRING COMMENT "Category of visit",
    demographic_category STRING COMMENT "Type of demographic",
    demographic_group STRING COMMENT "Specific demographic group within the category",
    percent DECIMAL(5,2) COMMENT "Percentage of visits represented by the demographic group"
)
COMMENT "Cleaned health surveillance data"
AS
SELECT
    YEAR(week_start) AS event_year,
    MONTH(week_start) AS event_month,
    week AS event_week,
    season,
    data_source,
    essence_category,
    respiratory_category,
    visit_type,
    demographic_category,
    demographic_group,
    CAST(REPLACE(percent, '%', '') AS DECIMAL(5,2)) AS percent
FROM bronze_health;