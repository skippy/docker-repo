Fleet config files
=========


tl;dr
-----

* setup 1+ ElasticSearch clusters
* have nodes startup one at a time
* monitor nodes
* restart services on the local node if they fail
* restart services on other nodes if the node goes down


Summary
-------

[Fleet](https://github.com/coreos/fleet) is a work in progress, but it is pretty damn nice as it is.  It isn't ready for production (see [Details & Gotchas](#details) below), but it is getting there.

The included Fleet config files manage the following:
* setup 1 or more ElasticSearch clusters
   * label the node ElasticSearch_logging
   * set the replica factor to 3
* have the ElasticSearch nodes startup sequentially.  This prevents all of the nodes from starting at once and not discovering anyone else. 
* the nodes are monitored.  Once they are joined to a cluster, the cluster will manage and remove stale nodes.  However, if new nodes are started, they will only see the currently active hosts.

All this logic can be collapsed into one file, but breaking it out has the advantage of making the logic more easily transferable to non-fleet deployment schemes like Google's [Container Engine](https://cloud.google.com/container-engine/) or AWS's [Elastic Container Service](https://aws.amazon.com/ecs/).  Plus it is easier to read and grok.

**[Details & Gotchas](#details)** are listed below.


Dependencies
-------

* CoreOS
* ETCD & Fleet


Usage: Fleet
-------------------------
After you have your CoreOS cluster setup (see their [docs](https://coreos.com/docs/)), make the fleet files accessible within a CoreOS instance (perhaps via a [Vagrant shared directory](https://coreos.com/docs/running-coreos/platforms/vagrant#shared-folder-setup)).

To register and startup a 5-node ElasticSearch cluster, run the following:

```
fleetctl stop -block-attempts=3 elasticsearch_logging@{1..5}.service

fleetctl destroy elasticsearch_logging@.service elasticsearch_logging-discovery@.service elasticsearch_logging-startup_lease@.service elasticsearch_logging@{1..5}.service elasticsearch_logging-discovery@{1..5}.service elasticsearch_logging-startup_lease@{1..5}.service

fleetctl submit ./elasticsearch_logging@.service ./elasticsearch_logging-discovery@.service ./elasticsearch_logging-startup_lease@.service

fleetctl load elasticsearch_logging@{1..5}.service elasticsearch_logging-discovery@{1..5}.service elasticsearch_logging-startup_lease@{1..5}.service

fleetctl start elasticsearch_logging@{1..5}.service
```

That is not the prettiest and is the downside of splitting up the logic into 3 separate files.  Here is what is going on:

* stopping the service if it is already running.  All the child services (startup_lease and discovery are tied to this main service and will start or stop based upon what the main service does)
* remove from Fleet all related files.  This has to include the base File (e.g. `elasticsearch_logging@.service`) as well as all its instance-specific versions (e.g. `elasticsearch_logging@1.service`, `elasticsearch_logging@2.service`, etc.)
* submit the base files into fleet.  These are read from the command line so they must be a relative or absolute path.
* now lets tell Fleet where to distribute the files.  All files, including the supporting SystemD config files, need to be deployed.  
* And **finally**, lets start the service.  Give it about 30 seconds and then watch the instances become available!  `http://IP_ADDRESS:9200/_plugin/marvel`


Some useful commands to see what is going on are:
```
fleetctl list-machines
fleetctl list-unit-files
fleetctl list-units
fleetctl journal -f elasticsearch_logging@1.service
```


<a name="details"></a>
Details & Gotchas:
-------------------------
Fleet is not production ready, for a few different reasons:
* the scheduler will, after any `[X-Fleet]` directives, places the docker container on the CoreOS node which has least recently received a new SystemD config file.  
* The order of Fleet commands needs to be followed very carefully... if you `destroy` before `stop`, you'll be SOL.  You have to `destroy` all versions of the unit-files otherwise when you go to load, you won't get the latest version.
* `start` doesn't work if nothing has been `load`(-ed)

BUT, Fleet is definitely getting there!



<a name="todos"></a>
TODOs:
-------------------------
