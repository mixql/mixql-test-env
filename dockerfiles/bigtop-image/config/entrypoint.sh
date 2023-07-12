#!/usr/bin/env bash
set -e
echo "########################################################"
echo "** Entrypoint for Bigtop container"
echo "** $0 $@ ($#)"
#source $HOME/.sdkman/bin/sdkman-init.sh

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

function oozie-start () {
  # Bug Oozie must read ssl-client.xml
  chmod o+r /etc/hadoop/conf/ssl-client.xml
  wget http://archive.cloudera.com/gplextras/misc/ext-2.2.zip -O /lib/oozie/libext/ext-2.2.zip
  chown -R oozie:oozie /lib/oozie/libext/ext-2.2.zip
  /lib/oozie/bin/oozie-setup.sh
  /lib/oozie/bin/oozie-setup.sh sharelib create -fs hdfs://main.mixql.loc:8020 -locallib /lib/oozie/oozie-sharelib.tar.gz
  sudo -u hdfs hdfs dfs -rm -R /user/oozie/share/lib
  l=$(hadoop fs -ls /user/root/share/lib | grep -oE '/lib_[0-9]{14}' | sed 's/\/lib_/lib_/')
  sudo -u hdfs hdfs dfs -mv /user/root/share/lib/$l /user/oozie/share/lib
  service oozie start
}

function puppetize() {
  puppet apply --verbose \
   --hiera_config=/etc/puppet/hiera.yaml \
   --modulepath=/tmp/bigtop/bigtop-deploy/puppet/modules:/etc/puppet/modules:/usr/share/puppet/modules:/etc/puppetlabs/code/modules:/etc/puppet/code/modules \
   /tmp/bigtop/bigtop-deploy/puppet/manifests
   echo "######   Puppet has started services.  ###### "
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
  cd MIXQL_PLATFORM_DEMO_HOME_PATH/bin
  checkfile MIXQL_PLATFORM_DEMO_HOME_PATH/bin/mixql-platform-demo
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

usage() {
    echo "usage: entrypoint.sh args"
    echo "       puppet                                   - Execute puppet apply"
    echo "       update                                   - Set new versions via sdk"
    echo "       run                                      - Execute precompiled mixql"
    echo "       run-host                                 - Execute compiled mixql"
    echo "       bash                                     - Stay in bash"
    echo "       wait                                     - Infinit loop"
    echo "       -h, --help"
}

while [ $# -gt 0 ]; do
    case "$1" in
    puppet)
        time puppetize
        time oozie-start || oozie_start_error=1
        if [ -n "$oozie_start_error" ]; then
          echo "** oozie_start_error = $oozie_start_error"
        fi
        shift;;
    run)
        export MIXQL_PLATFORM_DEMO_HOME_PATH=/mixql/app/mixql-platform-demo-$MIXQL_APP_VERSION/bin
        run
        shift;;
    run-host)
        export MIXQL_PLATFORM_DEMO_HOME_PATH=/mixql-host/app/mixql-platform-demo-$MIXQL_APP_VERSION/bin
        run
        shift;;
    -h|--help)
        usage
        shift;;
    bash)
        exec bash
        shift;;
    wait)
        echo "###### Use Ctrl-P Ctrl-Q to detach the container without stopping it ######"
        trap : TERM INT; sleep infinity & wait
        shift;;
    *)
        echo "** Unknown command: '$@'"
        usage
        echo "** Executing custom command: '$@'"
        exec "$@"
    esac
done