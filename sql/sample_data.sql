-- All names and records below are fictional sample data.
INSERT INTO departments VALUES (1,'Ride Operations'),(2,'Maintenance');
INSERT INTO employees VALUES (1,1,'Sample Operator'),(2,2,'Sample Technician');
INSERT INTO customers VALUES (1,'Sample Visitor A'),(2,'Sample Visitor B');
INSERT INTO zones VALUES (1,'Adventure Zone'),(2,'Family Zone');
INSERT INTO rides VALUES
 (1,1,'Sample Coaster',24,130,'OPEN'),
 (2,2,'Sample Carousel',30,0,'MAINTENANCE');
INSERT INTO ticket_types VALUES (1,'One-Day Entry',800);
INSERT INTO tickets VALUES
 (1,1,1,'2026-10-01T09:00:00','2026-10-01','VALID'),
 (2,2,1,'2026-10-01T09:10:00','2026-10-01','VALID');
INSERT INTO ride_staff_shifts VALUES (1,1,'2026-10-01');
INSERT INTO ride_maintenance VALUES
 (1,2,2,'2026-10-01T08:00:00','Scheduled safety inspection',1500);
INSERT INTO ride_visits VALUES
 (1,1,1,1,'2026-10-01T10:00:00');
INSERT INTO food_items VALUES (1,'Sample Snack',120,12);
INSERT INTO food_purchases VALUES
 (1,1,1,2,120,'2026-10-01T11:00:00');
