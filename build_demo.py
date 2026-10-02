"""Build a runnable SQLite demonstration of the amusement park data model."""
from pathlib import Path
import sqlite3

ROOT = Path(__file__).resolve().parent
DB = ROOT / "amusement_park_demo.sqlite"


def build_database(db_path=DB):
    db_path = Path(db_path)
    db_path.parent.mkdir(parents=True, exist_ok=True)
    if db_path.exists():
        db_path.unlink()
    with sqlite3.connect(db_path) as connection:
        connection.execute("PRAGMA foreign_keys = ON")
        for file in ("schema.sql", "sample_data.sql"):
            connection.executescript((ROOT / "sql" / file).read_text(encoding="utf-8"))
        violations = connection.execute("PRAGMA foreign_key_check").fetchall()
        if violations:
            raise ValueError(f"Foreign-key violations: {violations}")
        return {
            "customers": connection.execute("SELECT COUNT(*) FROM customers").fetchone()[0],
            "rides": connection.execute("SELECT COUNT(*) FROM rides").fetchone()[0],
            "tickets": connection.execute("SELECT COUNT(*) FROM tickets").fetchone()[0],
            "sample_daily_revenue_inr": connection.execute(
                "SELECT total_revenue_inr FROM daily_revenue WHERE sale_date='2026-10-01'"
            ).fetchone()[0],
        }


if __name__ == "__main__":
    print(build_database())
