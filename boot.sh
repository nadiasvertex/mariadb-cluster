#!/bin/bash
nodes=("192.168.77.21" "192.168.77.22" "192.168.77.23" "192.168.77.24" "192.168.77.25")
connect_node=${nodes[$RANDOM % ${#nodes[@]} ]}

vagrant up
mysql --user=root --host=${connect_node} --password=letmein
