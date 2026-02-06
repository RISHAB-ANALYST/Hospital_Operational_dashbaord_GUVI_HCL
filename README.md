# Hospital_Operational_dashbaord_GUVI_HCL
# 🏥 Hospital Operations Analytics Dashboard

## 📌 Problem Statement

Hospital operations teams in mid-sized multi-specialty hospital networks often struggle with fragmented data, delayed insights, and limited visibility into real-time resource utilization. This makes it difficult for administrators to manage patient flow, optimize staffing, reduce bottlenecks, and plan long-term capacity.

This project addresses that gap by designing and building an **interactive analytics dashboard** that enables hospital leadership and operations teams to **monitor, analyze, and optimize hospital performance** using standardized, interpretable KPIs.

---

## 🎯 Project Objective

To build an end-to-end analytics solution that provides **decision-makers and non-technical administrative staff** with:

* Clear visibility into hospital operations
* Actionable insights for short-term staffing and scheduling decisions
* Data-driven support for long-term capacity and infrastructure planning

---

## 🏗️ Solution Overview

The dashboard aggregates and analyzes operational data across a **mid-sized multi-specialty hospital network in India**, covering:

* Multiple hospital branches
* Core clinical departments
* Patient lifecycle from admission to discharge

The system supports **interactive drill-downs**, **cross-department comparisons**, and **time-based trend analysis** using simple visualizations and standardized healthcare metrics.

---

## 🧩 Key Stakeholders

* Hospital Administrators
* Operations Managers
* Capacity Planning Teams
* Department Heads (Clinical & Non-Clinical)

---

## 🏥 Departments Covered

* Cardiology
* Oncology
* Orthopedics
* Pediatrics
* Emergency
* General Medicine

---

## 📊 Key KPIs Tracked

### Patient Flow & Utilization

* **Average Length of Stay (ALOS)**
* **Patient Admission Count**
* **Patient Discharge Count**
* **Emergency vs Scheduled Admissions**
* **Readmission Rate (30-Day)**

### Capacity & Resource Utilization

* **Bed Occupancy Rate**
* **Doctor Utilization (% Time Booked)**
* **Procedure Volume by Department**

### Financial & Outcome Metrics

* **Cost per Patient**
* **Billing Breakdown (by procedure & department)**
* **Patient Outcome Classification**:

  * Recovered
  * Improved
  * Transferred
  * Deceased

---

## 📈 Analytics Capabilities

### Trend Analysis

* Daily
* Weekly
* Monthly
* Quarterly

### Comparative Analysis

* Cross-department comparison
* Hospital branch comparison
* Emergency vs elective workload comparison

### Operational Insights

* Identification of peak-hour congestion
* Detection of delayed discharges
* Highlighting departments under capacity stress
* Early signals for ICU beds, ventilator, and staffing needs

---

## 🔍 Drill-Down & Filters

Users can interactively drill down by:

* Hospital Branch
* Department
* Time Period
* Patient Demographics (age group, gender)

This allows both **high-level monitoring** and **deep operational investigation**.

---

## 🧠 Decision Support Use Cases

### Short-Term Decisions

* Adjust doctor rosters during peak hours
* Reallocate beds across departments
* Manage emergency department overload

### Long-Term Planning

* Capacity expansion planning
* Department-wise investment decisions
* Policy improvements to reduce readmissions and ALOS

---

## 🛠️ Tech Stack

* **Database**: PostgreSQL
* **Data Modeling**: Star/Snowflake schema (Facts & Dimensions)
* **Analytics Layer**: SQL-based KPI views
* **Visualization**: Power BI
* **Optional API Layer**: FastAPI (for KPI exposure & automation)

---

## 📐 Architecture Overview

```
ETL & KPI Logic (SQL / Python)
          ↓
PostgreSQL Analytics Schema
          ↓
Power BI Dashboard
```

---

## 📊 Dashboard Design Principles

* Simple, non-technical language
* Standardized healthcare KPIs
* Minimal cognitive load
* Clear visual hierarchy
* Executive-ready summaries

---

## 📁 Repository Structure

```
├── data/                 # Synthetic CSV datasets
├── schema/               # Database schema & table definitions
├── sql/                  # KPI queries & analytics views
├── dashboards/           # Power BI dashboard files
├── docs/                 # Architecture diagrams & KPI definitions
└── README.md             # Project documentation
```

---

## 🚀 Outcome

This project demonstrates the design and implementation of a **production-style hospital analytics system**, bridging:

* Data engineering
* Analytics modeling
* Business intelligence
* Healthcare operations understanding

It reflects real-world problem-solving expected from **Business Analysts, Product Analysts, and Analytics Engineers** working in healthcare and operations analytics domains.

---

## 📌 Future Enhancements

* Predictive modeling for bed demand
* Automated alerts for capacity thresholds
* Integration with real-time hospital systems
* Role-based dashboard access

---

## 👤 Author

**Rishab Tiwari**
