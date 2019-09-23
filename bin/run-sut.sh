#!/bin/sh

set -e

# run-sut.sh: Script to run system unit tests.

# Wait for chronyd to sync with sources.
sleep 20s

rc="0"

# The following tests query the server to verify that it is running and syncing with its pool servers.

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

# The following tests verify that our server is reponding to ntp queries.

# Let's setup the local daemon to query "our" server.
cat >/etc/chrony.conf <<-__EOF__
	server 10.30.50.2 iburst
	driftfile /var/lib/chrony/chrony.drift
	makestep 1.0 3
	keyfile /etc/chrony/chrony.keys
	logdir /var/log/chrony
	__EOF__

# Start the daemon.
chronyd -f /etc/chrony.conf

# Wait for it to come up.
sleep 10s

# Query the local sources.
if chronyc sources ; then
  echo "The local sources command succeeded!"
else
  echo "The local sources command failed!"
  rc="1"
fi

# Query the local tracking stats.
if chronyc tracking ; then
  echo "The local tracking command succeeded!"
else
  echo "The local tracking command failed!"
  rc="2"
fi

if [ "$rc" != "0" ]; then
  echo "Error: System unit tests failed!"
else
  echo "System unit tests succeeded!"
fi

exit $rc

