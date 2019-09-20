#!/bin/sh

set -e

# run-sut.sh: Script to run system unit tests.

# Wait for chronyd to sync with sources.
sleep 30s

rc="0"

# Query the sources.
if chronyc -h 10.30.50.2 sources ; then
  echo "The sources command succeeded!"
else
  echo "The sources command failed!"
  rc="1"
fi

# Query the tracking stats.
if chronyc -h 10.30.50.2 tracking ; then
  echo "The tracking command succeeded!"
else
  echo "The tracking command failed!"
  rc="2"
fi

if [ "$rc" != "0" ]; then
  echo "Error: System unit tests failed!"
else
  echo "System unit tests succeeded!"
fi

exit $rc

