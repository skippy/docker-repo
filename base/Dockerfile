FROM        ubuntu:12.04
MAINTAINER  Adam Greene <adam.greene@gmail.com>

## setting up useful ENV variables
ENV         LC_ALL C
ENV         DEBIAN_FRONTEND noninteractive

## Enable Ubuntu Universe.
RUN         echo deb http://archive.ubuntu.com/ubuntu precise main universe > /etc/apt/sources.list
RUN         echo deb http://archive.ubuntu.com/ubuntu precise-updates main universe >> /etc/apt/sources.list

## update default packages
RUN         apt-get update

## Enable APT https transport
RUN         apt-get install -y apt-transport-https

## Fix some issues with APT packages.
## See https://github.com/dotcloud/docker/issues/1024
RUN         dpkg-divert --local --rename --add /sbin/initctl
RUN         ln -sf /bin/true /sbin/initctl

# Upgrade packages
RUN         echo "initscripts hold" | dpkg --set-selections
RUN         apt-get upgrade -y --no-install-recommends

## Fix locale.
RUN         apt-get install -y language-pack-en
RUN         locale-gen en_US

## Basic requirements
RUN         apt-get -y install supervisor cron curl syslog-ng-core

## Setting up SupervisorD
ADD         supervisord.conf /etc/supervisor/conf.d/default.conf

## Setting up syslog
RUN         mkdir -p /var/lib/syslog-ng

## lets cleanup so the image size is small(er)
RUN         apt-get clean
RUN         rm -rf /tmp/* /var/tmp/* /var/log/*.log /var/log/*/*.log

CMD         /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
