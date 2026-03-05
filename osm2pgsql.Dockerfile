FROM debian:bookworm-slim

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
       osm2pgsql ca-certificates curl \
  && rm -rf /var/lib/apt/lists/*
