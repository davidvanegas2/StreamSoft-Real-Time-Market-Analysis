# StreamSoft: Real-Time Market Analysis Repository

Welcome to the Real-Time Stock Trading Data Analysis project repository! This comprehensive solution leverages cloud-native technologies and best practices in data engineering to enable efficient ingestion, processing, and analysis of stock market transactions.

## Table of Contents

<!-- TOC -->

- [StreamSoft: Real-Time Market Analysis Repository](#streamsoft-real-time-market-analysis-repository)
  - [Table of Contents](#table-of-contents)
  - [Architecture](#architecture)
  - [Introduction](#introduction)
  - [Problem Description](#problem-description)
    - [Client-Generated Data](#client-generated-data)
  - [Architecture Overview](#architecture-overview)
    - [Cloud Deployment](#cloud-deployment)
    - [Data Ingestion](#data-ingestion)
    - [Data Warehouse](#data-warehouse)
    - [Transformations](#transformations)
    - [Dashboard](#dashboard)
  - [Usage](#usage)
  - [Manual Steps for Setting up Metabase Visualizations](#manual-steps-for-setting-up-metabase-visualizations)
  <!-- TOC -->

## Architecture

![streamsoft drawio (4)](https://github.com/davidvanegas2/StreamSoft-Real-Time-Market-Analysis/assets/46963726/c4fb661a-2253-4273-ae7f-ad9837512fb2)

## Introduction

This repository presents a comprehensive solution for analyzing real-time stock trading data. By leveraging cloud-native technologies and best practices in data engineering, the project enables efficient ingestion, processing, and analysis of stock market transactions, facilitating data-driven decision-making processes.

## Problem Description

The project aims to address the challenge of processing and analyzing real-time stock trading data to derive actionable insights. With a focus on scalability, reliability, and performance, the solution enables near real-time analysis of stock market activities, empowering stakeholders to make informed decisions.

### Client-Generated Data

The client generates synthetic stock trading data using the [Mimesis](https://mimesis.name/en/master/) library to simulate real-world transactions. Each transaction record follows a predefined schema and includes the following fields:

```json lines
{"operation_id": "776ad7ac-f47f-4c5c-934b-d648c7729ea3", "person_name": "Keneth Reese", "symbol": "NOW", "timestamp": "2024-06-29 19:59:28", "exchange": "HKEX", "currency": "USD", "price": 880.91, "operation": "sale"}
{"operation_id": "ef6bc890-a1ed-4ac1-a957-9bb912f926ac", "person_name": "China Fernandez", "symbol": "CELP", "timestamp": "2024-02-25 03:21:42", "exchange": "NASDAQ", "currency": "USD", "price": 737.96, "operation": "sale"}
{"operation_id": "e9436eef-807c-43a1-ad80-1e0ac7e0a16d", "person_name": "Alonso Dean", "symbol": "PNRG", "timestamp": "2024-04-27 18:19:27", "exchange": "Euronext", "currency": "USD", "price": 1194.49, "operation": "purchase"}
{"operation_id": "e560d80f-710a-473f-aeb8-2269cd3a22fb", "person_name": "Loriann Huber", "symbol": "SMCP", "timestamp": "2024-03-02 02:10:36", "exchange": "JPX", "currency": "USD", "price": 599.81, "operation": "sale"}
{"operation_id": "f696029e-93b7-4165-9dbc-1317b9d4bf83", "person_name": "Tifany Hansen", "symbol": "WEX", "timestamp": "2024-01-15 21:12:07", "exchange": "NASDAQ", "currency": "USD", "price": 549.47, "operation": "purchase"}
{"operation_id": "dde79adf-abb2-4e48-9dda-f7dbc7dc820c", "person_name": "Caprice Travis", "symbol": "PIC.WS", "timestamp": "2024-12-11 03:04:27", "exchange": "JPX", "currency": "USD", "price": 854.02, "operation": "purchase"}
{"operation_id": "1b5aaca6-b0af-407e-9cfd-c72aceb46306", "person_name": "Jinny Oliver", "symbol": "ETN", "timestamp": "2024-07-16 07:37:29", "exchange": "NASDAQ", "currency": "USD", "price": 869.65, "operation": "sale"}
{"operation_id": "10034770-bfac-4853-8ed9-655eaa9d0877", "person_name": "Michiko Franco", "symbol": "EIGR", "timestamp": "2024-01-30 08:35:28", "exchange": "HKEX", "currency": "USD", "price": 735.25, "operation": "purchase"}
{"operation_id": "eda16834-e146-4e2e-ba02-39fd4b49f043", "person_name": "Dominick Bates", "symbol": "QTRH", "timestamp": "2024-03-25 05:46:15", "exchange": "Euronext", "currency": "USD", "price": 651.11, "operation": "sale"}
{"operation_id": "9d5a158e-b98e-4562-b084-a57b5136be89", "person_name": "Hank Joseph", "symbol": "MET^E", "timestamp": "2024-08-28 15:24:44", "exchange": "SSE", "currency": "USD", "price": 642.23, "operation": "purchase"}
```

These records represent a variety of stock trading transactions, including purchases and sales, conducted by fictitious individuals on different stock exchanges. The data is generated synthetically to mimic real-world trading activities, enabling realistic testing and analysis of the system's capabilities.

## Architecture Overview

### Cloud Deployment

The project is fully deployed on [Amazon Web Services (AWS)](https://aws.amazon.com/?nc2=h_lg) cloud infrastructure, utilizing [Terraform](https://developer.hashicorp.com/terraform?product_intent=terraform) for infrastructure as code (IaC) to provision and manage the necessary resources. This ensures consistency, repeatability, and scalability of the deployment process.

### Data Ingestion

- **Streaming**: [Kinesis Data Streams](https://aws.amazon.com/kinesis/data-streams/) is employed for real-time data ingestion, allowing seamless capture of stock trading transactions as they occur.
- **Batch**: Glue jobs are utilized for processing raw data in batch mode, providing flexibility in handling both streaming and batch data ingestion processes. This approach ensures robustness and reliability in data ingestion workflows.

### Data Warehouse

[Delta Lake](https://delta.io/) serves as the core data warehousing solution, offering ACID transactions and scalable storage for structured data. By leveraging Delta Lake's capabilities, the project ensures data integrity, reliability, and performance for analytical workloads.

### Transformations

Data transformations are orchestrated using PySpark within [Glue jobs](https://docs.aws.amazon.com/glue/latest/dg/what-is-glue.html). By leveraging the power of PySpark, the project enables efficient processing and analysis of the ingested data, including cleansing, enrichment, and aggregation tasks. This ensures that the data is optimized for downstream analytical tasks.

Furthermore, the data pipeline implements a [Medallion architecture](https://www.databricks.com/glossary/medallion-architecture) with the assistance of Delta Lake. The Medallon architecture enhances data reliability, scalability, and performance by incorporating Delta Lake's capabilities for transactional storage, schema enforcement, and time travel queries.

### Dashboard

A comprehensive dashboard is developed using [Metabase](https://www.metabase.com/), an open-source business intelligence tool. The dashboard features multiple tiles, each offering insights into various aspects of the stock trading data, including trends, patterns, and anomalies. By visualizing the data in a user-friendly manner, the dashboard empowers stakeholders to gain actionable insights and make informed decisions.
![](/Users/dvanegas/Desktop/Screenshot 2024-03-29 at 5.45.54 PM.png "Screenshot of EC2 instance running Metabase")

## Usage

To use this repository template, follow these steps:

1. **Clone the repository:**
   ```bash
   git clone https://github.com/davidvanegas2/streamsoft_market_analysis.git
   ```
2. **Navigate to the root directory of the cloned repository:**
   ```bash
   cd streamsoft_market_analysis
   ```
3. Ensure you have the following prerequisites installed on your machine:
   - [Poetry](https://python-poetry.org/docs/)
   - [pyenv](https://github.com/pyenv/pyenv)
   - [Terraform](https://developer.hashicorp.com/terraform?product_intent=terraform)
4. **Run the setup command:**

   ```bash
   make setup
   ```

   This command will initialize the repository, install the required Python version using pyenv, set up the local Python environment, verify the Python version, and install dependencies using Poetry.

5. **Run checks using pre-commit:**
   ```bash
   make check
   ```
   This command will run all checks configured with pre-commit, including linting and formatting using [ruff](https://github.com/astral-sh/ruff).
6. **Deploy the Terraform infrastructure:**
   Before running the deployment command, ensure that:

   - Your AWS account credentials are stored in the `~/.aws/credentials` file to allow Terraform to deploy resources.
   - You have previously manually created a key pair in EC2 with the name `keys_mac`.

   Now, run the following command to deploy the Terraform infrastructure:

   ```bash
   make deploy-terraform
   ```

   This command will initiate the deployment process, provisioning the necessary AWS resources for the project.

7. **Deploy all infrastructure and start sending messages to Kinesis:**
   To deploy all the infrastructure with Terraform and start sending messages to Kinesis, run the following command:
   ```bash
   make run-app
   ```
   This command will deploy all the required resources using Terraform and then execute a Python script to start sending messages to Kinesis, simulating real-time stock trading data.

## Manual Steps for Setting up Metabase Visualizations

Once all the infrastructure is deployed, follow these manual steps to set up the graphs in Metabase:

1. Access the EC2 Instance where Metabase is Mounted:
   - Note that Metabase is accessible via HTTP and not HTTPS.
   - Use the public IP address or domain name of the EC2 instance to access Metabase.
2. Access the Metabase Home with the Following Credentials:
   - User: `user@test.test`
   - Password: `MySecretPassword1`
   - These credentials are provided for demonstration purposes only and do not impact AWS security.
3. Create Visualizations:
   - Once logged into Metabase, navigate to the visualization creation interface.
   - Create visualizations based on the data available in the connected data sources.
   - Refer to the following images or guidelines for creating relevant visualizations:
     ![](/Users/dvanegas/Desktop/Screenshot 2024-03-29 at 5.47.28 PM.png "Create new question")
     ![](/Users/dvanegas/Desktop/Screenshot 2024-03-29 at 5.44.49 PM.png "Create another question")
   - Customize the visualizations according to your analysis requirements, incorporating relevant metrics, filters, and dimensions.
