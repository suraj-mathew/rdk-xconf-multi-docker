#!/bin/sh
cd Cassandra
docker build -t "cassandra_image:v1" .
cd ../Xconf-admin
docker build -t "xconfadmin_image:v1" .
cd ../Xconf-data
docker build -t "xconfdata_image:v1" .

docker volume create --name=cassandra_data
docker image prune -f
echo .
echo 'Generated images'
echo '================'
docker images -a | grep _image
