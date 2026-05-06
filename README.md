# 🚀 End-to-End Data Pipeline using DBT

## 📌 Overview

This project demonstrates an end-to-end data pipeline built using modern data stack tools. It integrates data from multiple sources, transforms it using dbt, and enables business insights through analytics.

---

## 🏗️ Architecture

Fivetran → Snowflake (Raw Layer) → DBT (Transformations) → Power BI (Visualization)

---

## ⚙️ Tech Stack

* **Data Ingestion**: Fivetran
* **Data Warehouse**: Snowflake
* **Transformation**: DBT
* **Visualization**: Power BI

---

## 🧱 Data Model (Medallion Architecture)

* **Bronze Layer (Raw)**

  * Source data ingested via Fivetran

* **Silver Layer (Intermediate)**

  * Data cleaning and transformation
  * Standardized schemas

* **Gold Layer (Marts)**

  * Business-level aggregations
  * Reporting-ready datasets

---

## 📊 Key Models

* `agg_pipeline_summary.sql` → Pipeline performance metrics
* `agg_pipeline_by_stage.sql` → Stage-wise opportunity breakdown
* `agg_product_intent_shift.sql` → Product transition insights
* `agg_pipeline_quality.sql` → Pipeline health metrics

---

## 📈 Use Case

This solution enables:

* Tracking sales pipeline performance
* Identifying product movement trends
* Monitoring deal progression across stages
* Improving decision-making with analytics

---

## 🔄 How to Run

```bash
dbt run
dbt test
```

---

## 💡 Key Highlights

* Built scalable DBT models using modular architecture
* Implemented medallion data layering (Bronze → Silver → Gold)
* Designed analytics-ready datasets for business users
* Integrated multiple data sources into a unified model

---

## 👨‍💻 Author

**Gaurav Srivastava**
Principal BI Analyst | Data Engineering | Analytics

---
