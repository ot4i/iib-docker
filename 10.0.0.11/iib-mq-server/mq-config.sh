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

configure_os_user()
{
  # The group ID of the user to configure
  local -r GROUP_NAME=$1
  # Name of environment variable containing the user name
  local -r USER_VAR=$2
  # Name of environment variable containing the password
  local -r PASSWORD=$3
  # Home directory for the user
  local -r HOME=$4
  # Determine the login name of the user (assuming it exists already)

  # if user does not exist
  if ! id ${!USER_VAR} 2>1 > /dev/null; then
    # create
    useradd --gid ${GROUP_NAME} --home ${HOME} ${!USER_VAR}
  fi
  # Change the user's password (if set)
  if [ ! "${!PASSWORD}" == "" ]; then
    echo ${!USER_VAR}:${!PASSWORD} | chpasswd
  fi
}

# Set default unless it is set
MQ_APP_NAME="iibmquser"
MQ_APP_PASSWORD=${MQ_APP_PASSWORD:-""}

echo "Configuring mq app user (iibmquser)"
configure_os_user mqclient MQ_APP_NAME MQ_APP_PASSWORD /home/iibmquser

echo "Configuring default objects for queue manager: ${MQ_QMGR_NAME}"
set +e
runmqsc ${MQ_QMGR_NAME} < /etc/mqm/mq-config

# If client password set to "" allow users to connect to application channel without a userid
if [ "${MQ_APP_PASSWORD}" == "" ]; then
  echo "SET CHLAUTH('IIB.SVRCONN') TYPE(ADDRESSMAP) ADDRESS('*') USERSRC(CHANNEL) CHCKCLNT(ASQMGR) ACTION(REPLACE)" | runmqsc ${MQ_QMGR_NAME}
fi

set -e

