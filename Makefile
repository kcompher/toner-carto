# use PGDATABASE PGHOST etc.

mml: project.mml

install:
	mkdir -p ${HOME}/Documents/MapBox/project
	ln -sf "`pwd`" ${HOME}/Documents/MapBox/project/toner-background
	npm install && npm rebuild
	echo DATABASE_URL=postgres:///osm > .env

clean:
	rm project.mml

project.mml: project.yml
	cat project.yml | (source .env && node jsonify.js $$DATABASE_URL)

data/land-polygons-complete-3857.zip:
	mkdir -p data
	curl -sL http://data.openstreetmapdata.com/land-polygons-complete-3857.zip -o data/land-polygons-complete-3857.zip

land: data/land-polygons-complete-3857.zip 
	cd shp/ && unzip -o ../data/land-polygons-complete-3857.zip
	cd shp/ && shapeindex land-polygons-complete-3857/land_polygons.shp

sql:
	psql -f highroad.sql

sfo:
	dropdb sfo2
	createdb sfo2
	psql sfo2 -c "create extension postgis"
	~/workspace/imposm/bin/imposm3 import --cachedir cache -mapping=imposm3_mapping.json -read /Volumes/Work/osm/sf-bay-area.osm.pbf -connection="postgis://localhost/sfo2" -write -deployproduction -overwritecache -optimize

