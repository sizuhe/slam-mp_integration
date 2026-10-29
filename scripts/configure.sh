#!/usr/bin/env bash
set -euo pipefail





configure_models() {
  echo "> Copying custom models into PX4"

  cp -rf "$ROOT/models/." "$LIB_DIR/PX4-Autopilot/Tools/simulation/gz/models/"

  echo ""
}



configure_workspace() {
  echo "> Building colcon workspace"

  source_ros
  set +u
  source "$LIB_DIR/px4_msgs/install/local_setup.bash"
  set -u

  cd "$ROOT/codes"
  colcon build --symlink-install
  cd "$ROOT"

  echo "> Run 'source $ROOT/codes/install/setup.bash' in each new terminal."
  sleep 2
  echo ""
}



configure_all() {
  echo "> Configuring simulation"

  configure_models
  configure_workspace
}



# ==================================================



declare -A CONFIG_TASKS=(
  [models]=configure_models
  [workspace]=configure_workspace
  [full]=configure_all
)


menu_configure() {
  local choices

  if ! choices=$(
    whiptail \
      --title         "Configure simulation" \
      --menu          "Choose an option" \
      --ok-button     "Select" \
      --cancel-button "Back" \
      20 70 10 \
      models          "Copy custom models into PX4" \
      workspace       "Build colcon workspace (inside 'codes' folder)" \
      full            "Configure everything automatically" \
      3>&1 1>&2 2>&3
  ); then
    return
  fi

  for choice in $choices; do
    choice=${choice//\"/}
    "${CONFIG_TASKS[$choice]}"
  done
}
