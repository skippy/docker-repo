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


**[Details & Gotchas](#details)** are listed below.


Dependencies
-------

* CoreOS
* Docker
* ETCD & Fleet


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

### Startup Lease
* Help: 

```bash
/usr/bin/docker run skippy/service_monitor acquire-lease --help
```

* Acquire a startup lease (return 0 on success, or blocks for timeout and then return 1 if lease was not able to be acquired)

```bash
/usr/bin/docker run skippy/service_monitor acquire-lease --label="MyService" --service-id="Service-0x3241dc3"
```

Usage: Fleet
-------------------------
Here is an example systemd configuration file for starting a cluster of elasticsearch instances and have them self-cluster.

**NOTE** there are two ways to do this; one is you can put everything in one file, as shown below.  The 'better' approach is to break this up into 3 files:
* lease acquistion
* main service
* monitor

```
# Design:
#  The goal is to bring up ElasticSearch, and allow it to
#  self-join the ElasticSearch Logging cluster.
#  This requires a few things:
#   - Instances can't all come online at once otherwise they 
#     won't be able to find any members of the cluster, as they
#     will all think they are the first.
#   - Allow ElasticSearch to take unto 240 seconds to boot up 
#     before we allow the next instance in the cluster to come online
#

[Unit]
Description=%p-%i

# Requirements
Requires=etcd.service
Requires=docker.service

# Dependency ordering
After=etcd.service
After=docker.service
 

[Service]
# Let processes take awhile to start up (for first run Docker containers)
TimeoutStartSec=0
# keep kill mode, but lets give docker plenty of chances to stop cleanly
TimeoutStopSec=90

# have SystemD restart the service if it goes down
Restart=always
RestartSec=10s

# Change killmode from "control-group" to "none" to let Docker remove
# work correctly.
KillMode=none

# Get CoreOS environmental variables
EnvironmentFile=/etc/environment

# Pre-start and Start
## Directives with "=-" are allowed to fail without consequence
ExecStartPre=-/usr/bin/docker kill %p-%i
ExecStartPre=-/usr/bin/docker kill %p-monitor-%i
ExecStartPre=-/usr/bin/docker kill %p-monitor_lock-%i
ExecStartPre=-/usr/bin/docker rm %p-%i
ExecStartPre=-/usr/bin/docker rm %p-monitor-%i
ExecStartPre=-/usr/bin/docker rm %p-monitor_lock-%i
ExecStartPre=/usr/bin/docker pull skippy/elasticsearch
ExecStartPre=/usr/bin/docker pull skippy/service_monitor
ExecStartPre=/usr/bin/docker pull busybox
## Create a data container that doesn't go away on restarts.
ExecStartPre=-/usr/bin/docker run -v /var/lib/%p:/data --name esldata busybox /bin/echo "Data volume container for %p-%i" 
## block startup process until we can acquire a lease.
## Fail and have SystemD retry if the lease cannot be acquired.
ExecStartPre=/usr/bin/docker run --rm --name %p-monitor_lock-%i skippy/service_monitor acquire-lease --label=%p --service-id=%p-%i --host-ip=${COREOS_PRIVATE_IPV4}

## lets:
##  - get all running cluster hosts;
##  - startup elastic search, linking to cluster hosts, if any!
ExecStart=/bin/bash -c '\
	UNICAST_HOSTS=$(/usr/bin/docker run \
			--rm \
			skippy/service_monitor hosts \
				--label=%p \
				--host-ip=${COREOS_PRIVATE_IPV4} \
		| sed "s/$/:9300/" \
		| paste -s -d","); \
	if [ "$UNICAST_HOSTS" = "" ]; then \
		systemd-cat -t "[%p]" echo "Initial cluster node"; \
	else \
		systemd-cat -t "[%p]" echo "Connecting to cluster hosts: $UNICAST_HOSTS"; \
    fi; \
	/usr/bin/docker run \
		--rm \
		--name %p-%i \
		--volumes-from esldata \
		-p 9200:9200 -p 9300:9300 \
		skippy/elasticsearch \
		/elasticsearch/bin/elasticsearch \
			-Des.default.cluster.name=Logging \
			-Des.default.node.name=%p-%i \
			-Des.default.bootstrap.mlockall=true \
			-Des.default.index.number_of_replicas=3 \
			-Des.default.network.publish_host=${COREOS_PRIVATE_IPV4} \
			-Des.default.discovery.zen.ping.multicast.enabled=false \
			-Des.default.discovery.zen.ping.unicast.hosts=$UNICAST_HOSTS'

## lets:
##  - after this node is started, remove the lock 
##    so the next node can startup.
##  - keep a watch on the health of the instance
ExecStartPost=/bin/bash -c '\
	/usr/bin/docker run \
		--rm \
		--name %p-monitor-%i \
		skippy/service_monitor watch \
			--label="%p" \
			--service-id="%p-%i" \
			--host-ip=${COREOS_PRIVATE_IPV4} \
			--monitor-url="http://${COREOS_PRIVATE_IPV4}:9200" \
			--service-info=\'{"http_port": 9200, "transport_port": 9300, "name": "%p-%i"}\' '

# Give Docker time to nicely kill the running containers
# before SystemD does.
ExecStop=/usr/bin/docker stop -t 10 %p-monitor_lock-%i
ExecStop=/usr/bin/docker stop -t 10 %p-monitor-%i
ExecStop=/usr/bin/docker stop -t 30 %p-%i
```



<a name="details"></a>Details & Gotchas:
-------------------------


<a name="todos"></a>TODOs:
-------------------------
* break up Fleet examples into 3 separate SystemD files
* allow AWS DynamoDB to be used as the discovery service
* add a test suite!
* improve help and documentation