Elasticsearch Docker Container
=========


tl;dr
-----

* extends [dockerfile/elasticsearch](https://registry.hub.docker.com/u/dockerfile/elasticsearch/)
* adds [marvel](http://www.elasticsearch.org/overview/marvel/) and [kibana3](http://www.elasticsearch.org/overview/kibana/) plugins
* Fleet SystemD config files to create self-registered ElasticSearch Cluster.


Summary
-------

The base ElasticSearch container works quite well!  This just adds some helpful plugins.  The real fun stuff is around the ElasticSearch cluster self-registering, which you can see with the included [Fleet configuration files](https://github.com/skippy/docker-repo/blob/master/elasticsearch/fleet/README.md)


**[Details & Gotchas](#details)** are listed below.



Dependencies
-------

For anything dealing with clustering, they currently are:

* CoreOS
* ETCD & Fleet
* [Skippy/ServiceToolkit](https://registry.hub.docker.com/u/skippy/service_toolkit/)



<a name="details"></a>
Details & Gotchas:
-------------------------
ES is not secure by default and thus does not meet numerous regulatory and compliance requirements.  Options include:

* waiting for [ES Shield](http://www.elasticsearch.com/products/shield/)
* futz around with [elasticsearch-jetty](https://github.com/sonian/elasticsearch-jetty)
* ditto with [elasticsearch-security-plugin](https://github.com/salyh/elasticsearch-security-plugin)



<a name="todos"></a>
TODOs:
-------------------------
* figure out a security picture