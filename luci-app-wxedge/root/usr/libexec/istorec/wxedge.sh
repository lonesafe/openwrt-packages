#!/bin/sh

ACTION=${1}
shift 1

get_image() {
  IMAGE_NAME="registry.hub.docker.com/onething1/wxedge"
}

do_install() {
  get_image
  echo "docker pull ${IMAGE_NAME}"
  docker pull ${IMAGE_NAME}
  docker rm -f wxedge

  do_install_detail
}

do_install_detail() {
  local path=`uci get wxedge.@wxedge[0].cache_path 2>/dev/null`

  if [ -z "$path" ]; then
      echo "path is empty!"
      exit 1
  fi

  local cmd="docker run --restart=unless-stopped -d \
    --privileged \
    --network=host \
    --dns=127.0.0.1 \
    --tmpfs /run \
    --tmpfs /tmp \
    -v \"$path:/storage\" \
    -v \"$path/containerd:/var/lib/containerd\" \
    -e PLACE=CTKS"

  local tz="`cat /tmp/TZ`"
  [ -z "$tz" ] || cmd="$cmd -e TZ=$tz"

  cmd="$cmd --name wxedge \"$IMAGE_NAME\""

  echo "$cmd"
  eval "$cmd"

}

usage() {
  echo "usage: $0 sub-command"
  echo "where sub-command is one of:"
  echo "      install                Install the wxedge"
  echo "      upgrade                Upgrade the wxedge"
  echo "      rm/start/stop/restart  Remove/Start/Stop/Restart the wxedge"
  echo "      status                 Onething Edge status"
  echo "      port                   Onething Edge port"
}

case ${ACTION} in
  "install")
    do_install
  ;;
  "upgrade")
    do_install
  ;;
  "rm")
    docker rm -f wxedge
  ;;
  "start" | "stop" | "restart")
    docker ${ACTION} wxedge
  ;;
  "status")
    docker ps --all -f 'name=wxedge' --format '{{.State}}'
  ;;
  "port")
    docker ps --all -f 'name=wxedge' --format '{{.Ports}}' | grep -om1 '0.0.0.0:[0-9]*' | sed 's/0.0.0.0://'
  ;;
  *)
    usage
    exit 1
  ;;
esac
