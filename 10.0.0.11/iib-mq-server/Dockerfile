FROM ubuntu:16.04

LABEL maintainer "Dan Robinson <dan.robinson@uk.ibm.com>"

LABEL "ProductID"="447aefb5fd1342d5b893f3934dfded73" \
      "ProductName"="IBM Integration Bus" \
      "ProductVersion"="10.0.0.11"

# The URL to download the MQ installer from in tar.gz format
ARG MQ_URL=https://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/messaging/mqadv/mqadv_dev904_ubuntu_x86-64.tar.gz

# The MQ packages to install
ARG MQ_PACKAGES="ibmmq-server ibmmq-java ibmmq-jre ibmmq-gskit ibmmq-msg-.* ibmmq-client ibmmq-sdk ibmmq-samples ibmmq-ft*"

# Install additional packages required by MQ and IIB, this install process and the runtime scripts
RUN export DEBIAN_FRONTEND=noninteractive \
  && apt-get update -y \
  && apt-get install -y --no-install-recommends \
    bash \
    bc \
    ca-certificates \
    coreutils \
    curl \
    debianutils \
    file \
    findutils \
    gawk \
    grep \
    libc-bin \
    lsb-release \
    mount \
    passwd \
    procps \
    rsyslog \
    sed \
    sudo \
    tar \
    util-linux \
  # Download and extract the MQ installation files
  && export DIR_EXTRACT=/tmp/mq \
  && mkdir -p ${DIR_EXTRACT} \ 
  && cd ${DIR_EXTRACT} \
  && curl -LO $MQ_URL \
  && tar -zxvf ./*.tar.gz \
  # Recommended: Create the mqm user ID with a fixed UID and group, so that the file permissions work between different images
  && groupadd --system --gid 999 mqm \
  && useradd --system --uid 999 --gid mqm mqm \
  && usermod -G mqm root \
  # Find directory containing .deb files
  && export DIR_DEB=$(find ${DIR_EXTRACT} -name "*.deb" -printf "%h\n" | sort -u | head -1) \
  # Find location of mqlicense.sh
  && export MQLICENSE=$(find ${DIR_EXTRACT} -name "mqlicense.sh") \
  # Accept the MQ license
  && ${MQLICENSE} -text_only -accept \
  && echo "deb [trusted=yes] file:${DIR_DEB} ./" > /etc/apt/sources.list.d/IBM_MQ.list \
  # Install MQ using the DEB packages
  && apt-get update \
  && apt-get install -y $MQ_PACKAGES \
  # Remove tar.gz files unpacked by RPM postinst scripts
  && find /opt/mqm -name '*.tar.gz' -delete \
  # Recommended: Set the default MQ installation (makes the MQ commands available on the PATH)
  && /opt/mqm/bin/setmqinst -p /opt/mqm -i \
  # Clean up all the downloaded files
  && rm -f /etc/apt/sources.list.d/IBM_MQ.list \
  && rm -rf ${DIR_EXTRACT} \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /var/mqm \
  # Optional: Set these values for the Bluemix Vulnerability Report
  && sed -i 's/PASS_MAX_DAYS\t99999/PASS_MAX_DAYS\t90/' /etc/login.defs \
  && sed -i 's/PASS_MIN_DAYS\t0/PASS_MIN_DAYS\t1/' /etc/login.defs \
  && sed -i 's/password\t\[success=1 default=ignore\]\tpam_unix\.so obscure sha512/password\t[success=1 default=ignore]\tpam_unix.so obscure sha512 minlen=8/' /etc/pam.d/common-password

ARG IIB_URL=http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/integration/10.0.0.11-IIB-LINUX64-DEVELOPER.tar.gz

# Install IIB V10 Developer edition
RUN mkdir /opt/ibm && \
    curl $IIB_URL \ 
    | tar zx --exclude iib-10.0.0.11/tools --directory /opt/ibm && \
    /opt/ibm/iib-10.0.0.11/iib make registry global accept license silently

# Configure system
RUN echo "IIB_10:" > /etc/debian_chroot  && \
    touch /var/log/syslog && \
    chown syslog:adm /var/log/syslog

# Create user to run as
RUN groupadd -f mqbrkrs && \
    groupadd -f mqclient && \
    useradd --create-home --home-dir /home/iibuser -G mqbrkrs,sudo,mqm,mqclient iibuser && \
    sed -e 's/^%sudo	.*/%sudo	ALL=NOPASSWD:ALL/g' -i /etc/sudoers

# Copy in script files
COPY *.sh /usr/local/bin/
COPY mq-config /etc/mqm/mq-config
RUN chmod 755 /usr/local/bin/*.sh \
  && chmod 755 /etc/mqm/mq-config

# Set BASH_ENV to source mqsiprofile when using docker exec bash -c
ENV BASH_ENV=/usr/local/bin/iib_env.sh MQSI_MQTT_LOCAL_HOSTNAME=127.0.0.1 MQSI_DONT_RUN_LISTENER=true LANG=en_US.UTF-8

# Expose default admin port and http ports
EXPOSE 4414 7800 1414

USER iibuser

# Set entrypoint to run management script
ENTRYPOINT ["iib_manage.sh"]
