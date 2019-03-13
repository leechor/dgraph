#!/bin/bash
# Containers MUST be labeled with "cluster:test" to be restarted and stopped
# by these functions.

# May be called with an argument which is a docker compose file
# to use *instead of* the default docker-compose.yml.
function restartCluster {
  if [[ -z $1 ]]; then
    compose_file="docker-compose.yml"
  else
    compose_file="$(readlink -f $1)"
  fi

  basedir=$GOPATH/src/github.com/dgraph-io/dgraph
  pushd $basedir/dgraph >/dev/null
  echo "Rebuilding dgraph ..."
  make install
  docker-compose -p dgraph -f $compose_file up --remove-orphans --force-recreate --detach || exit 1
  popd >/dev/null

  $basedir/contrib/wait-for-it.sh -t 60 localhost:6080 || exit 1
  $basedir/contrib/wait-for-it.sh -t 60 localhost:9180 || exit 1
  sleep 10 || exit 1
}

function stopCluster {
  basedir=$GOPATH/src/github.com/dgraph-io/dgraph
  pushd $basedir/dgraph >/dev/null
#  docker ps --filter label="cluster=test" --format "{{.Names}}" \
#  | xargs -r docker stop | sed 's/^/Stopped /'
#  docker ps -a --filter label="cluster=test" --format "{{.Names}}" \
#  | xargs -r docker rm | sed 's/^/Removed /'
  docker-compose -p dgraph down --remove-orphans
  popd >/dev/null
}
