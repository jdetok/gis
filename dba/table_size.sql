-- largest tables by size:
select
    n.nspname as "schema",
    c.relname as "table",
    pg_size_pretty(pg_total_relation_size(c.oid)) as "total_size"
from pg_class c
join pg_namespace n on n.oid = c.relnamespace
where c.relkind = 'r' -- regular tables
    and n.nspname not in ('pg_catalog', 'information_schema')
order by
    pg_total_relation_size(c.oid) desc
limit 25;


-- sizes by schema
with size as (
	select
    n.nspname as "schema",	
    c.relname as "table",
    sum(pg_total_relation_size(c.oid)) as "size",
    pg_size_pretty(pg_total_relation_size(c.oid)) as "size_pretty"
    from pg_class c
	join pg_namespace n on n.oid = c.relnamespace
	where c.relkind = 'r' -- regular tables
	group by n.nspname, c.relname, c.oid
)
select a.schema, count(a.table) as num_tables, sum(a.size) as "size", pg_size_pretty(sum(a.size)) as "size_pretty"
from size a
where a.schema in ('acs2024_5yr', 'public', 'tgr24')
group by a.schema;

-- activity stats
select pid, usename, datname, application_name, 
(select now() - backend_start) as timesince_start, query, client_addr, state, wait_event, backend_start 
from pg_stat_activity
where backend_type = 'client backend'
order by backend_start desc;