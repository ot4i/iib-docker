#!/bin/bash
# © Copyright IBM Corporation 2015.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html

 echo "net.ipv4.tcp_fin_timeout = 30" >> /etc/sysctl.conf
 echo "net.ipv4.tcp_keepalive_time = 300" >> /etc/sysctl.conf
 echo "net.ipv4.tcp_keepalive_intvl = 15" >> /etc/sysctl.conf
 echo "net.ipv4.tcp_keepalive_probes = 5" >> /etc/sysctl.conf
 echo "kernel.sem = 500 256000 250 1024" >> /etc/sysctl.conf
 echo "kernel.shmmni = 4096" >> /etc/sysctl.conf
 echo "kernel.shmall = 2097152" >> /etc/sysctl.conf
 echo "kernel.shmmax = 268435456" >> /etc/sysctl.conf
 echo "fs.file-max = 524288" >> /etc/sysctl.conf
 echo "kernel.shmall = 2097152" >> /etc/sysctl.conf
 echo "net.core.netdev_max_backlog = 3000" >> /etc/sysctl.conf
 echo "net.core.somaxconn = 3000" >> /etc/sysctl.conf

 echo "iibuser hard nofile 8192" >> /etc/security/limits.conf
 echo "iibuser soft nofile 8192" >> /etc/security/limits.conf
