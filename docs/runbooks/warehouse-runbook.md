# Warehouse Runbook

## Start Services
```powershell
docker compose up -d
```

## Stop Services
```powershell
docker compose down
```

## Reset Everything
Warning: this removes local database volumes.

```powershell
docker compose down -v
docker compose up -d
```

## Load Full Snapshot
```powershell
python -m src.loader.load_olist --data-dir data/raw --mode snapshot
```

## Load One Incremental Batch
```powershell
python -m src.loader.load_olist --data-dir data/raw --mode batch --batch-date 2017-01-05
```

## Run dbt Build
```powershell
$env:DBT_PROFILES_DIR="profiles"
dbt build --project-dir dbt
```

## Generate dbt Docs
```powershell
$env:DBT_PROFILES_DIR="profiles"
dbt docs generate --project-dir dbt
dbt docs serve --project-dir dbt
```

## Debug Failed Test
1. Run `dbt build --project-dir dbt`.
2. Identify failing test name.
3. Open compiled SQL under `dbt/target/compiled`.
4. Run the SQL in PostgreSQL.
5. Inspect failing rows.
6. Fix model or update metric definition.
```