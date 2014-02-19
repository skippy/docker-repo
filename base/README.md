# Base Docker Image

Designed to setup a docker image to be production ready, with things such as:
* syslog (and consolidated logging)
* log rotation
* supervisorD
* cron
* metric hooks
* ssh (optional)


This is a work in progress, so use at your own risk.


### TODOS
* SSH, and making it an optional component that can be turned on at run time
* figure out pathway for consolidated logging; do we push everything through syslog or go through supervisorD?
* ditto for metrics; do we put a metric process in the container or on the host?  If on the container; what is the best one for docker?  And do we add something like boundary?



### Inspiration
Obviously [Inspired by BaseImage-Docker](http://phusion.github.io/baseimage-docker/) has a lot to do with this.  I'm not a fan of how they setup ssh, nor that it is on by default.  I love RUNIT, but considering that the industry seems to be consolidating around [supervisorD](http://supervisord.org/), I wanted to use that.

The docker files from [Krijger](https://github.com/Krijger/docker-cookbooks) and [orchardup](https://github.com/orchardup) provide great ideas on how to organize docker containers and pass in variables at runtime.

-----------------------------------------

**Related resources**:
  [Inspired by BaseImage-Docker](http://phusion.github.io/baseimage-docker/)
