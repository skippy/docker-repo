FROM debian:wheezy
MAINTAINER  Adam Greene <adam.greene@gmail.com>

RUN apt-get update && \
	apt-get upgrade && \
	apt-get install -y --no-install-recommends \
		python \
		python-pip && \
	apt-get clean

RUN /usr/bin/pip install requests boto3

ADD bin/service-monitor /bin/service-monitor
RUN chmod +x /bin/service-monitor

USER daemon

ENTRYPOINT ["/bin/service-monitor"]
CMD        ["--help"]
