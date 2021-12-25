# Riak KV Docker image

Refreshed docker image with configuration improvements.
Now it's possible to change almost everything in riak.conf with environment variables.

### Current versions:

**Riak KV 2.2.3**

*Current tags:* [`stable`](https://github.com/kefirgames/riak_docker/blob/master/2.2.3/Dockerfile), [`2.2.3`](https://github.com/kefirgames/riak_docker/blob/master/2.2.3/Dockerfile), [`stable-basho`](https://github.com/kefirgames/riak_docker/blob/basho/2.2.3/Dockerfile), [`2.2.3-basho`](https://github.com/kefirgames/riak_docker/blob/basho/2.2.3/Dockerfile)

Based on `ubuntu:16.04`. Installed from [official packages](https://s3.amazonaws.com/downloads.basho.com), in `-basho` installed from now-defunct (after Basho bankruptcy) [packagecloud.io packages](https://packagecloud.io/basho/riak).

Current stable version production ready.

**Riak KV 2.9.2**

*Current tags:* [`latest`](https://github.com/kefirgames/riak_docker/blob/master/2.9/Dockerfile), [`2.9`](https://github.com/kefirgames/riak_docker/blob/master/2.9/Dockerfile), [`2.9.2`](https://github.com/kefirgames/riak_docker/blob/master/2.9/Dockerfile)

Based on `debian:buster-slim` compiled with OpenSSL 1.0.2u (20-Dec-2019) and Basho's Erlang OTP 16

First post-basho version. *Use at your own risk.* [Release notes](https://github.com/basho/riak/blob/develop-2.9/RELEASE-NOTES.md#riak-kv-291-release-notes).

###Default storage 
**LevelDB** (tiered, level 4), use `RIAK_STORAGE_BACKEND` variable to override.

## Run with docker-compose 
The `environment` variables below in example docker-compose.yml is set by default, therefore, you can run riak without specifying any parameters or variables just like that: `docker run -d kefirgames/riak:2.2.3`. And it will work fine.
```
version: "2"

volumes:
    riak: 

services:
  riak:
    image: kefirgames/riak:2.2.3
    ports:
      - "8087:8087"
      - "8098:8098"
    volumes:
      - riak:/etc/riak/schemas
    environment:
        - RIAK_LOG_CONSOLE=file
        - RIAK_LOG_CONSOLE_LEVEL=info
        - RIAK_LOG_SYSLOG=off
        - RIAK_LOG_CRASH=on
        - RIAK_LOG_CRASH_MAXIMUM_MESSAGE_SIZE=64KB
        - RIAK_LOG_CRASH_SIZE=10MB
        - RIAK_LOG_CRASH_ROTATION_KEEP=5
        - RIAK_NODENAME=riak
        - RIAK_RING_SIZE=64
        - RIAK_COOKIE=riak
        - RIAK_ERLANG_ASYNC_THREADS=64a
        - RIAK_ERLANG_MAX_PORTS=262144
        - RIAK_DTRACE=off
        - RIAK_DATA_DIR
        - RIAK_LOGS_DIR=/var/log/riak
        - RIAK_LISTENER_HTTP_INTERNAL_PORT=8098
        - RIAK_LISTENER_PROTOBUF_INTERNAL=8087
        - RIAK_ANTI_ENTROPY=active
        - RIAK_STORAGE_BACKEND=leveldb
        - RIAK_OBJECT_FORMAT=1
        - RIAK_OBJECT_SIZE_WARNING_THRESHOLD=5MB
        - RIAK_OBJECT_SIZE_MAXIMUM=50MB
        - RIAK_OBJECT_SIBLINGS_WARNING_THRESHOLD=25
        - RIAK_OBJECT_SIBLINGS_MAXIMUM=100
        - RIAK_BITCASK_DATA_ROOT=$- RIAK_DATA_DIR/bitcask
        - RIAK_BITCASK_IO_MODE=erlang
        - RIAK_CONTROL=off
        - RIAK_CONTROL_AUTH_MODE=off
        - RIAK_LEVELDB_MAXIMUM_MEMORY_PERCENT=70
        - RIAK_LEVELDB_COMPRESSION=on
        - RIAK_LEVELDB_COMPRESSION_ALGORITHM=lz4
        - RIAK_LEVELDB_WRITE_BUFFER_SIZE_MIN=30MB
        - RIAK_LEVELDB_WRITE_BUFFER_SIZE_MAX=60MB
        - RIAK_LEVELDB_BLOCK_SIZE=16KB
        - RIAK_LEVELDB_BLOOMFILTER=on
        - RIAK_LEVELDB_TIERED_LEVEL=4
        - RIAK_LEVELDB_TIERED_PATH_FAST=$- RIAK_DATA_DIR/leveldb/fast
        - RIAK_LEVELDB_TIERED_PATH_SLOW=$- RIAK_DATA_DIR/leveldb/slow
        - RIAK_LEVELDB_DATA_ROOT=./
        - RIAK_SEARCH=off
        - RIAK_SEARCH_SOLR_START_TIMEOUT=30s
        - RIAK_SEARCH_SOLR_PORT=8093
        - RIAK_SEARCH_SOLR_JMX_PORT=8985
        - RIAK_SEARCH_SOLR_JVM_OPTIONS=-d64
    healthcheck:
        test: ["CMD-SHELL", "riak-admin status"]
        interval: 10s
        timeout: 5s
        retries: 10
```
### Additional default variables
`HOST`=`hostname -i` - the default ipv4 address riak will serve on.

`RIAK_HOST`=`$HOST` - hostname which will identify node hostname in Riak cluster.

`RIAK_SET_ULIMIT=262144` - a kind of workaround to set ulimit before riak starts (because `docker --ulimit nofile=90000:90000` don't works here).

`RIAK_CHECKCONFIG=True` - run riak chkconfig before start, may be set to `False` if needed.

`RIAK_AUTOSTART=True` - runs `riak start; riak wait-for-service riak_kv`, then post-start scripts from `/etc/riak/poststart.d` and then starts to read riak logs with `tail -n 1024 --retry -f /var/log/riak/console.log /var/log/riak/error.log`

### Riak advanced.config
Default advanced.config file. 
```
[
  {riak_core, [
    {vnode_parallel_start, $RIAK_RING_SIZE},
    {forced_ownership_handoff, $RIAK_RING_SIZE},
    {handoff_concurrency, $RIAK_RING_SIZE}
  ]},

 {riak_repl,
   [
    {data_root, "/var/lib/riak/riak_repl/"},
    {max_fssource_cluster, 5},
    {max_fssource_node, 1},
    {max_fssink_node, 1},
    {fullsync_on_connect, true},
    {fullsync_interval, 30},
    {rtq_max_bytes, 104857600},
    {proxy_get, disabled},
    {rt_heartbeat_interval, 15},
    {rt_heartbeat_timeout, 15},
    {fullsync_use_background_manager, true}
   ]},

  {lager,
   [
      {extra_sinks,
           [
            {object_lager_event,
             [{handlers,
               [{lager_file_backend,
                 [{file, "/var/log/riak/object.log"},
                  {level, info},
                  {formatter_config, [date, " ", time," [",severity,"] ",message, "\n"]}
                 ]
                }]
              },
              {async_threshold, 500},
              {async_threshold_window, 50}]
            }
            ]
      }
    ]
}].
```
Could be overridden by mounting file to a container, like:

`docker run -d -v /path/to/advanced.config:/etc/riak/advanced.config kefirgames/riak:2.2.3`
