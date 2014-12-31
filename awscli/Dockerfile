FROM python:3.4-wheezy
MAINTAINER Adam Greene <adam.greene@gmail.com>

RUN	apt-get update && \
    apt-get install -y python-pip && \
    pip install awscli && \
    apt-get clean && \
	rm -rf /var/lib/apt/lists/*

WORKDIR /aws

ENTRYPOINT ["aws"]