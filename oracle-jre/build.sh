#!/bin/bash

set -m

docker build -t skippy/oracle-jre  .
docker push skippy/oracle-jre
