#! /bin/bash

# Versions
STABLE="2.9.0"
STABLE_CHECKSUM="626d9b8d6dbddee8d99f4622d54a28849ef2014aa96e14c9d183a7a8dde1d9f2"
OLD_STABLE="2.8.3"
OLD_STABLE_CHECKSUM="917989e23330d18b0d900e8722392cdbe4f17364a547508742c0fd005a1df7dd"
VERSION_TO_INSTALL=$STABLE
CHECKSUM_TO_USE=$STABLE_CHECKSUM
# Default Flag Values
INSTALL_OLD=false
PRE_LOADED_VARS=''
# Prerequisites
YUM_PACKAGES='curl';
APT_PACKAGES='build-essential curl';
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

# Verifies that the tar is good
function verify_sum {
	echo "Verifying checksum...";
	checksum=$(sha256sum $TEMP_DIR/$VERSION_TO_INSTALL.tar.gz | cut -d" " -f1)
	if [ "$checksum" == "$CHECKSUM_TO_USE" ];
	then
		echo "Checksum verification passed!";
	else
		echo "Wrong checksum. Download again or check if file has been tampered with!";
		exit 4;
	fi
}

function download_build {
	cd $TEMP_DIR;
	# Get Source
	echo "Downloading OSSEC source ..."
	curl https://codeload.github.com/ossec/ossec-hids/tar.gz/v$VERSION_TO_INSTALL -s -o $VERSION_TO_INSTALL.tar.gz;
	echo "Download completed!"
	# Verify the check sum!
	verify_sum;
	# Die here if the checksum did not pass
	die "Wrong checksum. Download again or check if file has been tampered with!"
	# Untar the archive
	echo "Extracting $VERSION_TO_INSTALL.tar.gz ..."
	tar -xzf $TEMP_DIR/$VERSION_TO_INSTALL.tar.gz;
	echo "Extracting completed!"
	# Get the preloaded vars file
	if [ "$PRE_LOADED_VARS" != "" ];
	then
		echo "Downloading preloaded vars to etc ...";
		curl $PRE_LOADED_VARS -s -o $TEMP_DIR/ossec-hids-$VERSION_TO_INSTALL/etc/preloaded-vars.conf;
		die "Could not download the preloaded vars file from the url specified: $PRE_LOADED_VARS";
		echo "Download completed!";
	else
		echo "You must provide a url to your preloaded vars file using the '-p' option!";
		exit 5;
	fi
	# Move into src directory.
	cd $TEMP_DIR/ossec-hids-$VERSION_TO_INSTALL;
	# Stop OSSEC if it is installed from source.
	sudo service ossec-hids stop;
	# Run the ossec installer
	sudo bash install.sh
	# Start the service
	sudo service ossec-hids start;
}

# This function is for debian based systems
function debian_install {
	# Update apt cache
	echo "Updating apt cache ..."
	sudo apt-get -qq update;
	echo "Done!"
	# Install build environment
	echo "Installing prerequisites from apt ..."
	sudo apt-get install -qq -y $APT_PACKAGES;
	echo "Done!"
}

# This function is for Red Hat based systems
function rhel_install {
	# update yum cache
	echo "Updating yum cache ..."
	yum makecache -q
	echo "Done!"
	# Install dev tools group
	echo "Installing prerequisites from yum ..."
	sudo yum -y -q groupinstall 'Development Tools';
	# Install build environment
	sudo yum -y -q install $YUM_PACKAGES;
	echo "Done!"
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
OPTIND=1
# Gather args from the command line
while getopts ":o:p:" opt; do
  case "${opt}" in
    o) INSTALL_OLD=true ;;
    p) PRE_LOADED_VARS=$OPTARG ;;
    *) echo "Unexpected option ${opt} ... ignoring" ;;
  esac
done
shift $((OPTIND-1))
[ "$1" = "--" ] && shift

# If we're installing the old stable release then set it as the version to install
if $INSTALL_OLD; then VERSION_TO_INSTALL=$OLD_STABLE; fi;
if $INSTALL_OLD; then CHECKSUM_TO_USE=$OLD_STABLE_CHECKSUM; fi;
# Begin the installation
begin_install;
