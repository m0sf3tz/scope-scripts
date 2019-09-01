#!/bin/bash

function print_space() {
    for i in {1..3}
    do 
       echo ""
    done
}

print_space

echo "**********************************************************"
echo "*        SETTING UP SMART-SCOPE YOCTO BUILD SYSTEM        "
echo "**********************************************************"
echo "								"

if [ -d poky ]; then
	echo "this folder already contains a /poky folder, this script should only be ran once... bailing!"
	exit
fi
	
print_space

echo "This script will load the smart-scope yocto build system in the current directory.. "

while true; do
    read -p "Do you wish to install this program in ${PWD} ? - please answer yes or no:  " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
cat
#we need this later for setting up the layers
ROOT=$PWD
	
git clone git://git.yoctoproject.org/poky

cd poky 

git clone git://git.yoctoproject.org/meta-raspberrypi
git clone https://github.com/m0sf3tz/meta-kernel.git

#must source the first time we run the enviorment to pull in the layers.conf
source oe-init-build-env

cd ${ROOT}/poky/build/conf


#the next few files will open ..poky/build/conf/local.conf and ..poky/build/conf/bblayers.conf and edit them to
#include ... (note that full link is required, hence why we stored the ROOT directoy earlier...
# A) meta-kernel (contains kernel changes)
# B) meta-rassbery (contains rasberry-pi layer)

sed -i "/BBLAYERS / a\  $ROOT\/poky\/meta-kernel \\\\" bblayers.conf 
sed -i "/BBLAYERS / a\  $ROOT\/poky\/meta-raspberrypi \\\\" bblayers.conf 

# C) update the machine type to raspberrypi
sed -i "/MACHINE ??= \"qemux86-64\"/c  #MACHINE ??= \"qemux86-64\"" local.conf
sed -i "/#MACHINE ??= \"qemux86-64\"/a  MACHINE ??= \"raspberrypi3\"" local.conf

#setup build/conf/local.conf to include kernel modules
echo "# Add kernel modules (all the camera stuff is currently modules"
echo "CORE_IMAGE_EXTRA_INSTALL += \" kernel-modules\"" >> local.conf

