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

start_mq()
{
        echo "----------------------------------------"
        echo "Setting up /var/mqm"
        setup-var-mqm.sh
        echo "----------------------------------------"
        echo "Source the mq environment"
        mq-pre-create-setup.sh

        QMGR_EXISTS=`dspmq | grep ${QMGR_NAME} > /dev/null ; echo $?`

        if [ ${QMGR_EXISTS} -ne 0 ]; then
          echo "----------------------------------------"
          echo "Queue manager $QMGR_NAME does not exist..."
          echo "Creating queue manager $QMGR_NAME"
          crtmqm -q -p 1414 ${QMGR_NAME}
          echo "----------------------------------------"
          echo "Starting queue manager $QMGR_NAME"
          strmqm ${QMGR_NAME}
          echo "----------------------------------------"
          echo "Configuring queue manager $QMGR_NAME"
          source mq-config.sh
          echo "----------------------------------------"
          source mq-configure-qmgr.sh
        else
          echo "----------------------------------------"
          echo "Starting queue manager $QMGR_NAME"
          strmqm ${QMGR_NAME}
          echo "----------------------------------------"
        fi
}

license-check.sh
start_mq
su -m iibuser -c "iib_manage.sh"
