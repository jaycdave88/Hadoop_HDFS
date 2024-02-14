#!/bin/bash

# Start Hadoop NameNode and DataNode as daemons
$HADOOP_HOME/bin/hdfs --daemon start namenode
$HADOOP_HOME/bin/hdfs --daemon start datanode

# Start Telegraf in the background
telegraf --config /etc/telegraf/telegraf.conf &

# Optionally, you can also start other Hadoop-related services here, if needed

# Keep the container running by tailing a log file (for example)
# This assumes that Hadoop logs are being written to the standard log directory
tail -f $HADOOP_HOME/logs/*-namenode-*.log & tail -f $HADOOP_HOME/logs/*-datanode-*.log