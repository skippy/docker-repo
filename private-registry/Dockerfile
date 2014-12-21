FROM registry:0.9.0
MAINTAINER  Adam Greene <adam.greene@gmail.com>

ENV STORAGE file
ENV STORAGE_PATH /tmp/registry
ENV SEARCH_BACKEND sqlalchemy
ENV SQLALCHEMY_INDEX_DATABASE sqlite:////tmp/registry/reg.db

ENV STANDALONE false
ENV MIRROR_SOURCE https://registry-1.docker.io
ENV MIRROR_SOURCE_INDEX https://index.docker.io
#ENV GUNICORN_OPTS '[--preload]'
