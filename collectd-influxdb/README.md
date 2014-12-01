CollectD -> InfluxDB Docker Container
=========


tl;dr
-----

* sends data to a InfluxDB that has the collectD plugin enabled
* uses [Confd](https://github.com/kelseyhightower/confd) for hooking up InfluxDB location with CollectD


Summary
-------

CAdvisor and Heapster work well for gathering metrics on the containers, but we still need to monitor the docker host, right?  *Right??* :)  

This requires 2 things:

* InfluxDB with the collectD plugin enabled.  See [skippy/influxdb config file](https://github.com/skippy/docker-repo/blob/master/influxdb/config.toml)
* the InfluxDB hosts are expected to have the following key in etcd `/services/influxdb/hosts/<IP-ADDR>`  If you are curious how to self-register a InfluxDB cluster (using Fleet), see the [skippy/influxdb fleet files](https://github.com/skippy/docker-repo/blob/master/influxdb/fleet/boot.sh)


Usage
-------

There are two ways to start this container:

    docker run --name collectd --net=host skippy/collectd-influxdb

or without `--net=host`

	docker run --name collectd -e ETCD_IP=<ETCD_IP> skippy/collectd-influxdb


Dependencies
-------
For anything dealing with clustering, they currently are:

* [etcd](https://github.com/coreos/etcd)
* [Confd](https://github.com/kelseyhightower/confd)



<a name="todos"></a>
TODOs:
-------------------------
* use a standard build of ConfD instead of the custom build from the master branch of kelseyhightower/confd
* right now we direct all collectD traffic to the first influxDB host registered in etcd.  This should be randomized
* confd does not pass along output from STDOUT.  So I have to send collectD to log and then tail the log.  This is a problem in case the log file fills up (highly unlikely I know, but still).  Confd seemed to used to be able to pickup and pass back STDOUT, but no more.