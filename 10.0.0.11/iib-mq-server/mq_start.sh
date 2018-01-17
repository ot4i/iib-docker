#!/bin/bash
# © Copyright IBM Corporation 2015.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html

set -e

MQ_QMGR_NAME=${MQ_QMGR_NAME-QM1}

start_mq()
{
        echo "----------------------------------------"
        echo "Setting up /var/mqm"
        setup-var-mqm.sh
        echo "----------------------------------------"
        echo "Source the mq environment"
        mq-pre-create-setup.sh

        QMGR_EXISTS=`dspmq | grep ${MQ_QMGR_NAME} > /dev/null ; echo $?`

        if [ ${QMGR_EXISTS} -ne 0 ]; then
          echo "----------------------------------------"
          echo "Queue manager $MQ_QMGR_NAME does not exist..."
          echo "Creating queue manager $MQ_QMGR_NAME"
          crtmqm -q -p 1414 ${MQ_QMGR_NAME}
          echo "----------------------------------------"
          echo "Starting queue manager $MQ_QMGR_NAME"
          strmqm ${MQ_QMGR_NAME}
          echo "----------------------------------------"
          echo "Creating iib queues"
          /opt/ibm/iib-10.0.0.11/server/sample/wmq/iib_createqueues.sh $MQ_QMGR_NAME mqbrkrs
          echo "----------------------------------------"
          echo "Configuring queue manager $MQ_QMGR_NAME"
          source mq-config.sh
          echo "----------------------------------------"
          source mq-configure-qmgr.sh
        else
          echo "----------------------------------------"
          echo "Starting queue manager $MQ_QMGR_NAME"
          strmqm ${MQ_QMGR_NAME}
          echo "----------------------------------------"
        fi
}

start_mq
