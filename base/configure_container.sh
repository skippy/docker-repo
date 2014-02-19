#!/bin/bash
set -e

# Setup common information; other images that build upon this base image can append
# to this file!
# NOTE: there is a bug in supervisorD where if this runs in less than 1 second,
# it will be flagged as an unexpected error and placed into a FATAL state.
# BUT we only want this to run once and exit cleanly.  So ignore that error for
# now.  See https://github.com/Supervisor/supervisor/issues/212

echo 'Configuring Container -- Base'
