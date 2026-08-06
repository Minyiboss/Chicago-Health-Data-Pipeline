CREATE OR REFRESH MATERIALIZED VIEW gold_age_analysis(
    season STRING COMMENT "Season of medical event",
    respiratory_category STRING COMMENT "Classification of respiratory diagnosis category",
    visit_type STRING COMMENT "Type of medical visit",
    demographic_group STRING COMMENT "Specific age range",
    avg_percent DECIMAL(9,6) COMMENT "Represents the average percentage of visits represented by the demographic group",
    max_percent DECIMAL(5,2) COMMENT "Represents the maximum percentage of visits represented by the demographic group",
    min_percent DECIMAL(5,2) COMMENT "Represents the minimum percentage of visits represented by the demographic group"

)
COMMENT "Aggregate data from the different age groups grouped by season, respiratory diagnosis, and visit type"
AS
SELECT
  season,
  respiratory_category,
  visit_type,
  demographic_group,
  AVG(percent) AS avg_percent,
  MAX(percent) AS max_percent,
  MIN(percent) AS min_percent
FROM silver_health
WHERE demographic_category = 'Age Group'
AND NOT demographic_group = 'Age Unknown'
GROUP BY demographic_group, season, respiratory_category, visit_type;
