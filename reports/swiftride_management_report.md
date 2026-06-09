# SwiftRide Logistics Management Report

Generated from the SwiftRide PostgreSQL database using the operational SQL queries.

Report generated: 2026-06-09 22:27:40 EEST

## Executive Summary

This report summarizes customer activity, delivery operations, revenue, payment status, inventory levels, and cross-schema operational visibility for SwiftRide Logistics.

## Database Coverage

This section confirms the number of records available across the core business areas.

| metric | total_records |
| --- | --- |
| Customers | 400 |
| Deliveries | 600 |
| Drivers | 360 |
| Inventory Items | 700 |
| Orders | 600 |
| Payments | 600 |
| Vehicles | 350 |
| Warehouses | 350 |


## Top 10 High-Value Customers

These customers generate the highest order value and are strong candidates for loyalty rewards, premium support, or targeted retention campaigns.

| customer | total_orders | total_spent |
| --- | --- | --- |
| Joy Adebayo | 8 | 2,031,602.87 |
| Fatima Umeh | 8 | 1,952,497.24 |
| Chioma Musa | 9 | 1,932,594.56 |
| Tunde Balogun | 8 | 1,840,532.84 |
| Grace James | 8 | 1,589,841.93 |
| Chioma Mohammed | 9 | 1,587,938.32 |
| Peter Aliyu | 7 | 1,411,584.53 |
| Joy Lawal | 5 | 1,345,063.50 |
| Yusuf Bello | 7 | 1,335,420.25 |
| Sola Mohammed | 7 | 1,266,147.96 |


## Driver Delivery Workload

This view helps management understand driver workload distribution and identify top-performing or heavily assigned drivers.

| driver | current_status | total_deliveries |
| --- | --- | --- |
| Ahmed Umeh | Available | 8 |
| Kemi Onyeka | On Delivery | 7 |
| Joy Musa | Available | 6 |
| Bola Ifeanyi | Off Duty | 6 |
| Fatima Aminu | On Delivery | 6 |
| Ibrahim Balogun | On Delivery | 6 |
| Esther Lawal | Available | 5 |
| Samuel Ogunleye | Available | 5 |
| Sola Lawal | Available | 5 |
| Zainab Bello | Available | 5 |


## Delivery Status Summary

Delivery status counts show operational progress, bottlenecks, and the volume of work that still needs attention.

| delivery_status | total_deliveries |
| --- | --- |
| Delivered | 234 |
| In Transit | 144 |
| Assigned | 94 |
| Pending | 62 |
| Failed | 37 |
| Returned | 29 |


## Pending Deliveries

Pending deliveries need operational follow-up to reduce customer delays and improve service reliability.

| delivery_id | order_id | customer | assigned_driver | vehicle | delivery_status |
| --- | --- | --- | --- | --- | --- |
| 2 | 2 | Mercy Ibrahim | Mercy Mohammed | SRL-0079-NG | Pending |
| 4 | 4 | Aisha Usman | Sola Ajayi | SRL-0259-NG | Pending |
| 33 | 33 | Samuel Musa | Joy Okafor | SRL-0270-NG | Pending |
| 43 | 43 | David Ibrahim | Victor Danladi | SRL-0273-NG | Pending |
| 45 | 45 | Peter Onyeka | Fatima Aminu | SRL-0012-NG | Pending |
| 47 | 47 | Ngozi Ajayi | Esther Lawal | SRL-0081-NG | Pending |
| 74 | 74 | Peter Ajayi | Blessing Nwosu | SRL-0184-NG | Pending |
| 79 | 79 | Yusuf Bello | Ahmed Musa | SRL-0116-NG | Pending |
| 103 | 103 | Ahmed Aliyu | Ruth Musa | SRL-0233-NG | Pending |
| 105 | 105 | Grace Mohammed | Tunde Aminu | SRL-0064-NG | Pending |
| 121 | 121 | Mercy Ibrahim | Tunde Nwosu | SRL-0227-NG | Pending |
| 124 | 124 | Joy Adebayo | Peter Okoro | SRL-0107-NG | Pending |
| 134 | 134 | Peter Ajayi | John Salami | SRL-0019-NG | Pending |
| 150 | 150 | John Mohammed | John Ajayi | SRL-0100-NG | Pending |
| 153 | 153 | Fatima Umeh | Kemi Onyeka | SRL-0212-NG | Pending |
| 176 | 176 | Tunde Okoro | Aisha Danladi | SRL-0212-NG | Pending |
| 181 | 181 | Sola Mohammed | David Danladi | SRL-0260-NG | Pending |
| 188 | 188 | Musa Okafor | Ayo Danladi | SRL-0060-NG | Pending |
| 210 | 210 | Samuel Salami | Halima Eze | SRL-0274-NG | Pending |
| 212 | 212 | Yusuf Bello | Bola Salami | SRL-0240-NG | Pending |


