#FROM debian:stretch-slim
FROM ubuntu:20.04 as builder
# Defining default versions
ARG DEBIAN_FRONTEND=noninteractive
ARG TZ=Europe/Moscow
ENV TZ $TZ
ARG MIXQL_APP_VERSION
ENV MIXQL_APP_VERSION $MIXQL_APP_VERSION
ARG MIXQL_GIT_COMMIT
ENV MIXQL_GIT_COMMIT $MIXQL_GIT_COMMIT
ARG JAVA_VERSION
ENV JAVA_VERSION $JAVA_VERSION
ARG SCALA_VERSION
ENV SCALA_VERSION $SCALA_VERSION
ARG SBT_VERSION
ENV SBT_VERSION $SBT_VERSION

# Downloading SDKMAN! Installing Java, Scala, sbt, removing some unnecessary SDKMAN files
RUN apt-get update && \
	apt-get install -y zip unzip curl git && \
    rm -rf /var/lib/apt/lists/* && \
	rm -rf /tmp/* && \
    curl -s "https://get.sdkman.io" | bash && \
    bash -c "source $HOME/.sdkman/bin/sdkman-init.sh && \
    yes | sdk install java $JAVA_VERSION && \
    yes | sdk install scala $SCALA_VERSION && \
    yes | sdk install sbt $SBT_VERSION" && \
    mkdir -m a=rwx -p /mixql/app
WORKDIR /mixql/src
RUN git clone --recurse-submodules -j8  https://github.com/mixql/mixql-platform.git && cd mixql-platform && git checkout $MIXQL_GIT_COMMIT && \
    bash -c "source $HOME/.sdkman/bin/sdkman-init.sh && \
    cd /mixql/src/mixql-platform/ && \
    sbt clean archiveMixQLPlatformDemo && \
    tar -xzf /mixql/src/mixql-platform/mixql-platform-demo/target/universal/mixql-platform-demo-$MIXQL_APP_VERSION.tgz -C /mixql/app && \
    sbt clean"

FROM ubuntu:20.04
# Defining default versions
ARG DEBIAN_FRONTEND=noninteractive
ARG TZ=Europe/Moscow
ENV TZ $TZ
ARG MIXQL_APP_VERSION
ENV MIXQL_APP_VERSION $MIXQL_APP_VERSION
ARG MIXQL_GIT_COMMIT
ENV MIXQL_GIT_COMMIT $MIXQL_GIT_COMMIT
ARG JAVA_VERSION
ENV JAVA_VERSION $JAVA_VERSION
ARG SCALA_VERSION
ENV SCALA_VERSION $SCALA_VERSION
ARG SBT_VERSION
ENV SBT_VERSION $SBT_VERSION
ENV MIXQL_CLUSTER_BASE_PATH="/mixql/app/mixql-platform-demo-$MIXQL_APP_VERSION/bin"

# Defining default non-root user UID, GID, and name
ARG USER_UID="1000"
ARG USER_GID="1000"
ARG USER_NAME="sbt"

# Installing basic packages
RUN apt-get update && \
	apt-get install -y sudo sqlite3 libsqlite3-dev zip unzip curl wget nano git mc tree && \
    rm -rf /var/lib/apt/lists/* && \
	rm -rf /tmp/* && \
    mkdir -m a=rwx  -p /mixql/app/ && \
    mkdir -m a=rwx  -p /mixql/src/ && \
    mkdir -m a=rwx  -p /mixql/samples/db && \
    mkdir -m a=rwx  -p /mixql/samples/scripts && \
    mkdir -m a=rwx  -p /mixql-host/app/ && \
    mkdir -m a=rwx  -p /mixql-host/src/ && \
    mkdir -m a=rwx  -p /mixql-host/samples

# Creating default non-user
RUN groupadd -g $USER_GID $USER_NAME && \
	useradd -m -g $USER_GID -G sudo -u $USER_UID -s /bin/bash  $USER_NAME && \
    adduser $USER_NAME sudo && \
    echo $USER_NAME:$USER_NAME | chpasswd

# Switching to non-root user to install SDKMAN!
USER $USER_UID:$USER_GID

# Downloading SDKMAN! Installing Java, Scala, sbt, removing some unnecessary SDKMAN files
RUN curl -s "https://get.sdkman.io" | bash && \
    bash -c "source $HOME/.sdkman/bin/sdkman-init.sh && \
    yes | sdk install java $JAVA_VERSION && \
    yes | sdk install scala $SCALA_VERSION && \
    yes | sdk install sbt $SBT_VERSION && \
    rm -rf $HOME/.sdkman/archives/* && \
    rm -rf $HOME/.sdkman/tmp/*"

ENV MAVEN_HOME="/home/sbt/.sdkman/candidates/maven/current"
ENV JAVA_HOME="/home/sbt/.sdkman/candidates/java/current"
ENV PATH="$MAVEN_HOME/bin:$JAVA_HOME/bin:$MIXQL_CLUSTER_BASE_PATH:$PATH"

WORKDIR /mixql/samples/db
RUN curl -sL https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/sakila-sample-database-ports/Sakila-sample-database-ports-v1.zip > /tmp/sakila.zip && \
    unzip /tmp/sakila.zip "Sakila/sqlite-sakila-db/*" -d /tmp && \
    mv /tmp/Sakila/sqlite-sakila-db/* /mixql/samples/db && \
    mv /mixql/samples/db/sqlite-sakila.sq /mixql/samples/db/sakila.db && \
    rm -rf /tmp/sakila.zip /tmp/Sakila

WORKDIR /mixql/app
COPY --from=builder /mixql/app/mixql-platform-demo-$MIXQL_APP_VERSION ./mixql-platform-demo-$MIXQL_APP_VERSION
COPY --from=builder /mixql/src/mixql-platform /mixql/src/mixql-platform

COPY entrypoint.sh /mixql
USER root
RUN chmod a+x /mixql/entrypoint.sh
USER $USER_UID:$USER_GID

WORKDIR /mixql
ENTRYPOINT ["/mixql/entrypoint.sh"]
CMD ["run"]

