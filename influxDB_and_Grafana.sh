#!/bin/bash

# AWS hostname
AWS_EC2_HOSTNAME_URL=$(curl -s http://169.254.169.254/latest/meta-data/public-hostname) # http://169.254.169.254/latest/meta-data/public-hostname

# InfluxDB
INFLUXDB_DATABASE=test1
INFLUXDB_PKG=influxdb_0.9.0_amd64.deb
INFLUXDB_URL=http://influxdb.s3.amazonaws.com/$INFLUXDB_PKG

# Grafana
GRAFANA_PKG=grafana_2.6.0_amd64.deb
GRAFANA_URL=https://grafanarel.s3.amazonaws.com/builds/$GRAFANA_PKG

# ----------------------------------------------------------------------

echo "Update packages"
sudo apt-get update
echo " "
echo " "

public_hostname=$AWS_EC2_HOSTNAME_URL
echo "Public hostname of this EC2 instance is: $public_hostname"
echo " "
echo " "

echo "Update ubuntu packages."
sudo apt-get update
echo " "
echo " "

echo "Downloading and installing Influxdb."
wget $INFLUXDB_URL
sudo dpkg -i $INFLUXDB_PKG
sudo kill -9 $(pidof influxd) # kill the running influxdb process
sudo /etc/init.d/influxdb start
echo " "
echo " "

echo "Downloading and installing Grafana."
wget $GRAFANA_URL
sudo kill -9 $(pidof grafana-server) # kill the running grafana process
sudo apt-get install -y adduser libfontconfig
sudo dpkg -i $GRAFANA_PKG
sudo service grafana-server start
echo " "
echo " "

echo "Configuring and restarting Grafana."
sudo sed -i "s|= localhost|= $public_hostname|g" /etc/grafana/grafana.ini
sudo service grafana-server restart
echo " "
echo " "

echo "Creating Influxdb database $INFLUXDB_DATABASE."
curl -G 'http://localhost:8086/query' --data-urlencode 'q=CREATE DATABASE "'"$INFLUXDB_DATABASE"'"'
for i in {1..1000}
do
	val=$((i%100))
	curl -POST http://localhost:8086/write?db=$INFLUXDB_DATABASE --data-binary 'cpu_load_short,host=server01,region=us-west value='"$val".0''
done
echo " "
echo " "

echo -e "Configuration complete. You can find InfluxDB and Grafana at the URLs below.\n"
echo "Influxdb URL:     http://$public_hostname:8083"
echo "Grafana URL:      http://$public_hostname:3000"
echo " "
echo " "
