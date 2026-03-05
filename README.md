# External GIS Data (ACS, OSM, TIGER) as Postgres (with PostGIS) database (docker image)

# * NOTE: VERY LARGE (120+ GB)
used as a general import of a massive amount of ACS/OSM data. not to be used in production environments. build and use the huge dbs temporarily to figure out what data is necessary, then export those as a new db

# Building from scratch
1. Build and run postgis service <br>
    `docker compose up --build -d postgis`
1. Import TIGER data with ogr2ogr tool <br>
    `docker compose run --build --rm tiger_load_2024`
    - should be relatively quick, just importing shape files (< 5 min)
1. Import census (ACS) data
    `docker compose run --rm acs2024_restore`
    - full restore from db dump, will take a <b>long</b> time (2-6+ hrs)
1. Import OSM data
    `docker compose run --rm osm2pgsql`
    - again, takes very long (2-6+ hours)
    - downloads a huge .pbf file (1-15gb), osm2pgsql inserts it into postgres
    - the default osm file is `https://download.geofabrik.de/north-america/us-midwest-latest.osm.pbf`
        - replace `us-midwest` with the following options for other regions: 
            - `us-northeast`
            - `us-south`
            - `us-pacific`
            - `us-west`
        - <b>IMPORTANT</b>: if the process finishes successfully once and you wish to expand the same database with another region, be sure to change the `--create` flag to `--append` in the osm2pgsql call

# Backups
- run temporary container to create a backup<br>
    `docker run --rm pg_backup`

# LOCAL:
- running db on pi to host the 200+ gb of osm/acs, connect from wherever with tailscale