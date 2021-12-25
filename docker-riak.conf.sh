#!/usr/bin/env bash

# Defaul riak config - /etc/riak/riak.conf
cat << EOF > $RIAK_CONF
log.console = ${RIAK_LOG_CONSOLE:-file}
log.console.level = ${RIAK_LOG_CONSOLE_LEVEL:-info}
log.console.file = /var/log/riak/console.log 
log.error.file = /var/log/riak/error.log
log.syslog = ${RIAK_LOG_SYSLOG:-off}
log.crash = ${RIAK_LOG_CRASH:-on}
log.crash.file = /var/log/riak/crash.log
log.crash.maximum_message_size = ${RIAK_LOG_CRASH_MAXIMUM_MESSAGE_SIZE:-64KB}
log.crash.size = ${RIAK_LOG_CRASH_SIZE:-10MB}
log.crash.rotation.keep = ${RIAK_LOG_CRASH_ROTATION_KEEP:-5}
EOF
echo 'log.crash.rotation = $D0' >> $RIAK_CONF
cat << EOF >> $RIAK_CONF

nodename = ${RIAK_NODENAME:-riak}@${RIAK_HOST:-127.0.0.1}

ring_size = ${RIAK_RING_SIZE}

distributed_cookie = ${RIAK_COOKIE:-riak}

erlang.async_threads = ${RIAK_ERLANG_ASYNC_THREADS:-64}
erlang.max_ports = ${RIAK_ERLANG_MAX_PORTS:-262144}

dtrace = ${RIAK_DTRACE:-off}

platform_bin_dir = /usr/sbin
platform_data_dir = ${RIAK_DATA_DIR}
platform_etc_dir = /etc/riak
platform_lib_dir = /usr/lib/riak/lib
platform_log_dir = ${RIAK_LOGS_DIR:-/var/log/riak}

listener.http.internal = ${HOST:-127.0.0.1}:${RIAK_LISTENER_HTTP_INTERNAL_PORT:-8098}
listener.protobuf.internal = ${HOST:-127.0.0.1}:${RIAK_LISTENER_PROTOBUF_INTERNAL:-8087}

anti_entropy = ${RIAK_ANTI_ENTROPY:-active}

storage_backend = ${RIAK_STORAGE_BACKEND:-leveldb}

object.format = ${RIAK_OBJECT_FORMAT:-1}
object.size.warning_threshold = ${RIAK_OBJECT_SIZE_WARNING_THRESHOLD:-5MB}
object.size.maximum = ${RIAK_OBJECT_SIZE_MAXIMUM:-50MB}
object.siblings.warning_threshold = ${RIAK_OBJECT_SIBLINGS_WARNING_THRESHOLD:-25}
object.siblings.maximum = ${RIAK_OBJECT_SIBLINGS_MAXIMUM:-100}

bitcask.data_root = ${RIAK_BITCASK_DATA_ROOT:-$RIAK_DATA_DIR/bitcask}
bitcask.io_mode = ${RIAK_BITCASK_IO_MODE:-erlang}

riak_control = ${RIAK_CONTROL:-off}
riak_control.auth.mode = ${RIAK_CONTROL_AUTH_MODE:-off}

leveldb.maximum_memory.percent = ${RIAK_LEVELDB_MAXIMUM_MEMORY_PERCENT:-70}
leveldb.compression = ${RIAK_LEVELDB_COMPRESSION:-on}
leveldb.compression.algorithm = ${RIAK_LEVELDB_COMPRESSION_ALGORITHM:-lz4}
leveldb.write_buffer_size_min = ${RIAK_LEVELDB_WRITE_BUFFER_SIZE_MIN:-30MB}
leveldb.write_buffer_size_max = ${RIAK_LEVELDB_WRITE_BUFFER_SIZE_MAX:-60MB}
leveldb.block.size = ${RIAK_LEVELDB_BLOCK_SIZE:-16KB}
leveldb.bloomfilter = ${RIAK_LEVELDB_BLOOMFILTER:-on}
leveldb.tiered = ${RIAK_LEVELDB_TIERED_LEVEL:-4}
leveldb.tiered.path.fast = ${RIAK_LEVELDB_TIERED_PATH_FAST:-$RIAK_DATA_DIR/leveldb/fast}
leveldb.tiered.path.slow = ${RIAK_LEVELDB_TIERED_PATH_SLOW:-$RIAK_DATA_DIR/leveldb/slow}
leveldb.data_root = ${RIAK_LEVELDB_DATA_ROOT:-./}

search = ${RIAK_SEARCH:-off}
search.solr.start_timeout = ${RIAK_SEARCH_SOLR_START_TIMEOUT:-30s}
search.solr.port = ${RIAK_SEARCH_SOLR_PORT:-8093}
search.solr.jmx_port = ${RIAK_SEARCH_SOLR_JMX_PORT:-8985}
search.solr.jvm_options = ${RIAK_SEARCH_SOLR_JVM_OPTIONS:--d64 -Xms1g -Xmx1g -XX:+UseStringCache -XX:+UseCompressedOops}

EOF
