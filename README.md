# osm-update

This example project shows how to keep a PostGIS database up to date with
OpenStreetMap data, using imposm3 and Docker.

```
$ cp osm.env.example osm.env
$ cp postgis.env.example postgis.env
$ cp db_password.example db_password

$ mkdir -p {postgres/data,imposm}

$ docker-compose up --build
```
