FROM debian:wheezy
MAINTAINER  Adam Greene <adam.greene@gmail.com>

RUN apt-get update -y && \
	apt-get install -y -q --no-install-recommends \
		python2.7-minimal \
		python-pip \
		openssl && \
	apt-get clean

RUN /usr/bin/pip -q install requests boto3

ADD service-toolkit /usr/local/bin/service-toolkit
RUN chmod +x /usr/local/bin/service-toolkit

USER daemon

ENTRYPOINT ["/usr/local/bin/service-toolkit"]
CMD        ["--help"]
