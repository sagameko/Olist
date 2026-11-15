import logging
from pathlib import Path

import duckdb

logger = logging.getLogger(__name__)

def run_sql_folder(con: duckdb.DuckDBPyConnection, folder: Path, schema: str) -> None:
    con.execute(f"CREATE SCHEMA IF NOT EXISTS {schema}")
    files = sorted(folder.glob("*.sql"))
    if not files:
        raise FileNotFoundError(f"No .sql files in {folder}")
    for sql_file in files:
        con.execute(sql_file.read_text(encoding="utf-8"))
        table = sql_file.stem
        rows = con.execute(f"SELECT COUNT(*) FROM {schema}.{table}").fetchone()[0]
        logger.info("%s.%s: %s rows", schema, table, rows)

