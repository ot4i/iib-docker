#!/bin/bash
# © Copyright IBM Corporation 2015.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html

set -e

MQ_QMGR_NAME=${MQ_QMGR_NAME-QM1}
NODENAME=${NODENAME-IIBV10NODE}
SERVERNAME=${SERVERNAME-default}

stop()
{
	echo "----------------------------------------"
	echo "Stopping node $NODENAME..."
	mqsistop $NODENAME
        echo "----------------------------------------"
        echo "Stopping node $NODENAME..."
        endmqm $MQ_QMGR_NAME
        exit
}

start_iib()
{
	echo "----------------------------------------"
        /opt/ibm/iib-10.0.0.11/iib version
	echo "----------------------------------------"

        NODE_EXISTS=`mqsilist | grep $NODENAME > /dev/null ; echo $?`


	if [ ${NODE_EXISTS} -ne 0 ]; then
          echo "----------------------------------------"
          echo "Node $NODENAME does not exist..."
          echo "Creating node $NODENAME"
          mqsicreatebroker -q $MQ_QMGR_NAME $NODENAME
          echo "----------------------------------------" 
          echo "----------------------------------------"
          echo "Starting syslog"
          sudo /usr/sbin/rsyslogd
          echo "Starting node $NODENAME"
          mqsistart $NODENAME
          echo "----------------------------------------" 
          echo "----------------------------------------"
          echo "Creating integration server $SERVERNAME"
          mqsicreateexecutiongroup $NODENAME -e $SERVERNAME -w 120
          echo "----------------------------------------"
          echo "----------------------------------------"
          shopt -s nullglob
          for f in /tmp/BARs/* ; do
            echo "Deploying $f ..."
            mqsideploy $NODENAME -e $SERVERNAME -a $f -w 120
          done		  
          echo "----------------------------------------"
          echo "----------------------------------------"
	else
          echo "----------------------------------------"
          echo "Starting syslog"
          sudo /usr/sbin/rsyslogd
          echo "Starting node $NODENAME"
          mqsistart $NODENAME
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

license-check.sh
sudo -u root -E mq_start.sh
start_iib
trap stop SIGTERM SIGINT
monitor

