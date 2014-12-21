Private Registry
================



tl;dr
-----

* run in mirror mode to cache images locally
* add `DOCKER_REPO` to `/etc/environment` to allow ability to pull locally
* takes care of registration and discovery of your local docker registry
* the private registry is using dev parameters


Usage:
------

```console
docker run \
	--rm \
   	--name %p \
    -p 5000:5000 \
    -v /my/cache/path:/data \
    skippy/private-registry
```

The database and images cache are located within /data, so use `-v` to mount that volumn in a space that will be persisted across container reboots.

There are a few bugs within the base `registry:0.9.0` that can cause problems with startups, such as a race condition on building the sqlite tables.  If you use `-v`, you may need to run it a few times to get it to come up.  See `fleet/docker-registry.service` for ways to start it up under systemd


Usage: via Fleet
----------------

After you have your CoreOS cluster setup (see their [docs](https://coreos.com/docs/)), it helps to have a shared folder which makes this repository available within the CoreOS instance(perhaps via a [Vagrant shared directory](https://coreos.com/docs/running-coreos/platforms/vagrant#shared-folder-setup)).

To launch the docker registry, as well as setup it's registration and discovery scripts, run
```console
$ fleetctl start fleet/docker-registry*
```

to stop, run
```console
$ fleetctl destroy fleet/docker-registry*
```



Details
-------

Running a local registry (in mirror mode!) has numerous advantages:

* instead of pulling down the same image over and over again, say on multiple coreOS hosts, you pull it down from the docker index *once*, and then each host pulls the locally cached copy.  This can be 4-8x faster.

* you can push to your local registry.  This speeds up testing of trusted builds, as well as allow you to keep things off of the docker hub if that is your need.

When used with fleet, this set of scripts does a few things:

* it registers the local docker registry, and then restarts each host's docker daemon to pick up the local mirror.
* it adds `DOCKER_REPO` to each host's `/etc/environment` file.  This allows you to do things like, in your systemd `<my-service>.service` files, `/usr/bin/docker pull ${DOCKER_REPO}skippy/elasticsearch`, and if your local docker registry is up and running, it will attempt to pull from there, and if it is not running, it will pull from the main docker index.  handy!
* it checks every few seconds, so if the local registry changes hosts or is removed, those changes will be picked up in short order.  
* It cleans up after itself if the registry no longer exists.


To run with production parameters, see [docker-registry configuration](https://github.com/docker/docker-registry#configuration-flavors) for additional information.


Dependencies
------------

None unless you want to use fleet, in which case they are:
* [ETCD](https://github.com/coreos/etcd)
* [Fleet](https://github.com/coreos/fleet)
* docker container [skippy/service-toolkit](https://registry.hub.docker.com/u/skippy/service_toolkit/)



Details & Gotchas:
------------------
* this caches images at `/home/core/share/.docker_registry_cache`.  This assumes a standard CoreOS and vagrant setup.  If you would like to change that location, check out `fleet/docker-registry.service`



TODOs:
------
