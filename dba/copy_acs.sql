create or replace procedure copy_acs_tables(
    source_schema text default 'acs2024_5yr',
    target_schema text default 'acs_out'
)
language plpgsql as $$
declare
    tbl text;   
begin
    execute format('create schema if not exists %I', target_schema);

    raise notice 'copying tables from schema % into schema %', source_schema, target_schema;
    for tbl in
        select t.table_name
        from information_schema.tables t
        where t.table_schema = source_schema
            and t.table_type = 'BASE TABLE'
    loop
    -- create identical table structure
        execute format('create table %I.%I (like %I.%I including all)',
            target_schema, tbl, source_schema, tbl
        );

-- if table has geoid, copy filtered rows; otherwise copy everything
        if exists (
            select 1 from information_schema.columns
            where table_schema = source_schema
            and table_name = tbl
            and column_name = 'geoid'
        ) then
            execute format(
            'insert into %I.%I select * from %I.%I where geoid like any (array[''14000US29%%'', ''14000US17%%''])',
            target_schema, tbl,
            source_schema, tbl
            );
        else
            execute format('insert into %I.%I select * from %I.%I',
                target_schema, tbl, source_schema, tbl
            );
        end if;
        raise notice 'copied table: %', tbl;
    end loop;
end;
$$;