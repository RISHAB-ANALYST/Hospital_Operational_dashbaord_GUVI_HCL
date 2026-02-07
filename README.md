# Hospital Operational Dashboard - Analytics & BI Project

## 📊 Project Overview
A comprehensive hospital analytics solution featuring a dimensional data warehouse, ETL processes, and interactive Power BI dashboards for operational insights and KPI tracking.

**Project Type:** Healthcare Analytics & Business Intelligence  
**Tools Used:** SQL, Python, Power BI, PostgreSQL/MySQL  
**Project Timeline:** February 2026

---

## 🎯 Business Objectives

- Track and analyze hospital operational metrics (bed occupancy, patient admissions, billing)
- Monitor doctor workload and productivity
- Analyze patient outcomes and treatment effectiveness
- Identify peak hours and resource utilization patterns
- Enable data-driven decision making for hospital management

---

## 📁 Project Structure
```
Hospital_Operational_dashboard_project/
├── BI_visualization/
│   └── Hospital_Operational_dashboard.pbix    # Power BI Dashboard
├── Hospital_data_generation_script/
│   └── Data_generation.ipynb                  # Python script for sample data generation
├── SQLs/
│   ├── create_table_schema/
│   │   └── DB_table_created.sql              # Database schema creation
│   ├── dim_tables/                           # Dimension tables (5 tables)
│   │   ├── dim_branch.sql
│   │   ├── dim_date.sql
│   │   ├── dim_department.sql
│   │   ├── dim_doctor.sql
│   │   └── dim_patient.sql
│   ├── fact_tables/                          # Fact tables (5 tables)
│   │   ├── fact_admissions.sql
│   │   ├── fact_bed_occupancy.sql
│   │   ├── fact_doctor_workload.sql
│   │   ├── fact_financials.sql
│   │   └── fact_procedures.sql
│   ├── kpi_precal/                           # Pre-calculated KPI views
│   │   ├── view_kpi_summary.sql
│   │   ├── view_outcome_detail.sql
│   │   └── view_peak_hours.sql
│   ├── import_csv_data.sql                   # Data import script
│   └── Checking_data.sql                     # Data validation queries
├── hospital_data/                            # CSV data files (~4.9 MB)
│   ├── admission.csv
│   ├── bed_occupancy.csv
│   ├── billing.csv
│   ├── branch.csv
│   ├── department.csv
│   ├── doctor.csv
│   ├── doctor_workload.csv
│   ├── outcome.csv
│   ├── patient.csv
│   ├── procedure.csv
│   └── procedure_clean.csv
└── requirement_docs/
    ├── Dashboard Requirement.pdf             # Business requirements
    └── Data requirement document.pdf         # Data specifications
```

---

## 🗄️ Data Warehouse Architecture

### Dimensional Model (Star Schema)

#### **Dimension Tables**
| Table | Description | Key Attributes |
|-------|-------------|----------------|
| `dim_branch` | Hospital branch master data | Branch ID, Name, Location |
| `dim_date` | Date dimension for time analysis | Date, Day, Month, Quarter, Year |
| `dim_department` | Department hierarchy | Dept ID, Name, Type |
| `dim_doctor` | Doctor profiles | Doctor ID, Name, Specialization |
| `dim_patient` | Patient demographics | Patient ID, Age, Gender, Location |

#### **Fact Tables**
| Table | Description | Metrics |
|-------|-------------|---------|
| `fact_admissions` | Patient admission events | Admission count, Duration |
| `fact_bed_occupancy` | Daily bed utilization | Occupancy rate, Available beds |
| `fact_doctor_workload` | Doctor productivity | Patients handled, Hours worked |
| `fact_financials` | Billing and revenue | Total charges, Payments received |
| `fact_procedures` | Medical procedures performed | Procedure count, Success rate |

#### **KPI Views**
- **view_kpi_summary**: Executive dashboard metrics
- **view_outcome_detail**: Patient outcome analysis
- **view_peak_hours**: Peak capacity and resource usage

---

## 📈 Key Performance Indicators (KPIs)

1. **Operational Efficiency**
   - Average bed occupancy rate
   - Patient admission trends
   - Peak hours analysis

2. **Clinical Performance**
   - Patient outcome rates
   - Procedure success rates
   - Average length of stay

3. **Financial Metrics**
   - Revenue per department
   - Billing vs collections
   - Cost per patient

