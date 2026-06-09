-- The create table statement only allowed three validations. So we gotta ALTER/MODIFY TABLE to allow more
ALTER TABLE
    fleet.drivers DROP CONSTRAINT IF EXISTS drivers_status_check;

ALTER TABLE
    fleet.drivers
ADD
    CONSTRAINT drivers_status_check CHECK (
        status IN (
            'Available',
            'Unavailable',
            'On Delivery',
            'Off Duty',
            'Suspended'
        )
    );

-- The create table statement only allowed four validations. So we gotta ALTER/MODIFY TABLE to allow more
ALTER TABLE
    operations.deliveries DROP CONSTRAINT IF EXISTS deliveries_delivery_status_check;

ALTER TABLE
    operations.deliveries
ADD
    CONSTRAINT deliveries_delivery_status_check CHECK (
        delivery_status IN (
            'Pending',
            'In Transit',
            'Delivered',
            'Cancelled',
            'Assigned',
            'Returned',
            'Failed'
        )
    );

-- The create table statement only allowed three validations. So we gotta ALTER/MODIFY TABLE to allow more
ALTER TABLE
    finance.payments DROP CONSTRAINT IF EXISTS payments_payment_status_check;

ALTER TABLE
    finance.payments
ADD
    CONSTRAINT payments_payment_status_check CHECK (
        payment_status IN ('Paid', 'Pending', 'Failed', 'Refunded')
    );
