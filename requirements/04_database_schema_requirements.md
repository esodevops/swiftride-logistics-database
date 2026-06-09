# Database Schema Requirements

## Architectural Overview

The SwiftRide database follows a relational database architecture where operational data is connected through primary and foreign key relationships.

Foreign keys enforce valid relationships between tables and preserve referential integrity.

## Core Relationships

### One-to-Many Relationships

- One customer can have many orders.
- One driver can handle many deliveries.
- One warehouse can store many inventory records.

### Many-to-One Relationships

- Many orders belong to one customer.
- Many deliveries can use one vehicle.

## Operations Schema

The `operations` schema manages the core business activities and logistics transactions of SwiftRide Logistics.

It should:

- Store operational business tables such as customers, orders, and deliveries.
- Handle customer order processing.
- Support delivery tracking activities.
- Maintain relationships between customers, orders, drivers, and vehicles using foreign keys.
- Support day-to-day logistics operations.
- Support delivery workflow management.
- Demonstrate joins, cascade operations, and referential integrity.

Expected tables include:

- `operations.customers`
- `operations.orders`
- `operations.deliveries`

## Fleet Schema

The `fleet` schema manages transportation resources used for deliveries.

It should:

- Store fleet-related tables such as drivers and vehicles.
- Track driver information, including license numbers, contact details, and work status.
- Maintain vehicle records such as plate numbers, vehicle types, and carrying capacities.
- Help monitor delivery assignments.
- Help monitor fleet utilization across the logistics system.
- Demonstrate constraints, validations, and one-to-many relationships in PostgreSQL.

Expected tables include:

- `fleet.drivers`
- `fleet.vehicles`

## Warehouse Schema

The `warehouse` schema handles inventory and warehouse management operations.

It should:

- Store warehouse and inventory tables.
- Track product quantities.
- Track stock availability across multiple warehouse locations.
- Support inventory monitoring.
- Support low-stock analysis for business decision-making.
- Maintain relationships between warehouses and inventory items using foreign keys.
- Demonstrate inventory management concepts and relational database organization.

Expected tables include:

- `warehouse.warehouses`
- `warehouse.inventory`

## Finance Schema

The `finance` schema manages payment and financial transaction records.

It should:

- Store the payments table.
- Track payment methods.
- Track payment statuses.
- Track successful, pending, failed, and refunded payment transactions.
- Help monitor company revenue.
- Help monitor customer payment activities.
- Maintain relationships between payments and customer orders through foreign keys.
- Demonstrate financial reporting, payment analysis, and transaction integrity in SQL systems.

Expected tables include:

- `finance.payments`

