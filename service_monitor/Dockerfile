FROM debian:wheezy

RUN apt-get update && \
	apt-get install -y --no-install-recommends \
		python \
		python-pip \
		python-requests && \
	apt-get clean

RUN /usr/bin/pip install boto

ADD bin/service-monitor /bin/service-monitor
RUN chmod +x /bin/service-monitor

USER daemon

ENTRYPOINT ["/bin/service-monitor"]
CMD        ["--help"]
