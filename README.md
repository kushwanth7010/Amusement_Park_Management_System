# Amusement Park Management System — DBMS Portfolio Project

This repository contains the original [project report](Amusement_Park_Management_System.pdf) and a **separate runnable SQLite companion prototype**. The companion demonstrates relational design, ticketing, ride operations, maintenance, staffing, food sales, foreign-key integrity, operational checks and simple revenue reporting. It is an educational sample, **not** a deployed park-management service or a verified page-for-page implementation of the PDF.

## Run the companion prototype

Requires Python 3.10+; it uses only the standard library.

```bash
python build_demo.py
python -m unittest discover -s tests -v
```

The first command recreates `amusement_park_demo.sqlite` with **fictional** sample records. Run the tests to verify database relationships, ticket-to-customer consistency, date validity, ride availability, food-stock controls and daily-revenue reconciliation.

To inspect the database in an SQLite application, open `amusement_park_demo.sqlite`. Example analysis:

```sql
SELECT * FROM daily_revenue ORDER BY sale_date;
SELECT r.ride_name, r.ride_status, COUNT(v.visit_id) AS visits
FROM rides r
LEFT JOIN ride_visits v ON v.ride_id=r.ride_id
GROUP BY r.ride_id, r.ride_name, r.ride_status;
```

## Relational design

- **Customers, ticket types and tickets:** record fictional visitors and dated admission tickets.
- **Zones and rides:** identify ride locations, capacity, height limits and operating status.
- **Departments, employees and ride staff shifts:** organize workforce assignments.
- **Ride visits and maintenance:** record visits with a valid customer ticket and keep inspection history.
- **Food items and purchases:** record illustrative sales and prevent purchases that exceed recorded stock.
- **Daily revenue:** a SQL view summarizes the sample ticket and food revenue.

`sql/schema.sql` creates tables, keys, indexes through SQLite constraints, safety triggers and the revenue view. `sql/sample_data.sql` supplies the example rows. The companion is designed to avoid unnecessary duplicate descriptive fields; it is not a formal proof that every entity in the PDF is in BCNF.

## Repository contents

```text
Amusement_Park_Management_System.pdf   Original project report
sql/schema.sql                      SQLite companion schema and triggers
sql/sample_data.sql                 Fictional demonstration records
build_demo.py                       Creates sample .sqlite database
tests/test_database.py              Automated integrity and business-rule tests
.github/workflows/tests.yml         GitHub Actions validation
```

## Limitations

The companion is deliberately small: it has no authentication, live payment processing, live queue/capacity tracking, real safety certification, production audit logs or web interface. Height restrictions are stored as metadata but are **not enforced** because the demonstration does not capture verified rider heights. Operational deployment would require a fuller application and legal/safety review. All visitor and employee names in the seed dataset are fictional.
