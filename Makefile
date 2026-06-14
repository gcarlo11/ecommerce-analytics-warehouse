setup:
	python -m pip install --upgrade pip
	python -m pip install -r requirements.txt

db-up:
	docker compose up -d

db-down:
	docker compose down

load-snapshot:
	python -m src.loader.load_olist --data-dir data/raw --mode snapshot

load-batch:
	python -m src.loader.load_olist --data-dir data/raw --mode batch --batch-date $(BATCH_DATE)

dbt-build:
	dbt build --project-dir dbt

dbt-docs:
	dbt docs generate --project-dir dbt
	dbt docs serve --project-dir dbt

test:
	pytest
	ruff check .
	dbt build --project-dir dbt