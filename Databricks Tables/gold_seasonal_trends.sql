CREATE OR REFRESH MATERIALIZED VIEW gold_season_trends(
    event_year INT COMMENT "Year of medical event",
    event_season STRING COMMENT "Season of medical event",
    respiratory_category STRING COMMENT "Classification of respiratory diagnosis category",
    percent DECIMAL(5,2) COMMENT "Percentage of visits associated with the respiratory category during the time period"
)
COMMENT "Weekly repiratory illness trends by respiratory category"
AS
SELECT
  event_year,
  season as event_season,
  respiratory_category,
  percent
FROM silver_health
WHERE demographic_category = 'ALL' AND demographic_group = 'ALL';