import logging
import re
from pathlib import Path

import duckdb

logger = logging.getLogger(__name__)


def table_name(sql_file: Path) -> str:
    return re.sub(r"^\d+_", "", sql_file.stem)

def run_sql_folder(con: duckdb.DuckDBPyConnection, folder: Path, schema: str) -> None:
    """Create the schema, then run each file in name order. Each file builds one table."""
    con.execute(f"CREATE SCHEMA IF NOT EXISTS {schema}")
    files = sorted(folder.glob("*.sql"))
    if not files:
        raise FileNotFoundError(f"No .sql files in {folder}")
    for sql_file in files:
        con.execute(sql_file.read_text(encoding="utf-8"))
        table = table_name(sql_file)
        rows = con.execute(f"SELECT COUNT(*) FROM {schema}.{table}").fetchall()[0][0]
        logger.info("%s.%s: %s rows", schema, table, rows)

        