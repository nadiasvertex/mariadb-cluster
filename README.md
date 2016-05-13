# mariadb-cluster
Provides a script and Vagrantfile to build a MariaDB cluster ready for geographical replication. Also installs
a proxy VM running HAProxy. A geo replication setup wouldn't use HAProxy this way, but a group of clusters would.
For example, there are 5 machines in Datacenter A, 5 in Datacenter B, and 5 in Datacenter C. Each group of 5 would
be behind an HAProxy instance in order to distribute load, but users in various regions would be sent to the nearest
proxy frontend.

To run, simply execute ./boot.sh

After the cluster is booted you can connect to any node. Nodes .21-.25 are data nodes. Node .26 is the HAProxy
instance, which is configured to balance to the least-connected machine.

To connect to the proxy:

```
mysql --user=root --host=192.168.77.26 --password=letmein
```

You should see: 

```
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 11
Server version: 10.1.14-MariaDB-1~trusty mariadb.org binary distribution

Copyright (c) 2000, 2016, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> 
```

You can check the state of the cluster with:

```
SHOW GLOBAL STATUS LIKE 'wsrep_%';
```

That will show a lot of data, but in particular the 'wsrep_cluster_size' variable should show 5.

```
MariaDB [(none)]> SHOW GLOBAL STATUS LIKE 'wsrep_%';
+------------------------------+------------------------------------------------------------------------------------------------+
| Variable_name                | Value                                                                                          |
+------------------------------+------------------------------------------------------------------------------------------------+
| wsrep_apply_oooe             | 0.000000                                                                                       |
| wsrep_apply_oool             | 0.000000                                                                                       |
| wsrep_apply_window           | 1.000000                                                                                       |
| wsrep_causal_reads           | 0                                                                                              |
| wsrep_cert_deps_distance     | 1.000000                                                                                       |
| wsrep_cert_index_size        | 1                                                                                              |
| wsrep_cert_interval          | 0.000000                                                                                       |
| wsrep_cluster_conf_id        | 2                                                                                              |
| wsrep_cluster_size           | 5                                                                                              |
| wsrep_cluster_state_uuid     | b1956346-1910-11e6-bbbd-868a30037da0                                                           |
| wsrep_cluster_status         | Primary                                                                                        |
| wsrep_commit_oooe            | 0.000000                                                                                       |
| wsrep_commit_oool            | 0.000000                                                                                       |
| wsrep_commit_window          | 1.000000                                                                                       |
| wsrep_connected              | ON                                                                                             |
| wsrep_evs_delayed            |                                                                                                |
| wsrep_evs_evict_list         |                                                                                                |
| wsrep_evs_repl_latency       | 0/0/0/0/0                                                                                      |
| wsrep_evs_state              | OPERATIONAL                                                                                    |
| wsrep_flow_control_paused    | 0.000000                                                                                       |
| wsrep_flow_control_paused_ns | 0                                                                                              |
| wsrep_flow_control_recv      | 0                                                                                              |
| wsrep_flow_control_sent      | 0                                                                                              |
| wsrep_gcomm_uuid             | b32d4bd9-1910-11e6-9048-86819b039850                                                           |
| wsrep_incoming_addresses     | 192.168.77.21:3306,192.168.77.25:3306,192.168.77.22:3306,192.168.77.24:3306,192.168.77.23:3306 |
| wsrep_last_committed         | 1                                                                                              |
| wsrep_local_bf_aborts        | 0                                                                                              |
| wsrep_local_cached_downto    | 1                                                                                              |
| wsrep_local_cert_failures    | 0                                                                                              |
| wsrep_local_commits          | 0                                                                                              |
| wsrep_local_index            | 4                                                                                              |
| wsrep_local_recv_queue       | 0                                                                                              |
| wsrep_local_recv_queue_avg   | 0.000000                                                                                       |
| wsrep_local_recv_queue_max   | 1                                                                                              |
| wsrep_local_recv_queue_min   | 0                                                                                              |
| wsrep_local_replays          | 0                                                                                              |
| wsrep_local_send_queue       | 0                                                                                              |
| wsrep_local_send_queue_avg   | 0.000000                                                                                       |
| wsrep_local_send_queue_max   | 1                                                                                              |
| wsrep_local_send_queue_min   | 0                                                                                              |
| wsrep_local_state            | 4                                                                                              |
| wsrep_local_state_comment    | Synced                                                                                         |
| wsrep_local_state_uuid       | b1956346-1910-11e6-bbbd-868a30037da0                                                           |
| wsrep_protocol_version       | 7                                                                                              |
| wsrep_provider_name          | Galera                                                                                         |
| wsrep_provider_vendor        | Codership Oy <info@codership.com>                                                              |
| wsrep_provider_version       | 25.3.15(r3578)                                                                                 |
| wsrep_ready                  | ON                                                                                             |
| wsrep_received               | 4                                                                                              |
| wsrep_received_bytes         | 924                                                                                            |
| wsrep_repl_data_bytes        | 0                                                                                              |
| wsrep_repl_keys              | 0                                                                                              |
| wsrep_repl_keys_bytes        | 0                                                                                              |
| wsrep_repl_other_bytes       | 0                                                                                              |
| wsrep_replicated             | 0                                                                                              |
| wsrep_replicated_bytes       | 0                                                                                              |
| wsrep_thread_count           | 2                                                                                              |
+------------------------------+------------------------------------------------------------------------------------------------+
57 rows in set (0.00 sec)

```

Any change you make on any node in the cluster should be instantly visible to other nodes. Note that this is not an MPP cluster, but it does geographical replication with synchronize-on-commit very well.
