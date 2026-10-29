#!/usr/bin/env bash
set -euo pipefail





ROOT="$(cd "$(dirname "$0")" && pwd)"
LIB_DIR="$ROOT/libs"
ROS_DISTRO="${ROS_DISTRO:-jazzy}"

mkdir -p "$LIB_DIR"


# ROS setup files use unset variables, so they break under "set -u".
source_ros() {
  set +u
  source "/opt/ros/$ROS_DISTRO/setup.bash"
  set -u
}



# ==================================================



main_menu() {
  while true; do
    option=$(
    whiptail \
      --title         "PX4 simulation installation wizard" \
      --menu          "Choose a setup option" \
      --ok-button     "Select" \
      --cancel-button "Exit" \
      20 70 10 \
      install         "Install dependencies" \
      configure       "Configure simulation" \
      full            "Install and configure everything automatically" \
      3>&1 1>&2 2>&3
    ) || exit 0

    case "$option" in
      install)
        source "$ROOT/scripts/dependencies.sh"
        menu_install
        ;;
      configure)
        source "$ROOT/scripts/configure.sh"
        menu_configure
        ;;
      full)
        source "$ROOT/scripts/dependencies.sh"
        source "$ROOT/scripts/configure.sh"
        install_all
        configure_all
        ;;
    esac
  done
}

main_menu
