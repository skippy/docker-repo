#!/bin/bash

set -m

docker pull golang:1.4
docker run --rm -v "$(pwd)/bin":/go/bin golang:1.4 go get github.com/bitly/google_auth_proxy

docker build -t skippy/google_auth_proxy:latest  .
