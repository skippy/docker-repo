#
FROM dockerfile/elasticsearch:latest
MAINTAINER Adam Greene <adam.greene@gmail.com>

# need to run as root as long as dockerfile/elasticsearch created all the dirs under root
# RUN useradd -Mr elasticsearch
# USER elasticsearch

# lets remove the plugin folder so it isn't in a data volume we may want to mount in the host system
RUN sed -i '/\plugins/d' /elasticsearch/config/elasticsearch.yml

# Install plugins
RUN /elasticsearch/bin/plugin --install elasticsearch/marvel/latest
RUN /elasticsearch/bin/plugin -url http://download.elasticsearch.org/kibana/kibana/kibana-latest.zip --install elasticsearch/kibana3

# Start Elasticsearch
CMD ["/elasticsearch/bin/elasticsearch"]
