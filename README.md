# ERAU-UdeA Simulation Setup
This repository contains the ROS 2 package, Gazebo models, and scripts used to run the PX4 simulation. The project is organized around three areas:

- `codes/`: ROS 2 colcon workspace - **Develop** the package code inside `codes/src/ros2_erau-udea/`.
- `models/`: Custom Gazebo models.
- `libs/`: Installed dependencies.

> The `scripts/` directory contains the installation and configuration scripts.



## Requirements
ROS 2 is the only direct requirement, other dependencies are installed per the `install.sh` script.

The code uses `ROS_DISTRO=jazzy` by default. To use another ROS distribution, export it before running the scripts:
```bash
export ROS_DISTRO=<your-ros-distribution>
```

The PX4 setup script may install additional toolchains and system packages. The QGroundControl installation also adds the current user to the `dialout` group, so log out and back in after installation.



## Installation
Run the installer from the repository path:

```bash
chmod +x install.sh scripts/*.sh terminals.sh
./install.sh
```


### Installation process
The dependency menu can install each component independently:

1. Installs `gz-harmonic` and `ros-$ROS_DISTRO-ros-gz` based on the installed ROS 2 distribution.
2. Donwloads and installs `QGroundControl.AppImage` to the repository root and makes it executable.
3. Installs the Micro XRCE-DDS Agent version `v2.4.3`.
4. Clones the `scitech_erau-udea` branch of the custom PX4 fork into `libs/PX4-Autopilot`.
5. Clones the `release/1.16` branch into `libs/px4_msgs`.

Choose **Install everything automatically** to run all five installation steps. The PX4 setup script may require a reboot before PX4 is built for the first time.


### Configure simulation
After installing dependencies, choose **Configure simulation**. The configuration menu provides:

- **Copy custom models into PX4**: copies `models/.` to `libs/PX4-Autopilot/Tools/simulation/gz/models/`.
- **Build colcon workspace**: sources ROS 2 and `px4_msgs`, then runs `colcon build --symlink-install` from `codes/`.
- **Configure everything automatically**: performs both operations.



## Running the simulation
`terminals.sh` is intended to open multiple GNOME Terminal windows for the agent, PX4/Gazebo, ROS-Gazebo bridge, and ROS 2 work. Its optional argument is the number of additional development terminals:

```bash
./terminals.sh       # one additional terminal
./terminals.sh 3     # three additional terminals
```

The manual steps below are equivalent to the `terminals.sh` script, but they can be run in any terminal emulator:

1. Start the Micro XRCE-DDS Agent: `MicroXRCEAgent udp4 -p 8888`.
2. Start PX4 SITL and Gazebo: `cd PX4-Autopilot && PX4_GZ_WORLD=erau_test make px4_sitl gz_standard_vtol_cam_lidar`.
3. Start QGroundControl: `./QGroundControl.AppImage`.
4. Start ROS 2 tools or nodes (see below).
    In a new terminal, source the environments and then use the project commands, for example:
    
    ```bash
    source /opt/ros/${ROS_DISTRO:-jazzy}/setup.bash
    source libs/px4_msgs/install/local_setup.bash
    source codes/install/setup.bash
    ros2 topic list
    ```



## `Justfile` commands
Install `just` if it is not already available, then run commands from the repository root. The current recipes are:

| Command | Purpose |
| --- | --- |
| `just help` | List available recipes. |
| `just topics` | List ROS 2 topics with `ros2 topic list`. |
| `just topic_info <topic>` | Show information for a ROS 2 topic. |
| `just echo_topic <topic>` | Echo messages from a ROS 2 topic. |
| `just odom` | Echo `/odom` position data only. |
| `just gz_topics` | List Gazebo topics. |
| `just kill` | Stop matching ROS 2, Gazebo, PX4, and Micro XRCE-DDS processes. |



## Cleaning generated files
To rebuild the ROS 2 workspace from scratch, remove only its generated directories and rebuild:

```bash
rm -rf codes/build codes/install codes/log
source /opt/ros/${ROS_DISTRO:-jazzy}/setup.bash
source libs/px4_msgs/install/local_setup.bash
cd codes
colcon build --symlink-install
```

Do not remove `libs/` unless the external dependencies must be downloaded and built again.
