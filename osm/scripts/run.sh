#!/bin/bash

CFG_DIR="/etc/osm-update"
DATA_DIR="/var/lib/imposm"

# Create database connection string
if [ ! -f $OSM_DB_PASS_FILE ] ; then
	CONN="postgis://${OSM_DB_USER}:${OSM_DB_PASS}@${OSM_DB_HOST}:${OSM_DB_PORT}/${OSM_DB_NAME}"
else
	PASS=$(cat "${OSM_DB_PASS_FILE}")
	CONN="postgis://${OSM_DB_USER}:${PASS}@${OSM_DB_HOST}:${OSM_DB_PORT}/${OSM_DB_NAME}"
fi

# Download .pbf file if it doesn't exist
PBF="${OSM_DOWNLOAD_URL##*/}"
if [ ! -z $PBF ] ; then
	if [ ! -f "${DATA_DIR}/downloads/$PBF" ] ; then
		echo "Downloading OSM data..."
		wget -q "${OSM_DOWNLOAD_URL}" -P /var/lib/imposm/downloads

		if [ $? -eq 0 ] ; then
		       echo "File downloaded successfully."
	        else
		       echo "ERROR: Couldn't download file!"
		fi
	else
		echo "File already exists!"
	fi
else
	echo "ERROR: Invalid filename!"
fi

# Import data to the database
if [ -f ] ; then
	echo "imposm: Importing data to the database..."
	imposm import -mapping "${CFG_DIR}/mapping.yml" \
		      -limitto "${CFG_DIR}/clipping-area.geojson" \
		      -read "${DATA_DIR}/downloads/$PBF" \
		      -write -cachedir "${DATA_DIR}/cache" -overwritecache \
		      -diff -diffdir "${DATA_DIR}/diff" \
		      -connection "$CONN"
fi

# Move imported data to the public schema
if [ $? -eq 0 ] ; then
	echo "imposm: Moving data to the public schema..."
	imposm import -mapping "${CFG_DIR}/mapping.yml" -connection "$CONN" -deployproduction
fi

# Run update
if [ $? -eq 0 ] ; then
	imposm run -mapping "${CFG_DIR}/mapping.yml" \
		   -limitto "${CFG_DIR}/clipping-area.geojson" \
		   -cachedir "${DATA_DIR}/cache" \
		   -diffdir "${DATA_DIR}/diff" \
		   -httpprofile "${OSM_REPLICATION_URL}" \
		   -replication-interval "${OSM_REPLICATION_INTERVAL}" \
		   -connection "$CONN"
fi
