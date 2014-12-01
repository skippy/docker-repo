### Todos:
* default dashboards
  - general system health (mem, cpu, disk)
  - component health (influxdb, elasticsearch, proxies, micro-services, queue depth)
  - app components (server requests, logins, Memory/CPU, client-side full page load, key controller hits)
* improve documentation!
* add security features:
  - transport security
  - lock down admin role
  - use client-specific users with limited roles (processes push data but cannot read; grafana can read but not modify)


### Notes

* this default grafana service uses `admin:mypass` for http basic auth.

* grafana has auto-complete for what is available from InfluxDB, but useful commands to run on Influx are:
   * list series `list series`
   * list columns in all series `select * from /.*/ limit 1`


Resources:
* examples 1: http://play.grafana.org/#/dashboard/db/grafana-play-home
* examples 2: http://play.grafana.org/#/dashboard/db/new-features-in-v19
* influxdb docs: http://influxdb.com/docs/v0.8/introduction/overview.html

