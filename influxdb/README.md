InfluxDB Docker Container
=========


tl;dr
-----

* extended off of the excellent [tutum/influxdb](https://registry.hub.docker.com/u/tutum/influxdb/)
* modified config file (use RockDB and log to stdout)


Summary
-------

Over time we'll be extending the default [tutum/influxdb](https://registry.hub.docker.com/u/tutum/influxdb/) to better fit our needs:
* security
* logging
* data safety (raft changes, > 1 replication, etc.)


**[Details & Gotchas](#details)** are listed below.


Dependencies
-------

* [tutum/influxdb](https://registry.hub.docker.com/u/tutum/influxdb/)


<a name="todos"></a>
TODOs:
-------------------------
* transport-layer security using authorized ssl certs
* protect admin acct (random password)
