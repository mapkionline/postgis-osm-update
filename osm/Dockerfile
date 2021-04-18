FROM debian:9

# Arguments
ARG OSM_DB_HOST=localhost
ARG OSM_DB_PORT=5432
ARG OSM_DB_NAME=osm
ARG OSM_DB_USER=osm
ARG OSM_DB_PASS=osm
ARG OSM_DB_PASS_FILE=osm

ARG OSM_DOWNLOAD_URL='https://download.geofabrik.de/europe/luxembourg-latest.osm.pbf'
ARG OSM_REPLICATION_URL='https://download.geofabrik.de/europe/luxembourg-updates/'
ARG OSM_REPLICATION_INTERVAL=24h

# Install wget, cron, osmium-tool
RUN apt-get update -qq && apt-get install -y wget tar

# Download and install imposm3
RUN wget -q https://github.com/omniscale/imposm3/releases/download/v0.11.1/imposm-0.11.1-linux-x86-64.tar.gz -P /tmp
RUN tar xzf /tmp/imposm-0.11.1-linux-x86-64.tar.gz -C /opt
RUN ln -s /opt/imposm-0.11.1-linux-x86-64/imposm3 /usr/bin/imposm

# Create directories for imposm data
RUN mkdir -p /var/lib/imposm/{diff,cache,downloads}

# Copy scripts to the image
RUN mkdir -p /opt/osm-update
COPY ./scripts /opt/osm-update/
RUN chmod +x /opt/osm-update/*.sh

# Create symbolic link to the entrypoint
RUN ln -s /opt/osm-update/run.sh /usr/bin/osm-update-run

# Copy configuration files to the image
RUN mkdir -p /etc/osm-update
COPY ./configs /etc/osm-update/

# Environment variables
ENV OSM_DB_HOST=${OSM_DB_HOST}
ENV OSM_DB_PORT=${OSM_DB_PORT}
ENV OSM_DB_NAME=${OSM_DB_NAME}
ENV OSM_DB_USER=${OSM_DB_USER}
ENV OSM_DB_PASS=${OSM_DB_PASS}
ENV OSM_DB_PASS_FILE=${OSM_DB_PASS_FILE}

ENV OSM_DOWNLOAD_URL=${OSM_DOWNLOAD_URL}
ENV OSM_REPLICATION_URL=${OSM_REPLICATION_URL}
ENV OSM_REPLICATION_INTERVAL=${OSM_REPLICATION_INTERVAL}

#" Download latest extract and run periodic updates
CMD [ "osm-update-run" ]
