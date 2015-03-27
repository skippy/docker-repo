#!/bin/bash

set -m

docker build -t skippy/ruby:2.2  .
docker push skippy/ruby:2.2
