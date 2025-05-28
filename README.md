# Star Schema Assignment

This project demonstrates the design of a star schema for a clinical data warehouse. It was completed as part of a cloud computing course assignment.

## Project Contents

- **Assignment_1.sql** – SQL script for creating the dimension and fact tables, with appropriate primary and foreign key constraints.
- **schema_diagram.pdf** – Visual diagram of the schema, showing relationships between fact and dimension tables.

## Schema Overview

The schema includes:
- 6 dimension tables:
  - `dim_patient`
  - `dim_provider`
  - `dim_procedure`
  - `dim_lab`
  - `dim_diagnosis`
  - `dim_time`
- 1 fact table:
  - `fact_visits`

The schema supports clinical analytics such as procedure frequency, lab test occurrence, and diagnosis trends.

## Tools Used

- SQL (MySQL)
- MySQL Workbench

## Purpose

This project simulates the backend design for a clinical data warehouse, where dimensional modeling enables efficient querying and reporting on healthcare visits.
