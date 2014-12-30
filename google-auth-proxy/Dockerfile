FROM flynn/busybox
MAINTAINER Adam Greene <adam.greene@gmail.com>

ADD ./bin/google_auth_proxy /bin/google_auth_proxy

EXPOSE 4180

ENTRYPOINT ["google_auth_proxy"]