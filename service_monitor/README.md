ServiceMonitor
=========


tl;dr
-----

* service discovery
* service monitoring
* enable sequential service startup


Summary
-------

in **DEVELOPMENT** :)

This is a docker container for helping with service discovery, monitoring, and ordered service startup.  It is designed as a separate sidekick process so you can use this for things like [ElasticSearch](https://github.com/skippy/docker-repo/elasticsearch)-compatible interface startup, monitoring, and cluster management, without having to include this logic in your ElasticSearch container.

* **Service Monitoring:**  This will monitor a service and persist its up or down state.  If the `monitor-url` returns anything except a `2xx` http response code, it will be flagged as unavailable.  
* **Service Discovery:** This will return a comma-delimited list of hosts that are currently up and running.
* **Sequential Service Startup:** A lease can be grabbed, if available, or the command will block until a lease can be grabbed.  This can be used in conjunction with SystemD and Fleet to prevent services such as ElasticSearch from starting up at the same time and not correctly registering into a cluster.


**[Details](#details)** are listed below.



Usage: stand-alone
-------------------------

### Monitor
* Help: 

```bash
/usr/bin/docker run skippy/service_monitor watch --help
```

* monitor a service:

```bash
/usr/bin/docker run skippy/service_monitor watch \
	--label="MyService" \
	--service-id="Service-0x3241dc3" \
	--monitor-url="http://127.0.0.1:9200"
```

### Discovery
* Help: 

```bash
/usr/bin/docker run skippy/service_monitor hosts --help
```

* Return a comma-delimited list of hosts:

```bash
/usr/bin/docker run skippy/service_monitor hosts --label="MyService"
```

Usage: SystemD
-------------------------




Usage: CoreOS Fleet
-------------------------



Details[Details]:
-------------------------
