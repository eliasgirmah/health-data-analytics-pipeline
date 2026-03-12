# 🏥 Health Data Analytics Pipeline (OLTP & OLAP Design)

## 📖 Project Overview
This project demonstrates the design and analysis of a health clinic database using **MySQL**. It focuses on transforming operational data (OLTP) into analytical insights (OLAP) to support health decision-making (e.g., HIV care cascade analysis).

## 🎯 Business Problem
Health clinics need to track patient outcomes (CD4 counts, Viral Loads) across different locations. The goal is to:
1. Store daily transactional data efficiently (**OLTP**).
2. Analyze clinic performance and patient risk levels (**OLAP**).
3. Identify clinics requiring additional resources based on average CD4 counts.

## 🛠️ Tech Stack
- **Database:** MySQL
- **Design:** Relational Model (Normalized) → Dimensional Modeling (Planned)
- **Analysis:** SQL (CTEs, Window Functions, Aggregates)
- **Visualization:** Apache Superset (In Progress)

## 🗄️ Database Design
### OLTP Schema (Normalized)
Designed to minimize redundancy for daily operations.
- **Tables:** `patients`, `visits`, `lab_results`
- **Relationships:** One-to-Many (Patient → Visits → Lab Results)

### OLAP Analysis (Aggregated)
Queries transform raw data into insights using:
- `GROUP BY` for clinic performance
- `CASE` statements for risk categorization
- `CTEs` for modular query design

## 📂 SQL Modules
| File | Description | Concepts Used |
|------|-------------|---------------|
| `01_create_schema.sql` | Defines tables & constraints | Primary Keys, Foreign Keys, Data Types |
| `02_insert_data.sql` | Populates synthetic health data | INSERT, Data Integrity |
| `03_analysis_queries.sql` | Analytical queries | JOINs, CTEs, HAVING, CASE |

## 📊 Key Insights Generated
1. **Clinic Performance:** Identified clinics with average CD4 counts < 400 (High Risk).
2. **Patient Risk Categorization:** Classified patients into 'High', 'Moderate', and 'Low' risk based on lab results.
3. **Regional Analysis:** Aggregated patient data by country and clinic location.

## 🚀 Future Improvements
- [ ] Implement **Star Schema** for faster OLAP queries.
- [ ] Build **Apache Superset** dashboard for visualization.
- [ ] Add **Apache Airflow** for pipeline orchestration.
- [ ] Implement **dbt** for transformation logic.

## 📬 Contact
- **LinkedIn:** [https://www.linkedin.com/in/elias-girma-155a09283/]
- **Twitter:** [https://x.com/EGHurisa]
- **Email:** [eliasgirma.b@gmail.com]
