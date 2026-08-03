# E-Commerce Marketplace Analytics & Dashboard

End-to-end data analytics project on a Brazilian e-commerce marketplace dataset, covering data cleaning, exploratory SQL analysis, and an interactive Power BI dashboard for tracking sales, delivery, and customer satisfaction KPIs.

## 📊 Project Overview

This project analyzes multi-table e-commerce data (orders, customers, payments, products, sellers, reviews, and geolocation) to uncover sales trends, delivery performance, and customer behavior insights. The workflow spans the full analytics pipeline: **data cleaning (Python) → relational querying (MySQL) → business intelligence dashboard (Power BI)**.

## 🔑 Key Insights

- **137% YoY revenue growth** (Jan–Aug 2017 vs. Jan–Aug 2018)
- **97.02%** of orders were successfully delivered
- **6.77%** of delivered orders arrived later than their estimated delivery date
- Average customer review score: **4.09 / 5**
- **99,441 orders** placed by **96,096 unique customers** across **27 states** and **4,119 cities**
- Total transaction value: **~$16.01M**
- Credit card was the dominant payment method, used in **73.9%** of transactions

## 🛠️ Tools & Tech Stack

| Stage | Tool |
|---|---|
| Data Cleaning & Preprocessing | Python (Pandas) — `marketing_analysis.ipynb` |
| Data Storage & Querying | MySQL — `marketing_analysis.sql` |
| Dashboard & Visualization | Power BI — `marketing_analysis.pbix` |

## 📁 Repository Structure

```
├── marketing_analysis.ipynb     # Data cleaning & preprocessing notebook
├── marketing_analysis.sql       # SQL queries for business analysis
├── marketing_analysis.pbix        # Power BI dashboard
├── datasets/                    # Raw datasets
│   ├── customers (1).csv
│   ├── orders (1).csv
│   ├── order_items.csv
│   ├── order_reviews.csv
│   ├── payments.csv
│   ├── products (1).csv
│   ├── sellers.csv
│   └── geolocation.csv
├── cleaned-datasets/             # Datasets after Python cleaning step
│   ├── customers_cleaned.csv
│   ├── orders_cleaned.csv
│   ├── order_items_cleaned.csv
│   ├── order_reviews_cleaned.csv
│   ├── payments_cleaned.csv
│   ├── products_cleaned.csv
│   ├── sellers_cleaned.csv
│   └── geolocation_cleaned.csv
├── LICENSE
└── README.md
```

## 📈 Analysis Highlights

The SQL analysis (see `marketing_analysis.sql`) answers business questions including:

- Order volume trends over time and monthly seasonality
- Regional (state/city) distribution of customers and revenue
- Delivery time and delay analysis by state and product category
- Revenue breakdown by product category, seller, and payment type
- Customer lifetime value and top spenders
- Relationship between payment method and customer satisfaction
- Order status distribution (delivered, canceled, shipped, etc.)

The Power BI dashboard visualizes these findings interactively, allowing filtering by time period, region, and product category.

## 🚀 How to Reproduce

1. Raw CSV files (`datasets/`) are processed via `marketing_analysis.ipynb`, which handles cleaning, deduplication, and feature engineering, producing the output files in `cleaned-datasets/`.
2. Load the cleaned CSV files (`cleaned-datasets/`) into a MySQL database named `marketing_analysis`.
3. Run `marketing_analysis.sql` against the cleaned tables to generate the analysis views.
4. Open `marketing_analysis.pbix` in Power BI Desktop to explore the interactive dashboard, which is built on the cleaned data.

## 📌 Dataset

The dataset is a Brazilian e-commerce marketplace dataset spanning multiple relational tables (orders, customers, order items, payments, reviews, products, sellers, and geolocation).

---

*Feel free to reach out with questions or suggestions for improving this analysis.*
