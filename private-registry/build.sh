#!/bin/bash

set -me

docker build -t skippy/private-registry .
docker push skippy/private-registry
