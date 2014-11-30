FROM dockerfile/java:oracle-java7
MAINTAINER Adam Greene <adam.greene@gmail.com>

# Create directories
RUN mkdir -p /opt/logstash/ssl
RUN mkdir -p /etc/confd/conf.d
RUN mkdir -p /etc/confd/templates

# Install confd
RUN curl -L https://github.com/kelseyhightower/confd/releases/download/v0.6.3/confd-0.6.3-linux-amd64 -o /usr/local/bin/confd
RUN chmod +x /usr/local/bin/confd

# Install Logstash
# Save the SHA1 checksum from https://download.elasticsearch.org/logstash/logstash/logstash-1.4.2.tar.gz.sha1.txt
RUN echo 'd59ef579c7614c5df9bd69cfdce20ed371f728ff  logstash-1.4.2.tar.gz' > /tmp/logstash-1.4.2.tar.gz.sha1
RUN curl https://download.elasticsearch.org/logstash/logstash/logstash-1.4.2.tar.gz -o /tmp/logstash-1.4.2.tar.gz && \
	cd /tmp && sha1sum —-check /tmp/logstash-1.4.2.tar.gz.sha1 && \
	tar -xzf /tmp/logstash-1.4.2.tar.gz -C /opt/logstash/. --strip-components=1 && \
	rm /tmp/*

# Add files
ADD ./confd                   /etc/confd
ADD ./bin/boot.sh             /boot.sh

# Expose LumberJack protocol (logstash-forwarder)
# EXPOSE 514 514/udp 9200 9292 9300
EXPOSE 514 514/udp 

# Start the container
RUN chmod +x /boot.sh
CMD ["/boot.sh"]


# Clean up
#RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
