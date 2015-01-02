#!/bin/bash

set -m

docker pull golang:1.4
docker run --rm -v "$(pwd)/bin":/go/bin golang:1.4 go get github.com/hashicorp/consul-template

docker build -t skippy/consul-template:latest  .
