FROM ubuntu:20.04
# Defining default versions
ARG DEBIAN_FRONTEND=noninteractive
ARG TZ=Europe/Moscow
ENV TZ $TZ
ARG MIXQL_APP_VERSION
ENV MIXQL_APP_VERSION $MIXQL_APP_VERSION
ARG MIXQL_GIT_COMMIT
ENV MIXQL_GIT_COMMIT $MIXQL_GIT_COMMIT
ARG BIGTOP_GIT_COMMIT
ENV BIGTOP_GIT_COMMIT $BIGTOP_GIT_COMMIT
ARG JAVA_VERSION
ENV JAVA_VERSION $JAVA_VERSION
ARG SCALA_VERSION
ENV SCALA_VERSION $SCALA_VERSION
ARG SBT_VERSION
ENV SBT_VERSION $SBT_VERSION
ENV MIXQL_CLUSTER_BASE_PATH="/mixql/app/mixql-platform-demo-$MIXQL_APP_VERSION/bin"

RUN . /etc/os-release
RUN apt-get update -y && apt-get install -y \
    apt-transport-https \
    gnupg \
    locales\
    python3-pip \
    libkrb5-dev  \
    libsasl2-modules-gssapi-mit \
    libsasl2-dev \
    libkrb5-dev \
    krb5-config \
    krb5-user \
    libxml2-dev \
    libxslt-dev \
    libmysqlclient-dev \
    libldap2-dev \
    libsnappy-dev \
    rsync \
    curl \
    sudo \
    git \
    tree \
    wget \
    unzip \
    zip \
    iproute2 \
    iputils-ping \
    dnsutils \
    lsof  \
    net-tools\
    rng-tools \
    nmap \
    mc \
    lynx \
    puppet  \
    software-properties-common  \
    puppet-module-puppetlabs-apt  \
    puppet-module-puppetlabs-stdlib  \
    systemd-sysv &&\
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /mixql/app/ && \
    mkdir -p /mixql/src/ && \
    mkdir -p /mixql/samples/db && \
    mkdir -p /mixql/samples/scripts && \
    mkdir -p /mixql-host/app/ && \
    mkdir -p /mixql-host/src/ && \
    mkdir -p /mixql-host/samples


WORKDIR /tmp
RUN git clone https://github.com/apache/bigtop.git && cd bigtop && git checkout $BIGTOP_GIT_VERSION

# Config core-site.xml for Hue users
RUN sed -i '/spark => { groups =>/a\ \ \ \ hue => { groups => \"*\", hosts => \"*\" },' /tmp/bigtop/bigtop-deploy/puppet/modules/hadoop/manifests/init.pp

#COPY bigtop-deploy/puppet/hiera.yaml /etc/puppet/
RUN mkdir -p /etc/puppet/hieradata
COPY config/hiera.yaml /etc/puppet/
COPY config/hieradata /etc/puppet/hieradata

ENV PATH="/mixql/:$PATH"
WORKDIR /mixql
COPY config/entrypoint.sh /mixql
RUN chmod a+x /mixql/entrypoint.sh
ENTRYPOINT ["/mixql/entrypoint.sh"]
CMD ["puppet", "wait"]
