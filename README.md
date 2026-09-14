# SHOWROOM ANALYTICS

An end-to-end data analysis project focused on understanding showroom sales performance, revenue realization, product performance, branch performance, and customer transaction patterns.

The project uses **Excel, SQL, Python, and Power BI** to transform raw transaction data into actionable business insights.

---

## Project Overview

A showroom business reported strong sales performance, but management needed to understand how much revenue was actually realized and what factors were driving sales performance.

This analysis explores the sales transaction data to answer key business questions around revenue, products, branches, customers, and transaction behavior.

### Business Questions

* How much revenue was actually realized from completed transactions?
* What products and categories contribute most to sales?
* Which branches perform best?
* What are the main customer and transaction patterns?
* How do sales trends change over time?
* How does **Trade-In** usage vary across transactions and branches?
* What business actions can be recommended based on the findings?

---

## Analytical Workflow

```text
Raw Data
   ↓
Excel
Data Preparation & Validation
   ↓
BigQuery SQL
Data Transformation & Analysis
   ↓
Python
Exploratory Data Analysis
   ↓
Power BI
Dashboard & Business Insights
```

---

## Tools & Technologies

| Tool                      | Purpose                                              |
| ------------------------- | ---------------------------------------------------- |
| **Microsoft Excel**       | Data preparation, formatting, and initial validation |
| **Google BigQuery / SQL** | Data transformation and analytical queries           |
| **Python**                | Exploratory Data Analysis and visualization          |
| **Power BI**              | Interactive dashboard and business reporting         |

### Python Libraries

* Pandas
* Matplotlib
* Seaborn

---

## Dataset

The dataset contains showroom sales transaction records with information related to:

* Transaction details
* Customer information
* Product and category
* Branch
* Sales date
* Payment type
* Trade-In status
* Transaction status
* Quantity
* Revenue

Before analysis, the dataset was checked for data quality issues including missing values, duplicate records, inconsistent categories, date formatting, and transaction status.

---

## Data Preparation

Several preparation steps were performed before analysis:

### Date Formatting

Converted text-formatted dates into standardized date values.

### Trade-In Classification

Created a `Trade-In Status` field based on the payment type.

* `Cash + Trade In` → Trade In
* `Kredit + Trade In` → Trade In
* Other payment types → Non Trade In

### Data Validation

Validated transaction status, numerical values, dates, and revenue-related fields to ensure the dataset was ready for analysis.

### Data Structuring

Prepared categorical and analytical fields for SQL, Python, and Power BI analysis.

---

## Analysis

### 01 — Revenue Realization

Evaluated reported sales versus completed transactions to understand actual revenue realization.

Key considerations include:

* Completed transactions
* Cancelled transactions
* Refunded transactions
* Revenue realization
* Completion rate

### 02 — Product & Branch Performance

Analyzed sales performance across products, categories, and branches.

Focus areas include:

* Units sold
* Revenue contribution
* Top-performing products
* Category performance
* Branch performance

### 03 — Customer & Transaction Patterns

Explored customer behavior and transaction characteristics.

Focus areas include:

* Customer transactions
* Payment methods
* Trade-In usage
* Transaction volume
* Customer purchasing patterns

### 04 — Sales Trends

Analyzed sales performance over time to identify changes in transaction volume and revenue.

---

## Dashboard

The final analysis is presented through an interactive **Power BI dashboard**, providing a consolidated view of showroom sales performance.

> Dashboard preview will be added here.

---

## Key Findings

Key findings and business recommendations will be added after the analysis is finalized.

> **Note:** This section will be updated based on the final SQL, Python, and Power BI results.

---

## Project Structure

```text
showroom-analytics/
│
├── data/
│   └── README.md
│
├── sql/
│   └── showroom_analysis.sql
│
├── python/
│   └── showroom_eda.ipynb
│
├── powerbi/
│   └── showroom_dashboard.pbix
│
├── images/
│   └── dashboard-preview.png
│
└── README.md
```

---

## Outcome

This project demonstrates an end-to-end **Data Analyst workflow**, from data preparation and SQL analysis to exploratory analysis and dashboard development.

The analysis aims to translate transaction data into clear business insights that can support decisions related to **revenue, products, branches, customers, and sales performance**.

---

## Author

**Aulia Azzahra**

Data Analyst Portfolio Project · 2026
