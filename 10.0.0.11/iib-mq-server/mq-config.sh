#!/bin/bash
# -*- mode: sh -*-
# © Copyright IBM Corporation 2017
#
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

# Set needed variables to point to various MQ directories
DATA_PATH=`dspmqver -b -f 4096`
INSTALLATION=`dspmqver -b -f 512`


echo "Configuring default objects for queue manager: ${MQ_QMGR_NAME}"
set +e
runmqsc ${MQ_QMGR_NAME} < /home/iibuser/mq-config

# If client password set to "" allow users to connect to application channel without a userid
if [ "${MQ_APP_PASSWORD}" == "" ]; then
  echo "SET CHLAUTH('IIB.SVRCONN') TYPE(ADDRESSMAP) ADDRESS('*') USERSRC(CHANNEL) CHCKCLNT(ASQMGR) ACTION(REPLACE)" | runmqsc ${MQ_QMGR_NAME}
fi

set -e

