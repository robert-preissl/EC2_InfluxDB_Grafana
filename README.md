# EC2_InfluxDB_Grafana
Deploy an instance of influxDB and of Grafana on an EC2 instance.

The goal is to push any time series data to the EC2 influxDB instance. and then have the EC2 Grafana instance visualize the data.

InfluxDB version 0.9.0 and Grafana version 2.6.0 have been successfully tested on a t2.micro instance running 64bit Ubuntu Linux.

(Note, newer versions of InfluxDB and Grafana did not play well with each other. Gefana's influxDB plugin support InfluxDB version 0.8 and 0.9.)

# Tailing logs
InfluxDB: tail -f  /var/log/influxdb/influxd.log
Grafana:  tail -f /var/log/grafana/grafana.log

