-- Runnable SQLite companion prototype for the portfolio PDF report.
-- Educational sample only; it is not a production park-management application.
PRAGMA foreign_keys = ON;

CREATE TABLE departments (
    department_id INTEGER PRIMARY KEY,
    department_name TEXT NOT NULL UNIQUE
);
CREATE TABLE employees (
    employee_id INTEGER PRIMARY KEY,
    department_id INTEGER NOT NULL REFERENCES departments(department_id),
    employee_name TEXT NOT NULL
);
CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    customer_name TEXT NOT NULL
);
CREATE TABLE zones (
    zone_id INTEGER PRIMARY KEY,
    zone_name TEXT NOT NULL UNIQUE
);
CREATE TABLE rides (
    ride_id INTEGER PRIMARY KEY,
    zone_id INTEGER NOT NULL REFERENCES zones(zone_id),
    ride_name TEXT NOT NULL,
    capacity INTEGER NOT NULL CHECK (capacity > 0),
    min_height_cm INTEGER NOT NULL DEFAULT 0 CHECK (min_height_cm >= 0),
    ride_status TEXT NOT NULL CHECK (ride_status IN ('OPEN','CLOSED','MAINTENANCE')),
    UNIQUE (zone_id, ride_name)
);
CREATE TABLE ticket_types (
    ticket_type_id INTEGER PRIMARY KEY,
    ticket_name TEXT NOT NULL UNIQUE,
    price_inr NUMERIC NOT NULL CHECK (price_inr >= 0)
);
CREATE TABLE tickets (
    ticket_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(customer_id),
    ticket_type_id INTEGER NOT NULL REFERENCES ticket_types(ticket_type_id),
    purchased_at TEXT NOT NULL,
    valid_on TEXT NOT NULL,
    ticket_status TEXT NOT NULL CHECK (ticket_status IN ('VALID','CANCELLED')),
    UNIQUE (ticket_id,customer_id)
);
CREATE TABLE ride_visits (
    visit_id INTEGER PRIMARY KEY,
    ticket_id INTEGER NOT NULL,
    customer_id INTEGER NOT NULL,
    ride_id INTEGER NOT NULL REFERENCES rides(ride_id),
    ridden_at TEXT NOT NULL,
    FOREIGN KEY (ticket_id,customer_id) REFERENCES tickets(ticket_id,customer_id),
    UNIQUE (ticket_id,ride_id,ridden_at)
);
CREATE TABLE ride_maintenance (
    maintenance_id INTEGER PRIMARY KEY,
    ride_id INTEGER NOT NULL REFERENCES rides(ride_id),
    employee_id INTEGER NOT NULL REFERENCES employees(employee_id),
    performed_at TEXT NOT NULL,
    description TEXT NOT NULL,
    cost_inr NUMERIC NOT NULL DEFAULT 0 CHECK (cost_inr >= 0)
);
CREATE TABLE ride_staff_shifts (
    ride_id INTEGER NOT NULL REFERENCES rides(ride_id),
    employee_id INTEGER NOT NULL REFERENCES employees(employee_id),
    shift_on TEXT NOT NULL,
    PRIMARY KEY (ride_id,employee_id,shift_on)
);
CREATE TABLE food_items (
    food_item_id INTEGER PRIMARY KEY,
    item_name TEXT NOT NULL UNIQUE,
    list_price_inr NUMERIC NOT NULL CHECK (list_price_inr >= 0),
    stock_qty INTEGER NOT NULL CHECK (stock_qty >= 0)
);
CREATE TABLE food_purchases (
    purchase_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(customer_id),
    food_item_id INTEGER NOT NULL REFERENCES food_items(food_item_id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    price_each_inr NUMERIC NOT NULL CHECK (price_each_inr >= 0),
    purchased_at TEXT NOT NULL
);

CREATE TRIGGER check_ride_visit BEFORE INSERT ON ride_visits
BEGIN
    SELECT RAISE(ABORT,'Ride is not open')
      WHERE COALESCE((SELECT ride_status FROM rides WHERE ride_id=NEW.ride_id),'MISSING') <> 'OPEN';
    SELECT RAISE(ABORT,'Ticket is not valid for this customer and date')
      WHERE NOT EXISTS (
        SELECT 1 FROM tickets t
        WHERE t.ticket_id=NEW.ticket_id
          AND t.customer_id=NEW.customer_id
          AND t.ticket_status='VALID'
          AND t.valid_on=substr(NEW.ridden_at,1,10)
      );
END;

CREATE TRIGGER check_food_stock BEFORE INSERT ON food_purchases
BEGIN
    SELECT RAISE(ABORT,'Insufficient food stock')
      WHERE NEW.quantity > COALESCE(
        (SELECT stock_qty FROM food_items WHERE food_item_id=NEW.food_item_id),0
      );
END;
CREATE TRIGGER deduct_food_stock AFTER INSERT ON food_purchases
BEGIN
    UPDATE food_items SET stock_qty=stock_qty-NEW.quantity
    WHERE food_item_id=NEW.food_item_id;
END;

CREATE VIEW daily_revenue AS
SELECT sale_date, SUM(ticket_revenue_inr) AS ticket_revenue_inr,
       SUM(food_revenue_inr) AS food_revenue_inr,
       SUM(ticket_revenue_inr+food_revenue_inr) AS total_revenue_inr
FROM (
    SELECT substr(t.purchased_at,1,10) AS sale_date,
           tt.price_inr AS ticket_revenue_inr,0 AS food_revenue_inr
    FROM tickets t JOIN ticket_types tt ON tt.ticket_type_id=t.ticket_type_id
    WHERE t.ticket_status='VALID'
    UNION ALL
    SELECT substr(p.purchased_at,1,10),0,p.quantity*p.price_each_inr
    FROM food_purchases p
) GROUP BY sale_date;
