#!/usr/bin/env bash

set -e

# Default riak config files
declare -x RIAK_CONF=/etc/riak/riak.conf
declare -x RIAK_ADVANCED_CONF=/etc/riak/advanced.config

if [ -z $RIAK_SET_ULIMIT ]; then
    declare -x RIAK_SET_ULIMIT=262144
fi

# Set riak ring size if not defined
if [ -z $RIAK_RING_SIZE ]; then
    declare -x RIAK_RING_SIZE=64
fi

# Get host ipv4 default address
if [ -z $HOST ]; then
    declare -x HOST=`hostname -i`
fi

# Default riak binary
if [[ -x /usr/sbin/riak ]]; then
  declare -x RIAK=/usr/sbin/riak
else
  declare -x RIAK=$RIAK_HOME/bin/riak
fi

# Default riak-admin binary
if [[ -x /usr/sbin/riak-admin ]]; then
  declare -x RIAK_ADMIN=/usr/sbin/riak-admin
else
  declare -x RIAK_ADMIN=$RIAK_HOME/bin/riak-admin
fi

# Default riak data directory
if [ -z $RIAK_DATA_DIR ]; then
    declare -x RIAK_DATA_DIR=/var/lib/riak
fi

# Default riak logs directory
if [ -z $RIAK_LOGS_DIR ]; then
    declare -x RIAK_LOGS_DIR=/var/log/riak
fi

# Default riak schemas directory
declare -x SCHEMAS_DIR=/etc/riak/schemas/

# Run all prestart scripts
PRESTART=$(find /etc/riak/prestart.d -name *.sh -print | sort)
for script in $PRESTART; do
  . $script
done

# Ensure LevelDB directories exist
mkdir -p $RIAK_DATA_DIR/leveldb/fast $RIAK_DATA_DIR/leveldb/slow

# Ensure directory owner is riak
chown -R riak:riak $RIAK_DATA_DIR $RIAK_LOGS_DIR

# Check riak config before start
if [ "$RIAK_CHECKCONFIG" != 'False' ]; then
    $RIAK chkconfig
    ULIMIT=`ulimit -n`; echo "Ulimit is: $ULIMIT"
fi

# Clean up the ring files | Useful when the ip address changed
if [ "$RIAK_RING_CLEANUP" == 'True' ]; then
    rm $RIAK_DATA_DIR/ring/*
fi

# Start the node and wait until fully up
if [ "$RIAK_AUTOSTART" != 'False' ]; then
    $RIAK start &
    $RIAK_ADMIN wait-for-service riak_kv
fi

# Run all poststart scripts
POSTSTART=$(find /etc/riak/poststart.d -name *.sh -print | sort)
for script in $POSTSTART; do
  . $script
done

# Read riak logs
if [ "$RIAK_AUTOSTART" != 'False' ]; then
    tail -n 1024 --retry -F /var/log/riak/console.log /var/log/riak/error.log
fi

# # Trap SIGTERM and SIGINT 
PID=$!
trap "$RIAK stop; kill $PID" SIGTERM SIGINT
wait $PID

# Run custom command if needed
exec "$@"