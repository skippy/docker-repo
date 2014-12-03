ServiceToolkit Docker Container
=========


tl;dr
-----

* service discovery
* service monitoring
* enable sequential service startup
* handle service security certificates (see [TODOS](#todos))
* service proxy


Summary
-------

in **DEVELOPMENT** :)

This is a docker container for helping with service discovery, monitoring, service certificate handling, and ordered service startup.  It is designed as a separate sidekick process so you can use this for things like [ElasticSearch](https://github.com/skippy/docker-repo/tree/master/elasticsearch)-compatible interface startup, monitoring, and cluster management, without having to include this logic in your ElasticSearch container.

* **Service Monitoring:**  This will monitor a service and persist its up or down state.  If the `monitor-url` returns anything except a `2xx` http response code, it will be flagged as unavailable.  
* **Service Discovery:** This will return a comma-delimited list of hosts that are currently up and running.
* **Sequential Service Startup:** A lease can be grabbed, if available, or the command will block until a lease can be grabbed.  This can be used in conjunction with SystemD and Fleet to prevent services such as ElasticSearch from starting up at the same time and not correctly registering into a cluster.
* **Service Certificate:** Create, store, and handle service security certificates.
* **Service Proxy:** Allow access to a service via a local proxy that ties into the Service Discovery layer.


**[Details & Gotchas](#details)** are listed below.


Dependencies
-------

* CoreOS
* ETCD & Fleet


Usage: stand-alone
-------------------------

### Monitor
* Help: `docker run skippy/service_toolkit watch --help`

* monitor a service:

```bash
docker run skippy/service_toolkit watch \
	--label="MyService" \
	--service-id="MyService-0x3241dc3" \
	--monitor-url="http://127.0.0.1:9200"
```


### Discovery
* Help: `docker run skippy/service_toolkit hosts --help`

* Return a comma-delimited list of hosts: `docker run skippy/service_toolkit hosts --label="MyService"`


### Startup Lease
* Help: `docker run skippy/service_toolkit acquire-lease --help`

* Acquire a startup lease (return 0 on success, or blocks for timeout and then return 1 if lease was not able to be acquired):
`docker run skippy/service_toolkit acquire-lease --label="MyService" --service-id="MyService-0x3241dc3"`


### Service Certificate
* Help: `docker run skippy/service_toolkit cert --help`

* Acquire a x509 set of certificates, returned in a json object.  The certs are created if they do not already exist:
`docker run skippy/service_toolkit cert --label=MyService --x509`


### Service Proxy
* Help: `docker run skippy/service_toolkit proxy --help`

* proxy to an external service that is already registered by the Monitoring service:
`
docker run --net=host skippy/service_toolkit proxy --service-label=MyService --local-port=9000 --service-port=9001`


Usage: Fleet
-------------------------
Check out an [example](https://github.com/skippy/docker-repo/tree/master/elasticsearch) of how the ServiceMonitor container is used within a [set of Fleet configuration files](https://github.com/skippy/docker-repo/blob/master/elasticsearch/fleet/)


<a name="details"></a>
Details & Gotchas:
-------------------------
This is for development and testing purposes only, at this point.  It is missing a few key components, but most importantly, it is NOT SECURE.  Anyone can call the service and pull down certificates, and the data in transit and at rest is not secure.  This needs to be addressed before it should be used in a true production setting.

To custom compile confd, do the following:
* `git clone https://github.com/kelseyhightower/confd.git`
* within native docker container (ie, not remote), run: `docker run -it --rm -v "$(pwd)/share/confd":/usr/src/myapp -w /usr/src/myapp golang:1.3.3-wheezy /bin/bash`
* within the go container, run:
```
go get -v -d ./...
go build -v -o confd-custom-linux-amd64
```

Tests:
-------------------------

* run tests: 

`$ test/test.sh`


<a name="todos"></a>
TODOs:
-------------------------
* allow AWS DynamoDB to be used as the discovery service
* improve help and documentation
* implement security in transit
* implement security at rest
* use standard confd.  