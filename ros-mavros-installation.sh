#!/bin/bash

if [ -d "/var" ];
then
    echo "/var directory exist."
    if [ -d "/var/zenadrone" ];
    then
        echo "---------------------- 1: zenadrone directory exist ----------------------"
        if [ -d "/var/zenadrone/mavros" ];
        then
            echo "---------------------- 1: mavros directory exist ----------------------"
        else
            mkdir -p /var/zenadrone/mavros
            if [ $? -eq 0 ];
            then
                echo "---------------------- 2: Successfully created 'mavros' directory ----------------------"
            else
                echo "---------------------- 2: mkdir mavros encountered an error ----------------------"
                exit 1
            fi
        fi
    else
        mkdir /var/zenadrone
        if [ $? -eq 0 ];
        then
            echo "---------------------- 1-2: Successfully created 'zenadrone' directory ----------------------"
            if [ -d "/var/zenadrone/mavros" ];
            then
                echo "---------------------- 1-2: mavros directory exist ----------------------"
            else
                mkdir -p /var/zenadrone/mavros
                if [ $? -eq 0 ];
                then
                    echo "---------------------- 2-1: Successfully created 'mavros' directory ----------------------"
                else
                    echo "---------------------- 2-2: mkdir mavros encountered an error ----------------------"
                    exit 1
                fi
            fi
        else
            echo "---------------------- 2-3: mkdir zenadrone encountered an error ----------------------"
            exit 1
        fi
    fi
else
    echo "---------------------- 1: var directory not exist ----------------------"
fi

if command -v jq &>/dev/null; then
    echo "---------------------- 3: Found jq ----------------------"
else
    apt install jq -y
    if [ $? -eq 0 ]; then
        echo "---------------------- 3: Installed "jq" successfully ----------------------"
    else
        echo "---------------------- 3: encountered an error ----------------------"
        exit 1
    fi
fi

if command -v git &>/dev/null; then
    echo "---------------------- 4: Found git ----------------------"
else
    apt install git -y
    if [ $? -eq 0 ]; then
        echo "---------------------- 4: ran successfully ----------------------"
    else
        echo "---------------------- 4: encountered an error ----------------------"
        exit 1
    fi
fi

ZDIQRepoURL="https://github.com/MuhammadBilal1/ZDIQCommands.git"
ZDIQTargetPath="/var/zenadrone/ZDIQCommands"

git clone "$ZDIQRepoURL" "$ZDIQTargetPath"
if [ $? -eq 0 ]; then
    cd /var/zenadrone/ZDIQCommands
    git config --global --add safe.directory /var/zenadrone/ZDIQCommands
    echo "---------------------- 5: Repository Cloned successfully ----------------------"
else
    echo "---------------------- 5: encountered an error ----------------------"
    exit 1
fi

sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
if [ $? -eq 0 ]; then
    echo "---------------------- 6: ran successfully ----------------------"
else
    echo "---------------------- 6: encountered an error ----------------------"
fi

sudo apt install curl -y
if [ $? -eq 0 ]; then
    echo "---------------------- 7: found curl ----------------------"
else
    echo "---------------------- 7: encountered an error ----------------------"
fi

curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -
if [ $? -eq 0 ]; then
    echo "---------------------- 8: ran successfully ----------------------"
else
    echo "---------------------- 8: encountered an error ----------------------"
fi

sudo apt update
if [ $? -eq 0 ]; then
    echo "---------------------- 9: ran successfully ----------------------"
else
    echo "---------------------- 9: encountered an error ----------------------"
fi

sudo apt install ros-noetic-desktop-full -y
if [ $? -eq 0 ]; then
    echo "---------------------- 10: Successfully installed ros-noetic-desktop-full ----------------------"
else
    echo "---------------------- 10: encountered an error ----------------------"
fi

sudo apt install python3-rosdep -y
if [ $? -eq 0 ]; then
    echo "---------------------- 11: Successfully installed python3-rosdep ----------------------"
else
    echo "---------------------- 11: encountered an error ----------------------"
fi

sudo rosdep init
if [ $? -eq 0 ]; then
    echo "---------------------- 12: ran successfully ----------------------"
else
    echo "---------------------- 12: encountered an error ----------------------"
fi

rosdep update
if [ $? -eq 0 ]; then
    echo "---------------------- 13: Successfully ran rosdep update ----------------------"
else
    echo "---------------------- 13: encountered an error----------------------"
fi

sudo apt install ros-noetic-mavros ros-noetic-mavros-extras -y
if [ $? -eq 0 ]; then
    echo "---------------------- 14: Successfully installed ros-noetic-mavros ros-noetic-mavros-extras ----------------------"
else
    echo "---------------------- 14: encountered an error ----------------------"
fi

cd /var/zenadrone/ZDIQCommands
chmod +x ros-mavros-installation.sh
if [ $? -eq 0 ]; then
    echo "---------------------- 15: ran successfully ----------------------"
else
    echo "---------------------- 15: encountered an error ----------------------"
fi

sudo ./ros-mavros-installation.sh
if [ $? -eq 0 ]; then
    echo "---------------------- 16: ran successfully ----------------------"
else
    echo "---------------------- 16: encountered an error ----------------------"
fi

sudo mv /var/zenadrone/ZDIQCommands/geographiclib_datasets/* /usr/share/GeographicLib/
if [ $? -eq 0 ]; then
    echo "---------------------- 17: ran successfully ----------------------"
else
    echo "---------------------- 17: encountered an error ----------------------"
fi

source /opt/ros/noetic/setup.bash
if [ $? -eq 0 ]; then
    echo "---------------------- 18: ran successfully ----------------------"
else
    echo "---------------------- 18: encountered an error ----------------------"
fi

if command -v python3-pip &>/dev/null; then
    echo "---------------------- 19: Found python3-pip ----------------------"
else
    apt install python3-pip -y
    if [ $? -eq 0 ]; then
        echo "---------------------- 19-1: ran successfully ----------------------"
    else
        echo "---------------------- 19-1: encountered an error ----------------------"
    fi
fi

ServicesPath="/var/zenadrone/ZDIQCommands"
SystemPath="/etc/systemd/system"

sudo ln -s $ServicesPath/ros-mavros.service $SystemPath/ros-mavros.service
if [ $? -eq 0 ]; then
    echo "---------------------- 20: Successfully created symlink for ros-mavros.service ----------------------"
else
    echo "---------------------- 20: encountered an error ----------------------"
    exit 1
fi

sudo chmod u+x $SystemPath/ros-mavros.service
if [ $? -eq 0 ]; then
    echo "---------------------- 21: Successfully make services executables ----------------------"
else
    echo "---------------------- 21: encountered an error ----------------------"
fi

sudo systemctl daemon-reload
if [ $? -eq 0 ]; then
    echo "---------------------- 22: Successfully reloaded daemon ----------------------"
else
    echo "---------------------- 22: encountered an error ----------------------"
fi

sudo systemctl enable ros-mavros.service
if [ $? -eq 0 ]; then
    echo "---------------------- 23: Successfully enabled services to run on startup ----------------------"
else
    echo "---------------------- 23: encountered an error ----------------------"
fi

sudo systemctl start ros-mavros.service
if [ $? -eq 0 ]; then
    echo "---------------------- 24: Successfully started services ----------------------"
else
    echo "---------------------- 24: encountered an error ----------------------"
fi

sudo systemctl status ros-mavros.service
