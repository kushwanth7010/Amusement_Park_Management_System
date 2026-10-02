"""End-to-end integrity checks for the educational SQLite companion."""
import sqlite3
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class AmusementParkDatabaseTests(unittest.TestCase):
    def setUp(self):
        self.db = sqlite3.connect(":memory:")
        self.db.execute("PRAGMA foreign_keys=ON")
        for file in ("schema.sql", "sample_data.sql"):
            self.db.executescript((ROOT / "sql" / file).read_text(encoding="utf-8"))

    def tearDown(self):
        self.db.close()

    def test_sample_records_and_relationships(self):
        self.assertEqual(self.db.execute("SELECT COUNT(*) FROM rides").fetchone()[0], 2)
        self.assertEqual(self.db.execute("SELECT COUNT(*) FROM tickets").fetchone()[0], 2)
        self.assertEqual(self.db.execute("PRAGMA foreign_key_check").fetchall(), [])

    def test_daily_revenue_reconciles(self):
        row = self.db.execute(
            "SELECT ticket_revenue_inr,food_revenue_inr,total_revenue_inr "
            "FROM daily_revenue WHERE sale_date='2026-10-01'"
        ).fetchone()
        self.assertEqual(row, (1600, 240, 1840))

    def test_closed_or_maintenance_ride_cannot_accept_visit(self):
        with self.assertRaises(sqlite3.IntegrityError):
            self.db.execute(
                "INSERT INTO ride_visits VALUES (2,1,1,2,'2026-10-01T11:00:00')"
            )

    def test_ticket_cannot_be_used_by_another_customer(self):
        with self.assertRaises(sqlite3.IntegrityError):
            self.db.execute(
                "INSERT INTO ride_visits VALUES (2,1,2,1,'2026-10-01T11:00:00')"
            )

    def test_ticket_must_be_valid_on_visit_date(self):
        with self.assertRaises(sqlite3.IntegrityError):
            self.db.execute(
                "INSERT INTO ride_visits VALUES (2,1,1,1,'2026-10-02T11:00:00')"
            )

    def test_food_stock_is_reduced_and_overselling_blocked(self):
        self.assertEqual(self.db.execute("SELECT stock_qty FROM food_items WHERE food_item_id=1").fetchone()[0], 10)
        with self.assertRaises(sqlite3.IntegrityError):
            self.db.execute(
                "INSERT INTO food_purchases VALUES (2,1,1,11,120,'2026-10-01T12:00:00')"
            )
        self.db.execute(
            "INSERT INTO food_purchases VALUES (2,1,1,3,120,'2026-10-01T12:00:00')"
        )
        self.assertEqual(self.db.execute("SELECT stock_qty FROM food_items WHERE food_item_id=1").fetchone()[0], 7)

    def test_foreign_keys_reject_unknown_zone(self):
        with self.assertRaises(sqlite3.IntegrityError):
            self.db.execute(
                "INSERT INTO rides VALUES (3,999,'Unknown Ride',10,0,'OPEN')"
            )

    def test_negative_ticket_price_rejected(self):
        with self.assertRaises(sqlite3.IntegrityError):
            self.db.execute("INSERT INTO ticket_types VALUES (2,'Invalid',-5)")


if __name__ == "__main__":
    unittest.main()
