#!/usr/bin/env bash
set -euo pipefail





ROOT="$(cd "$(dirname "$0")" && pwd)"
ROS_DISTRO="${ROS_DISTRO:-jazzy}"
TERMINAL_NUMBER="${1:-1}"

# Sourced at the start of every ROS terminal
# ROS_ENV="source /opt/ros/$ROS_DISTRO/setup.bash
# source $ROOT/libs/px4_msgs/install/local_setup.bash
# [ -f $ROOT/codes/install/setup.bash ] && source $ROOT/codes/install/setup.bash"



# Opens a new terminal window that stays open after the command ends
open_terminal() {
  local title="$1"
  local cmd="$2"

  gnome-terminal --title="$title" -- bash -c "$cmd; exec bash"
}



# ==================================================



echo "> Starting Micro XRCE-DDS Agent"
open_terminal "XRCE Agent" \
  "MicroXRCEAgent udp4 -p 8888"
sleep 1


echo "> Starting PX4 SITL + Gazebo"
open_terminal "ERAU-UdeA PX4 SITL" \
  "cd $ROOT/libs/PX4-Autopilot && PX4_GZ_WORLD=erau_test make px4_sitl gz_standard_vtol_cam_lidar"
sleep 5


echo "> Starting ROS-Gazebo bridge"
open_terminal "ROS-Gazebo bridge" \
  "$ROS_ENV
  ros2 run ros_gz_bridge parameter_bridge /clock@rosgraph_msgs/msg/Clock[gz.msgs.Clock"
sleep 1


echo "> Opening ROS 2 terminal"
open_terminal "ROS 2" \
  "$ROS_ENV
  echo '> Waiting for PX4 topics...'
  sleep 5
  ros2 topic list | grep fmu"
sleep 1


for i in $(seq 1 $TERMINAL_NUMBER); do
    echo "> Opening misc terminal"
    open_terminal "Terminal" \
        cd $ROOT/codes/src/ros2_scitech-udea
done