## Revenue Summary

This section provides a high-level revenue view based on order totals.

| total_orders | total_revenue | average_order_value | lowest_order_value | highest_order_value |
| --- | --- | --- | --- | --- |
| 600 | 110,199,989.64 | 183,666.65 | 3,451.45 | 349,863.00 |


## Payment Status Summary

Payment status counts help finance track successful payments, pending transactions, failures, and refunds.

| payment_status | total_payments |
| --- | --- |
| Paid | 423 |
| Pending | 106 |
| Failed | 42 |
| Refunded | 29 |


## Low Inventory Items

These products are below the stock threshold and should be reviewed for replenishment.

| warehouse_name | location | product_name | quantity |
| --- | --- | --- | --- |
| Owerri Distribution Hub 228 | Owerri Central, Owerri | Printer | 6 |
| Kano Distribution Hub 254 | Nassarawa, Kano | Tablet | 7 |
| Lagos Distribution Hub 230 | Ajah, Lagos | Generator | 10 |
| Abeokuta Distribution Hub 205 | Abeokuta Central, Abeokuta | Desk Chair | 13 |
| Enugu Distribution Hub 225 | Independence Layout, Enugu | Backpack | 13 |
| Abeokuta Distribution Hub 027 | Abeokuta Central, Abeokuta | Generator | 16 |
| Jos Distribution Hub 161 | Jos Central, Jos | Solar Panel | 16 |
| Kano Distribution Hub 227 | Nassarawa, Kano | Shoes | 16 |
| Owerri Distribution Hub 279 | Owerri Central, Owerri | Headphones | 17 |
| Uyo Distribution Hub 244 | Uyo Central, Uyo | Laptop | 19 |


## Cross-Schema Operational View

This combined view gives management end-to-end visibility from customer order to delivery and payment status.

| customer | order_id | driver | vehicle | payment_status | delivery_status |
| --- | --- | --- | --- | --- | --- |
| John Onyeka | 1 | Chinedu James | SRL-0168-NG | Paid | Delivered |
| Mercy Ibrahim | 2 | Mercy Mohammed | SRL-0079-NG | Paid | Pending |
| Grace Ojo | 3 | Esther Lawal | SRL-0229-NG | Paid | Delivered |
| Aisha Usman | 4 | Sola Ajayi | SRL-0259-NG | Paid | Pending |
| Peter James | 5 | Mary Aliyu | SRL-0149-NG | Failed | Delivered |
| John Aminu | 6 | Ayo Ibrahim | SRL-0068-NG | Paid | In Transit |
| Ibrahim Mohammed | 7 | Ayo Adebayo | SRL-0293-NG | Paid | Delivered |
| Musa Eze | 8 | Yusuf Ifeanyi | SRL-0205-NG | Refunded | In Transit |
| Aisha Usman | 9 | Sola Ajayi | SRL-0257-NG | Paid | In Transit |
| Grace Musa | 10 | Bola Salami | SRL-0067-NG | Paid | Delivered |
| Musa Mohammed | 11 | Blessing Aminu | SRL-0287-NG | Paid | Assigned |
| Bola Usman | 12 | Ibrahim Eze | SRL-0334-NG | Pending | Delivered |
| Mercy Danladi | 13 | Fatima Aminu | SRL-0316-NG | Paid | Returned |
| Bola Musa | 14 | Ibrahim Balogun | SRL-0127-NG | Pending | Assigned |
| Halima Ajayi | 15 | Musa Umeh | SRL-0221-NG | Paid | In Transit |
| Blessing Ogunleye | 16 | Sola Ajayi | SRL-0046-NG | Paid | Assigned |
| Ruth Usman | 17 | Blessing Ogunleye | SRL-0217-NG | Paid | In Transit |
| Chioma Ibrahim | 18 | Sola Aliyu | SRL-0165-NG | Paid | In Transit |
| Mary Ifeanyi | 19 | Zainab Lawal | SRL-0013-NG | Failed | Delivered |
| Victor Lawal | 20 | Sola Okafor | SRL-0180-NG | Paid | Delivered |
| Ruth Ogunleye | 21 | Bola Aminu | SRL-0320-NG | Paid | Assigned |
| Bola Salami | 22 | Mercy Akande | SRL-0120-NG | Paid | Assigned |
| Kemi Ogunleye | 23 | Mary Balogun | SRL-0080-NG | Paid | Delivered |
| John Aminu | 24 | Tunde Salami | SRL-0058-NG | Paid | Delivered |
| Esther Balogun | 25 | Musa Ade | SRL-0318-NG | Paid | Failed |


## Recommended Management Actions

- Prioritize follow-up on pending deliveries.
- Review low inventory items and restock where required.
- Monitor failed, pending, and refunded payments with the finance team.
- Use high-value customer insights to plan retention and loyalty offers.
- Use driver workload data to balance assignments and recognize strong performance.
