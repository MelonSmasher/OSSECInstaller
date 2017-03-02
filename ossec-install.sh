#! /bin/bash

# Versions
STABLE="2.9.0"
OLD_STABLE="2.8.3"
VERSION_TO_INSTALL=$STABLE
# Default Flag Values
INSTALL_OLD=false
# Prerequisites
YUM_PACKAGES='curl unzip';
APT_PACKAGES='build-essential curl unzip';
# Temp Dir
TEMP_DIR=/tmp/OSSECInstaller

# Function called when the script fails
function die {
	if [ $? -ne 0 ]; then { echo "$1" ; exit 1; } fi
}

function init_tmp {
	# Create Temp installer dir
	sudo mkdir -p $TEMP_DIR;
}

function cleanup_tmp {
	# Cleanup Temp installer dir
	sudo rm -rf $TEMP_DIR;
}

function download_build {
	cd $TEMP_DIR;
	# Get Source
	cd $TEMP_DIR; curl https://codeload.github.com/ossec/ossec-hids/tar.gz/v$VERSION_TO_INSTALL | tar xvz;
	# Move into src directory.
	cd $TEMP_DIR/ossec-hids-$VERSION_TO_INSTALL;
	# Run the ossec installer
	sudo bash install.sh
	# Stop OSSEC if it is installed from source.
	sudo service ossec-hids stop;
	# Start the service
	sudo service ossec-hids start;
}

# This function is for debian based systems
function debian_install {
	# Update apt cache
	sudo apt-get update;
	# Install build environment
	sudo apt-get install -y $APT_PACKAGES;
}

# This function is for Red Hat based systems
function rhel_install {
	# Install dev tools group
	sudo yum -y groupinstall 'Development Tools';
	# Install build environment
	sudo yum -y install $YUM_PACKAGES;
}

# This function fires the installation process
function begin_install {
	init_tmp;
	if [ -f /etc/redhat-release ]; then
		rhel_install;
	elif [ -f /etc/debian_version ]; then
		debian_install;
	else
		echo 'Supported Distros are RHEL/Centos and Debian/Ubuntu... sorry.';
		exit 3;
	fi
	# Get OSSEC and build it
	download_build;
	cleanup_tmp;
}

# Gather args from the command line
while getopts "o" flag; do
  case "${flag}" in
    o) INSTALL_OLD=true ;;
    *) echo "Unexpected option ${flag} ... ignoring" ;;
  esac
done

# If we're installing the old stable release then set it as the version to install
if $INSTALL_OLD; then VERSION_TO_INSTALL=$OLD_STABLE; fi;
# Begin the installation
begin_install;
