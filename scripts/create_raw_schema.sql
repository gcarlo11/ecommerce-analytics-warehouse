create schema if not exists raw;

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