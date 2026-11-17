import logging
from pathlib import Path

import duckdb

from olist.load_raw import load_raw
from olist.run_sql import run_sql_folder

RAW_DIR = Path("data/raw/olist")
DATABASE = Path("data/warehouse.duckdb")
STAGING_SQL = Path("sql/staging")
MARTS_SQL = Path("sql/marts")   

logger = logging.getLogger(__name__)

def main() -> None:
    logging.basicConfig(
        level= logging.INFO,
        format="%(asctime)s %(levelname)s %(name)s: %(message)s",    
    )

    DATABASE.parent.mkdir(parents=True, exist_ok=True)
    con = duckdb.connect(str(DATABASE))
    try:
        con.execute("BEGIN")
        load_raw(con, RAW_DIR)
        run_sql_folder(con, STAGING_SQL, schema="staging")
        run_sql_folder(con, MARTS_SQL, schema="marts")
        con.execute("COMMIT")
        logger.info("Pipeline finished")
    except Exception:
        con.execute("ROLLBACK")
        logger.exception("Pipeline failed, nothing was changed")
        raise
    finally:
        con.close()


if __name__ == "__main__":
    main()   