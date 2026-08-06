# Chicago Health Surveillance Pipeline

A Databricks Lakehouse pipeline that ingests Chicago respiratory illness surveillance data from [data.gov](https://data.gov) and transforms it through a medallion architecture (Bronze → Silver → Gold) for trend and demographic analysis, with a Power BI dashboard on top of the gold layer.

## Overview

The pipeline tracks emergency department visits and hospital admissions related to respiratory conditions such as influenza, RSV, COVID-19, ILI, and broad acute respiratory illness. Cleaned and aggregated tables feed a Power BI report for analysis by week, season, age group, and race/ethnicity.

## Architecture

```
CSV (Volumes) → bronze_health → silver_health → gold_* views → Power BI
```

| Layer | View | Description |
| --- | --- | --- |
| **Bronze** | `bronze_health` | Raw CSV ingest from Unity Catalog Volumes |
| **Silver** | `silver_health` | Typed, cleaned surveillance records |
| **Gold** | `gold_health_trends` | Weekly respiratory trends (all demographics) |
| **Gold** | `gold_season_trends` | Seasonal respiratory trends (all demographics) |
| **Gold** | `gold_age_analysis` | Age-group aggregates by season, diagnosis, and visit type |
| **Gold** | `gold_race_analysis` | Race/ethnicity aggregates by season, diagnosis, and visit type |

All tables are defined as Databricks **materialized views** (`CREATE OR REFRESH MATERIALIZED VIEW`).

## Project Structure

```
Chicago Health/
├── CSV Files/                          # Exported gold-layer datasets
│   ├── Chicago Health Weeks.csv
│   ├── Chicago Health Seasonal.csv
│   ├── Chicago Health Age.csv
│   └── Chicago Health Race.csv
├── Databricks Tables/                  # Pipeline DDL
│   ├── bronze_health.sql
│   ├── silver_health.sql
│   ├── gold_health_trends.sql
│   ├── gold_seasonal_trends.sql
│   ├── gold_age_analysis.sql
│   └── gold_race_analysis.sql
├── Power BI/                           # Dashboard and screenshots
│   ├── Dashboard.pbix
│   ├── Health Trends Screenshot.png
│   └── Demographic Trends Screenshot.png
└── README.md
```

## Data Flow

### Bronze — `bronze_health`

Reads raw CSV files from a Unity Catalog Volume:

```sql
/Volumes/personal_projects/chicago_health_data/chicago_raw_data
```

### Silver — `silver_health`

Cleans and standardizes fields:

- Derives `event_year` and `event_month` from `week_start`
- Retains week, season, source, ESSENCE category, respiratory category, and visit type
- Parses `percent` by stripping the `%` suffix and casting to `DECIMAL(5,2)`

### Gold — analytics views

| View | Filter / logic | Output |
| --- | --- | --- |
| `gold_health_trends` | `demographic_category = 'ALL'` | Year, week, respiratory category, percent |
| `gold_season_trends` | `demographic_category = 'ALL'` | Year, season, respiratory category, percent |
| `gold_age_analysis` | `demographic_category = 'Age Group'` (excludes `Age Unknown`) | Avg / max / min percent by season, diagnosis, visit type, age group |
| `gold_race_analysis` | `demographic_category = 'Race/Ethnicity'` | Avg / max / min percent by season, diagnosis, visit type, race |

## Key Dimensions

- **Respiratory categories:** Broad Acute Respiratory, Influenza, RSV, COVID-19, ILI, and related ESSENCE classifications
- **Visit types:** ED Visits, Admissions
- **Demographics:** Age groups (e.g. `00_04`, `18_44`) and race/ethnicity groups
- **Time:** Week, month, year, and respiratory season (e.g. `2023-2024`)

## Prerequisites

- Databricks workspace with Unity Catalog enabled
- Volume path populated with the source CSV files:
  `/Volumes/personal_projects/chicago_health_data/chicago_raw_data`
- Permission to create/refresh materialized views in the target catalog/schema

## Setup

1. Upload the source CSVs into the Unity Catalog Volume above (or update the path in `bronze_health.sql`).
2. Run the SQL scripts in order:
   1. `bronze_health.sql`
   2. `silver_health.sql`
   3. `gold_health_trends.sql`
   4. `gold_seasonal_trends.sql`
   5. `gold_age_analysis.sql`
   6. `gold_race_analysis.sql`
3. Refresh the materialized views as new source data arrives.

## Power BI Dashboard

The gold views are visualized in `Power BI/Dashboard.pbix`, with pages for time-based trends and demographic breakdowns.

### Health trends over time (2015–2026)

Seasonal and weekly line charts of visit share by respiratory category, with slicers for category and week year.

![Chicago Health Data Over Time](Power%20BI/Health%20Trends%20Screenshot.png)

### Demographic trends

Stacked bar charts comparing average visit share by age group and race/ethnicity across respiratory categories, with slicers for category and season.

![Chicago Health Data By Demographic](Power%20BI/Demographic%20Trends%20Screenshot.png)

## Exported CSVs

The files under `CSV Files/` are sample exports of the gold views for offline review or dashboarding:

| File | Source view |
| --- | --- |
| `Chicago Health Weeks.csv` | `gold_health_trends` |
| `Chicago Health Seasonal.csv` | `gold_season_trends` |
| `Chicago Health Age.csv` | `gold_age_analysis` |
| `Chicago Health Race.csv` | `gold_race_analysis` |

## Notes

- Source data originates from public Chicago health surveillance datasets published on data.gov.
- Gold trend views intentionally restrict to `ALL` demographics so visit shares are not double-counted across groups.
- Age analysis excludes `Age Unknown` to keep aggregates focused on known age bands.
