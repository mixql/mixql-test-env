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
  echo "** MIXQL_PLATFORM_DEMO_HOME_PATH=$MIXQL_PLATFORM_DEMO_HOME_PATH"
  echo "** DB=$DB"
  echo "** SCRIPT=$SCRIPT"
  cd $MIXQL_PLATFORM_DEMO_HOME_PATH/bin
  checkfile $MIXQL_PLATFORM_DEMO_HOME_PATH/bin/mixql-platform-demo
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
  if [ "$1" = 'demo' ]; then
    cmd="archiveMixQLPlatformDemo"
  elif [ "$1" = 'oozie' ]; then
    cmd="archiveMixQLPlatformOozie"
  else
    echo "** Unknown custom command: '$1'"
  fi
  host_src_path=/mixql-host/src/mixql-platform
  host_tgt_path=/mixql-host/app/
  echo "########################################################"
  echo "** Src dir: $host_src_path"
  echo "** Tgt dir: $host_tgt_path"
  echo "** Executing: sbt clean $cmd"
  checkdir $host_src_path
  checkdir $host_tgt_path
  cd $host_src_path
  sbt clean $cmd
  echo "** Executing: untar app to $host_tgt_path"
  checkdir $host_tgt_path/mixql-platform-demo-$MIXQL_APP_VERSION/
  rm -rf $host_tgt_path/mixql-platform-demo-$MIXQL_APP_VERSION/*
  tar -xzf $host_src_path/mixql-platform-demo/target/universal/mixql-platform-$1-$MIXQL_APP_VERSION.tgz -C $host_tgt_path
  tree $host_tgt_path -L 2
}

update
if [ "$1" = 'run' ]; then
  export MIXQL_PLATFORM_DEMO_HOME_PATH=/mixql/app/mixql-platform-demo-$MIXQL_APP_VERSION/
  run
  if [ "$2" = 'bash' ]; then
    exec bash
  fi
elif [ "$1" = 'compile-demo' ]; then
  export MIXQL_PLATFORM_DEMO_HOME_PATH=/mixql-host/app/mixql-platform-demo-$MIXQL_APP_VERSION/
  compile demo
  if [ "$2" = 'bash' ]; then
    exec bash
  fi
elif [ "$1" = 'compile-oozie' ]; then
  export MIXQL_PLATFORM_DEMO_HOME_PATH=/mixql-host/app/mixql-platform-demo-$MIXQL_APP_VERSION/
  compile oozie
  if [ "$2" = 'bash' ]; then
    exec bash
  fi
elif [ "$1" = 'compile-run' ]; then
  export MIXQL_PLATFORM_DEMO_HOME_PATH=/mixql-host/app/mixql-platform-demo-$MIXQL_APP_VERSION/
  compile
  run
  if [ "$2" = 'bash' ]; then
    exec bash
  fi
elif [ "$1" = 'run-host' ]; then
  export MIXQL_PLATFORM_DEMO_HOME_PATH=/mixql-host/app/mixql-platform-demo-$MIXQL_APP_VERSION/
  run
  if [ "$2" = 'bash' ]; then
    exec bash
  fi
else
  echo "** Executing custom command: '$@'"
  exec "$@"
fi
exit 0


