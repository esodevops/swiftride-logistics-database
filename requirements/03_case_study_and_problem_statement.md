# Case Study and Problem Statement

## Organization Overview

SwiftRide Logistics is a fast-growing logistics and delivery company operating across major cities in Nigeria.

The company handles:

- Customer orders
- Delivery operations
- Driver assignments
- Warehouse management
- Vehicle tracking
- Payments and invoices

As the business expanded, the company realized its manual record-keeping system could no longer support growing operational demands.

Management decided to build a centralized PostgreSQL database system to automate operations and improve reporting.

## Current Business Challenges

SwiftRide Logistics currently faces several business challenges:

- Duplicate customer records
- Delayed delivery tracking
- Missing payment information
- Poor relationship management between orders and drivers
- Inconsistent warehouse inventory records
- Slow reporting and operational inefficiencies
- Difficulty managing deleted records and dependencies

## Data Integrity Problems

The current process also creates relationship and consistency problems:

- Drivers sometimes get assigned to invalid orders.
- Orders remain even after customers are removed.
- Inventory records become inconsistent after updates.

## Required Solution

SwiftRide Logistics needs a robust relational database system with proper constraints, relationships, and cascading rules.

The database should:

- Maintain data integrity.
- Improve business operations.
- Prevent invalid records.
- Connect related business data correctly.
- Support operational reporting.
- Reduce manual record-keeping errors.

