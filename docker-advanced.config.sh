#!/usr/bin/env bash

# Defaul riak advanced config
if [[ ! -e $RIAK_ADVANCED_CONF ]]; then
cat <<END > $RIAK_ADVANCED_CONF
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

END
fi
