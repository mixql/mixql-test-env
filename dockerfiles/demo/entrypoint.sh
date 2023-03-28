#!/usr/bin/env bash
set -e
echo "########################################################"
echo "** Entrypoint for mixql-platform-demo-$MIXQL_APP_VERSION"
source $HOME/.sdkman/bin/sdkman-init.sh

function checkfile() {
  if [ ! -f $1 ]; then
      echo "** Warning: file not found $1"
  fi
}

function checkdir() {
  if [ ! -d $1 ]; then
      echo "** Warning: folder not found $1"
  fi
}

function update() {
  echo "########################################################"
  echo "** Executing: setup SDKMAN versions"
  echo "Input parameters:"
  echo "JAVA_VERSION=$JAVA_VERSION"
  echo "SCALA_VERSION=$SCALA_VERSION"
  echo "SBT_VERSION=$SBT_VERSION"
  yes | sdk install java $JAVA_VERSION && \
  yes | sdk install scala $SCALA_VERSION && \
  yes | sdk install sbt $SBT_VERSION && \
  rm -rf $HOME/.sdkman/archives/* && \
  rm -rf $HOME/.sdkman/tmp/*
}

function run() {
  echo "########################################################"
  echo "** Executing: ./mixql-platform-demo"
  echo "** MIXQL_CLUSTER_BASE_PATH=$MIXQL_CLUSTER_BASE_PATH"
  echo "** DB=$DB"
  echo "** SCRIPT=$SCRIPT"
  cd $MIXQL_CLUSTER_BASE_PATH
  checkfile $MIXQL_CLUSTER_BASE_PATH/mixql-platform-demo
  if [ -n "$DB" ]; then
    checkfile $DB
    dbfile="-Dmixql.org.engine.sqlight.db.path=\"jdbc:sqlite:$DB\""
  fi
  if [ -n "$SCRIPT" ]; then
    checkfile $SCRIPT
    file="--sql-file $SCRIPT"
  fi
  echo "** Cmdline: $PWD/mixql-platform-demo $dbfile $file"
  echo
  ./mixql-platform-demo $dbfile $file
}

function compile() {
  host_src_path=/mixql-host/src/mixql-platform
  host_tgt_path=/mixql-host/app/
  echo "########################################################"
  echo "** Src dir: $host_src_path"
  echo "** Tgt dir: $host_tgt_path"
  echo "** Executing: sbt clean archiveMixQLPlatformDemo"
  checkdir $host_src_path
  checkdir $host_tgt_path
  cd $host_src_path
  sbt clean archiveMixQLPlatformDemo
  echo "** Executing: untar app to $host_tgt_path"
  checkdir $host_tgt_path/mixql-platform-demo-$MIXQL_APP_VERSION/
  rm -rf $host_tgt_path/mixql-platform-demo-$MIXQL_APP_VERSION/*
  tar -xzf $host_src_path/mixql-platform-demo/target/universal/mixql-platform-demo-$MIXQL_APP_VERSION.tgz -C $host_tgt_path
  tree $host_tgt_path -L 2
}

update
if [ "$1" = 'run' ]; then
  export MIXQL_CLUSTER_BASE_PATH=/mixql/app/mixql-platform-demo-$MIXQL_APP_VERSION/bin
  run
  if [ "$2" = 'bash' ]; then
    exec bash
  fi
elif [ "$1" = 'compile' ]; then
  export MIXQL_CLUSTER_BASE_PATH=/mixql-host/app/mixql-platform-demo-$MIXQL_APP_VERSION/bin
  compile
  if [ "$2" = 'bash' ]; then
    exec bash
  fi
elif [ "$1" = 'compile-run' ]; then
  export MIXQL_CLUSTER_BASE_PATH=/mixql-host/app/mixql-platform-demo-$MIXQL_APP_VERSION/bin
  compile
  run
  if [ "$2" = 'bash' ]; then
    exec bash
  fi
elif [ "$1" = 'run-host' ]; then
  export MIXQL_CLUSTER_BASE_PATH=/mixql-host/app/mixql-platform-demo-$MIXQL_APP_VERSION/bin
  run
  if [ "$2" = 'bash' ]; then
    exec bash
  fi
else
  echo "** Executing custom command: '$@'"
  exec "$@"
fi
exit 0


