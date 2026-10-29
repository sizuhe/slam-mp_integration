#!/usr/bin/env bash
set -euo pipefail





install_gazebo() {
  echo "> Installing Gazebo Harmonic"

  sudo wget https://packages.osrfoundation.org/gazebo.gpg -O /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" \
    | sudo tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null
  sudo apt-get update
  sudo apt-get install -y gz-harmonic
  sudo apt-get install -y "ros-$ROS_DISTRO-ros-gz"

  echo ""
}



install_qgc() {
  echo "> Installing QGroundControl"

  sudo usermod -a -G dialout "$USER"
  sudo apt-get remove -y modemmanager
  sudo apt-get update
  sudo apt-get install -y gstreamer1.0-plugins-bad gstreamer1.0-libav gstreamer1.0-gl libqt5gui5 libfuse2

  wget https://github.com/mavlink/qgroundcontrol/releases/download/v4.3.0/QGroundControl.AppImage -O "$ROOT/QGroundControl.AppImage"
  chmod +x "$ROOT/QGroundControl.AppImage"

  echo "> Log out and back in so the dialout group is applied."
  sleep 2
  echo ""
}



install_xrce_agent() {
  echo "> Installing Micro XRCE-DDS Agent"

  cd "$LIB_DIR"
  [ -d Micro-XRCE-DDS-Agent ] \
    || git clone -b v2.4.3 https://github.com/eProsima/Micro-XRCE-DDS-Agent.git
  mkdir -p Micro-XRCE-DDS-Agent/build
  cd Micro-XRCE-DDS-Agent/build
  cmake ..
  make -j"$(nproc)"
  sudo make install
  sudo ldconfig /usr/local/lib/
  cd "$ROOT"

  echo ""
}



install_px4() {
  echo "> Installing PX4-Autopilot"

  cd "$LIB_DIR"
  [ -d PX4-Autopilot ] \
    || git clone https://github.com/Darkjrcy/PX4-Autopilot.git --recursive -b scitech_erau-udea
  cd PX4-Autopilot
  bash ./Tools/setup/ubuntu.sh
  cd "$ROOT"

  echo "> Reboot before building PX4 for the first time."
  sleep 2
  echo ""
}



install_px4_msgs() {
  echo "> Installing px4_msgs (PX4 ROS 2 bridge)"

  # Must match the PX4 version: the scitech_erau-udea fork is based on v1.16
  cd "$LIB_DIR"
  [ -d px4_msgs ] \
    || git clone -b release/1.16 https://github.com/PX4/px4_msgs.git
  cd px4_msgs
  source_ros
  colcon build
  cd "$ROOT"

  BASHRC_LINE="source $LIB_DIR/px4_msgs/install/local_setup.bash"
  grep -qxF "$BASHRC_LINE" ~/.bashrc || echo "$BASHRC_LINE" >> ~/.bashrc

  echo ""
}



install_all() {
  echo "> Installing all dependencies"

  install_gazebo
  install_qgc
  install_xrce_agent
  install_px4
  install_px4_msgs
}



# ==================================================



declare -A INSTALL_TASKS=(
  [gazebo]=install_gazebo
  [qgc]=install_qgc
  [xrce]=install_xrce_agent
  [px4]=install_px4
  [px4_msgs]=install_px4_msgs
  [full]=install_all
)


menu_install() {
  local choices

  if ! choices=$(
    whiptail \
      --title         "Install dependencies" \
      --menu          "Choose an option" \
      --ok-button     "Select" \
      --cancel-button "Back" \
      20 70 10 \
      gazebo          "Gazebo Harmonic + ROS 2 bridge" \
      qgc             "QGroundControl" \
      xrce            "Micro XRCE-DDS Agent" \
      px4             "PX4-Autopilot (erau-udea fork)" \
      px4_msgs        "px4_msgs (ROS 2 messages)" \
      full            "Install everything automatically" \
      3>&1 1>&2 2>&3
  ); then
    return
  fi

  for choice in $choices; do
    choice=${choice//\"/}
    "${INSTALL_TASKS[$choice]}"
  done
}
