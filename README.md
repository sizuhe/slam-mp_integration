# Autonomous GPS-Denied Simulation Setup

This guide details the process for configuring Gazebo Harmonic, installing all necessary dependencies, setting up the custom PX4-Autopilot repository, and running the GPS denied simulation.

## 1. Installation of Dependencies

### Install Gazebo Hamonic for ROS2 Humble.
To install gz sim Harmonic with their dependencies to work with ROS2 Humble, run these commands:

``` bash
    # Add the Gazebo Harmonic repository
    sudo wget [https://packages.osrfoundation.org/gazebo.gpg](https://packages.osrfoundation.org/gazebo.gpg) -O /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] [http://packages.osrfoundation.org/gazebo/ubuntu-stable](http://packages.osrfoundation.org/gazebo/ubuntu-stable) $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null

    # Install Gazebo Harmonic and ROS 2 Humble bridge
    sudo apt-get update
    sudo apt-get install gz-harmonic
    sudo apt-get install ros-humble-ros-gzharmonic
```

### Install the Micro XRCE-DDS Agent
The Micro XRCE-DDS agent is required to enable communication between PX4 and ROS 2.
``` bash
    cd
    git clone [https://github.com/eProsima/Micro-XRCE-DDS-Agent.git](https://github.com/eProsima/Micro-XRCE-DDS-Agent.git)
    cd Micro-XRCE-DDS-Agent
    mkdir build
    cd build
    cmake ..
    make
    sudo make install
    cd
    sudo ldconfig /usr/local/lib/
```

### Install QGroundControl
Configure your system permissions, install the required dependencies (such as video streaming libraries), and download the QGroundControl AppImage.
``` bash
    # Remove ModemManager (prevents serial connection interference) and add user to dialout
    sudo usermod -a -G dialout $USER
    sudo apt-get remove modemmanager -y
    sudo apt-get update

    # Install QGroundControl dependencies
    sudo apt-get install -y gstreamer1.0-plugins-bad gstreamer1.0-libav gstreamer1.0-gl libqt5gui5 libfuse2

    # Download the QGroundControl AppImage and grant execution permissions
    wget [https://github.com/mavlink/qgroundcontrol/releases/download/v4.3.0/QGroundControl.AppImage](https://github.com/mavlink/qgroundcontrol/releases/download/v4.3.0/QGroundControl.AppImage)
    chmod +x ./QGroundControl.AppImage
```

### Install the custom PX4-Autopilot Repository
Clone the customized PX4 repository that contains the customized VTOL, worlds, plugins and install the standard Ubuntu toolchains.
``` bash
    git clone [https://github.com/Darkjrcy/PX4-Autopilot.git](https://github.com/Darkjrcy/PX4-Autopilot.git) --recursive -b scitech_erau-udea
    cd PX4-Autopilot
    bash ./Tools/setup/ubuntu.sh
```

## 2. Steps to Open the Simulation.
To run the full PX4 simlation of the custom standard_vtol with the camera and the 3D lidar follow the next steps:
1. In one terminal run the PX4 simulation:
``` bash
    cd PX4-Autopilot
    PX4_GZ_WORLD=erau_test make px4_sitl gz_standard_vtol_cam_lidar
```
2. In another terminal start the QGroundControl AppImage
``` bash
    ./QGroundControl.AppImage
```
3. In another terminal enable ROS 2 communication by running the agent on the default PX4 UDP port:
``` bash
    MicroXRCEAgent udp4 -p 8888
```