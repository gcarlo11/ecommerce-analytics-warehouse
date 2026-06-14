from pathlib import Path

from src.loader.load_olist import CSV_TABLES


def test_required_csv_mapping_contains_orders():
    assert "olist_orders_dataset.csv" in CSV_TABLES
    assert CSV_TABLES["olist_orders_dataset.csv"] == "raw_olist_orders"


def test_required_csv_names_are_csv_files():
    for csv_name in CSV_TABLES:
        assert Path(csv_name).suffix == ".csv"