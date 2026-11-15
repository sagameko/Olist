import logging
from pathlib import Path

import duckdb

logger = logging.getLogger(__name__)


RAW_FILES = {
    "customers": "olist_customers_dataset.csv",
    "orders": "olist_orders_dataset.csv",
    "order_items": "olist_order_items_dataset.csv",
    "order_payments": "olist_order_payments_dataset.csv",
    "order_reviews": "olist_order_reviews_dataset.csv",
    "products": "olist_products_dataset.csv",
    "sellers": "olist_sellers_dataset.csv",
    "geolocation": "olist_geolocation_dataset.csv",
    "category_translation": "product_category_name_translation.csv",
}


def load_raw(con: duckdb.DuckDBPyConnection, raw_dir: Path) -> None:
    """Copy every CSV into raw.<table> with all columns as text.

    all_varchar keeps values exactly as in the file (e.g. zip '01001' keeps its
    leading zero). Choosing types is the staging layer's job, not this one's.
    """
    con.execute("CREATE SCHEMA IF NOT EXISTS raw")
    for table, file_name in RAW_FILES.items():
        path = raw_dir / file_name
        if not path.exists():
            raise FileNotFoundError(f"Missing raw file: {path}")
        con.execute(
            f"CREATE OR REPLACE TABLE raw.{table} AS "
            "SELECT * FROM read_csv(?, header = true, all_varchar = true)",
            [str(path)],
        )
        rows = con.execute(f"SELECT COUNT(*) FROM raw.{table}").fetchone()[0]
        logger.info("raw.%s: %s rows", table, rows)
        