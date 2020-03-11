#!/usr/bin/env bash

# Default riak system limits config 
cat << EOF > $RIAK_LIMITS_CONF
riak soft nofile ${RIAK_SET_ULIMIT}
riak hard nofile ${RIAK_SET_ULIMIT}
root soft nofile ${RIAK_SET_ULIMIT}
root hard nofile ${RIAK_SET_ULIMIT}

EOF