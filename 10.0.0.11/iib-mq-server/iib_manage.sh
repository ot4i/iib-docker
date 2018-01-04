#!/bin/bash
# © Copyright IBM Corporation 2015.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html

set -e

QMGR_NAME=${MQ_QMGR_NAME}
NODE_NAME=${NODENAME-IIBV10NODE}
SERVER_NAME=${SERVERNAME-default}
MQSI_MQTT_LOCAL_HOSTNAME=127.0.0.1

stop()
{
	echo "----------------------------------------"
	echo "Stopping node $NODE_NAME..."
	mqsistop $NODE_NAME
        echo "----------------------------------------"
        echo "Stopping node $NODE_NAME..."
        endmqm $QMGR_NAME
        exit
}

start_iib()
{
	echo "----------------------------------------"
        /opt/ibm/iib-10.0.0.10/iib version
	echo "----------------------------------------"

        NODE_EXISTS=`mqsilist | grep $NODE_NAME > /dev/null ; echo $?`


	if [ ${NODE_EXISTS} -ne 0 ]; then
          echo "----------------------------------------"
          echo "Node $NODE_NAME does not exist..."
          echo "Creating node $NODE_NAME"
          mqsicreatebroker -q $QMGR_NAME $NODE_NAME
          echo "----------------------------------------" 
          echo "----------------------------------------"
          echo "Starting syslog"
          sudo /usr/sbin/rsyslogd
          echo "Starting node $NODE_NAME"
          mqsistart $NODE_NAME
          echo "----------------------------------------" 
          echo "----------------------------------------"
          echo "Creating integration server $SERVER_NAME"
          mqsicreateexecutiongroup $NODE_NAME -e $SERVER_NAME -w 120
          echo "----------------------------------------"
          echo "----------------------------------------"
          shopt -s nullglob
          for f in /tmp/BARs/* ; do
            echo "Deploying $f ..."
            mqsideploy $NODE_NAME -e $SERVER_NAME -a $f -w 120
          done		  
          echo "----------------------------------------"
          echo "----------------------------------------"
	else
          echo "----------------------------------------"
          echo "Starting syslog"
          sudo /usr/sbin/rsyslogd
          echo "Starting node $NODE_NAME"
          mqsistart $NODE_NAME
          echo "----------------------------------------" 
          echo "----------------------------------------"
	fi
}

monitor()
{
	echo "----------------------------------------"
	echo "Running - stop container to exit"
	# Loop forever by default - container must be stopped manually.
	# Here is where you can add in conditions controlling when your container will exit - e.g. check for existence of specific processes stopping or errors being reported
	while true; do
		sleep 1
	done
}

/usr/local/bin/iib_env.sh
start_iib
trap stop SIGTERM SIGINT
monitor