4. **Resource Utilization**
   - Doctor workload distribution
   - Department capacity utilization
   - Bed turnover rate

---

## 🚀 Setup Instructions

### Prerequisites
- **Database:** PostgreSQL 12+ or MySQL 8+
- **Python:** 3.8+ with pandas, numpy
- **Power BI Desktop:** Latest version
- **Git:** For version control

### Installation Steps

#### 1. Clone the Repository
```bash
git clone https://github.com/RISHAB-ANALYST/Hospital_Operational_dashbaord_GUVI_HCL.git
cd Hospital_Operational_dashbaord_GUVI_HCL
```

#### 2. Database Setup

**Create Database Schema:**
```sql
-- Connect to your database
psql -U username -d database_name

-- Run schema creation
\i SQLs/create_table_schema/DB_table_created.sql
```

**Import CSV Data:**
```sql
\i SQLs/import_csv_data.sql
```

**Create Dimension Tables:**
```sql
\i SQLs/dim_tables/dim_branch.sql
\i SQLs/dim_tables/dim_date.sql
\i SQLs/dim_tables/dim_department.sql
\i SQLs/dim_tables/dim_doctor.sql
\i SQLs/dim_tables/dim_patient.sql
```

**Create Fact Tables:**
```sql
\i SQLs/fact_tables/fact_admissions.sql
\i SQLs/fact_tables/fact_bed_occupancy.sql
\i SQLs/fact_tables/fact_doctor_workload.sql
\i SQLs/fact_tables/fact_financials.sql
\i SQLs/fact_tables/fact_procedures.sql
```

**Create KPI Views:**
```sql
\i SQLs/kpi_precal/view_kpi_summary.sql
\i SQLs/kpi_precal/view_outcome_detail.sql
\i SQLs/kpi_precal/view_peak_hours.sql
```

#### 3. Data Validation
```sql
\i SQLs/Checking_data.sql
```

#### 4. Open Power BI Dashboard
- Open `BI_visualization/Hospital_Operational_dashboard.pbix`
- Update data source connection to your database
- Refresh data to see visualizations

---

## 💾 Dataset Information

**Total Data Size:** ~4.9 MB  
**Number of Tables:** 10 CSV files

| File | Size | Records (approx) |
|------|------|------------------|
| admission.csv | 626 KB | ~10,000 admissions |
| bed_occupancy.csv | 1,550 KB | ~25,000 records |
| billing.csv | 146 KB | ~2,500 bills |
| branch.csv | 1 KB | 5 branches |
| department.csv | 1 KB | 15 departments |
| doctor.csv | 2 KB | 50 doctors |
| doctor_workload.csv | 255 KB | ~4,000 records |
| outcome.csv | 159 KB | ~2,500 outcomes |
| patient.csv | 209 KB | ~3,500 patients |
| procedure.csv | 929 KB | ~15,000 procedures |

---

## 🔍 Key Features

✅ **Dimensional Data Warehouse** - Star schema design for optimal query performance  
✅ **ETL Pipeline** - Automated data import and transformation  
✅ **Pre-calculated KPIs** - Materialized views for fast dashboard rendering  
✅ **Data Quality Checks** - Validation scripts for data integrity  
✅ **Interactive Dashboard** - Power BI visualizations for insights  
✅ **Scalable Architecture** - Designed for production deployment  

---

## 📊 Dashboard Highlights

The Power BI dashboard includes:
- **Executive Summary**: High-level KPIs and trends
- **Operational Metrics**: Bed occupancy, admissions, peak hours
- **Clinical Analytics**: Patient outcomes, procedure success rates
- **Financial Overview**: Revenue trends, billing analysis
- **Resource Management**: Doctor workload, department utilization

---

## 🛠️ Technologies Used

| Technology | Purpose |
|------------|---------|
| **SQL** | Data warehousing, ETL, queries |
| **Python** | Data generation, preprocessing |
| **PostgreSQL/MySQL** | Relational database |
| **Power BI** | Business intelligence dashboards |
| **Git** | Version control |
| **Jupyter Notebook** | Data exploration and scripting |

---

## 📚 Documentation

- **Dashboard Requirements:** `requirement_docs/Dashboard Requirement.pdf`
- **Data Specifications:** `requirement_docs/Data requirement document.pdf`
