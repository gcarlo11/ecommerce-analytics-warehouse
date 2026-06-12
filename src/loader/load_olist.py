from __future__ import annotations

import argparse
import hashlib
import os
from datetime import datetime, timezone
from pathlib import Path

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine, text


CSV_TABLES = {
    "olist_customers_dataset.csv": "raw_olist_customers",
    "olist_geolocation_dataset.csv": "raw_olist_geolocation",
    "olist_order_items_dataset.csv": "raw_olist_order_items",
    "olist_order_payments_dataset.csv": "raw_olist_order_payments",
    "olist_order_reviews_dataset.csv": "raw_olist_order_reviews",
    "olist_orders_dataset.csv": "raw_olist_orders",
    "olist_products_dataset.csv": "raw_olist_products",
    "olist_sellers_dataset.csv": "raw_olist_sellers",
    "product_category_name_translation.csv": "raw_product_category_name_translation",
}

TRANSACTION_TABLES = {
    "raw_olist_orders",
    "raw_olist_order_items",
    "raw_olist_order_payments",
    "raw_olist_order_reviews",
}


def get_engine():
    load_dotenv()
    host = os.getenv("WAREHOUSE_HOST", "localhost")
    port = os.getenv("WAREHOUSE_PORT", "5432")
    db = os.getenv("WAREHOUSE_DB", "olist_warehouse")
    user = os.getenv("WAREHOUSE_USER", "warehouse")
    password = os.getenv("WAREHOUSE_PASSWORD", "warehouse")
    url = f"postgresql+psycopg2://{user}:{password}@{host}:{port}/{db}"
    return create_engine(url)


def file_checksum(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as file_obj:
        for chunk in iter(lambda: file_obj.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def read_csv(path: Path) -> pd.DataFrame:
    return pd.read_csv(path, dtype=str, keep_default_na=False)


def filter_batch(
    table_name: str,
    df: pd.DataFrame,
    orders_df: pd.DataFrame,
    batch_date: str,
) -> pd.DataFrame:
    if table_name == "raw_olist_orders":
        purchase_dates = pd.to_datetime(df["order_purchase_timestamp"], errors="coerce").dt.date
        return df[purchase_dates.astype(str) == batch_date].copy()

    if table_name in {"raw_olist_order_items", "raw_olist_order_payments", "raw_olist_order_reviews"}:
        order_dates = orders_df[["order_id", "order_purchase_timestamp"]].copy()
        order_dates["batch_date"] = pd.to_datetime(
            order_dates["order_purchase_timestamp"],
            errors="coerce",
        ).dt.date.astype(str)
        batch_order_ids = set(order_dates.loc[order_dates["batch_date"] == batch_date, "order_id"])
        return df[df["order_id"].isin(batch_order_ids)].copy()

    return df.copy()


def ensure_schema(engine) -> None:
    with engine.begin() as conn:
        conn.execute(text("create schema if not exists raw"))
        conn.execute(
            text(
                """
                create table if not exists raw.load_manifest (
                    manifest_id bigserial primary key,
                    source_table text not null,
                    source_file text not null,
                    load_mode text not null,
                    batch_date date,
                    loaded_rows bigint not null,
                    source_checksum text not null,
                    started_at timestamptz not null,
                    finished_at timestamptz not null
                )
                """
            )
        )


def load_table(
    engine,
    data_dir: Path,
    csv_name: str,
    table_name: str,
    load_mode: str,
    batch_date: str | None,
    orders_df: pd.DataFrame,
) -> None:
    started_at = datetime.now(timezone.utc)
    csv_path = data_dir / csv_name

    if not csv_path.exists():
        raise FileNotFoundError(f"Required CSV not found: {csv_path}")

    df = read_csv(csv_path)

    if load_mode == "batch":
        if batch_date is None:
            raise ValueError("batch mode requires --batch-date")
        df = filter_batch(table_name, df, orders_df, batch_date)

    df["loaded_at"] = datetime.now(timezone.utc).isoformat()
    df["source_file"] = csv_name
    df["batch_date"] = batch_date

    if load_mode == "snapshot":
        with engine.begin() as conn:
            conn.execute(text(f"drop table if exists raw.{table_name} cascade"))

    df.to_sql(
        name=table_name,
        con=engine,
        schema="raw",
        if_exists="append",
        index=False,
        method="multi",
        chunksize=5000,
    )

    finished_at = datetime.now(timezone.utc)
    checksum = file_checksum(csv_path)

    with engine.begin() as conn:
        conn.execute(
            text(
                """
                insert into raw.load_manifest (
                    source_table,
                    source_file,
                    load_mode,
                    batch_date,
                    loaded_rows,
                    source_checksum,
                    started_at,
                    finished_at
                )
                values (
                    :source_table,
                    :source_file,
                    :load_mode,
                    :batch_date,
                    :loaded_rows,
                    :source_checksum,
                    :started_at,
                    :finished_at
                )
                """
            ),
            {
                "source_table": table_name,
                "source_file": csv_name,
                "load_mode": load_mode,
                "batch_date": batch_date,
                "loaded_rows": len(df),
                "source_checksum": checksum,
                "started_at": started_at,
                "finished_at": finished_at,
            },
        )

    print(f"Loaded {len(df):>8} rows into raw.{table_name}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--data-dir", default="data/raw")
    parser.add_argument("--mode", choices=["snapshot", "batch"], default="snapshot")
    parser.add_argument("--batch-date", default=None)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    data_dir = Path(args.data_dir)
    engine = get_engine()
    ensure_schema(engine)

    orders_path = data_dir / "olist_orders_dataset.csv"
    if not orders_path.exists():
        raise FileNotFoundError(f"Required CSV not found: {orders_path}")

    orders_df = read_csv(orders_path)

    for csv_name, table_name in CSV_TABLES.items():
        load_table(
            engine=engine,
            data_dir=data_dir,
            csv_name=csv_name,
            table_name=table_name,
            load_mode=args.mode,
            batch_date=args.batch_date,
            orders_df=orders_df,
        )


if __name__ == "__main__":
    main()