set -ex

cd /tmp

apt-get -y purge virtualbox-ose-guest-x11 virtualbox-ose-guest-dkms virtualbox-ose-guest-utils
apt-get -y install dkms

export VMTOOLS_ARCHIVE=/home/vagrant/_latest_vmware_tools.tar.gz

set +x

###################

#!/bin/bash
# Automatic install and configure VMware Tools using DKMS 
# dkms.conf is an modified version of open-vm-tools' dkms.conf
#
# Idea for this script is from http://www.l4l.be/docs/virt/openvmtools_ubuntu810.php
#
# See also:
# http://runesk.blogspot.nl/2009/03/vmware-tools-and-dkms.html
# https://aur.archlinux.org/packages/vmware-modules-dkms/
#
# Copyright (c) 2009 Rune Nordbøe Skillingstad <rune.skillingstad@ntnu.no>
# Copyright (c) 2013 Hongli Lai <hongli@phusion.nl>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 dated June, 1991.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307,
# USA.

VMTOOLS_MOUNT_OPTIONS=${VMTOOLS_MOUNT_OPTIONS:-ro}

if [ "$USER" != "root" ]; then 
  echo "Can not run this as \"$USER\". Please sudo"
  exit 255
fi

if [ "$VMTOOLS_ARCHIVE" = "" ]; then
  if [ "$VMTOOLS_DEVICE" = "" -a "$VMTOOLS_MOUNT" = "" ]; then
    FSTAB=$(awk '/cdrom/{printf "%s %s\n", $1, $2}' /etc/fstab);

    if [ "$FSTAB" = "" ]; then
      echo "Can't find CD-ROM in /etc/fstab: please set \$VMTOOLS_DEVICE and \$VMTOOLS_MOUNT" >&2
      exit 1
    fi

    if [ $(echo $FSTAB | wc -l) -gt 1 ]; then
      echo "More than one CD-ROM device: please set \$VMTOOLS_DEVICE and \$VMTOOLS_MOUNT" >&2
      exit 1
    fi
    VMTOOLS_DEVICE=$(echo $FSTAB | cut -d\  -f1)
    VMTOOLS_MOUNT=$(echo $FSTAB | cut -d\  -f2)
  fi

  if [ ! -d $VMTOOLS_MOUNT ]; then
    echo "Mount point directory missing" >%2
    exit 2
  fi

  if mount | grep -q -F " on $VMTOOLS_MOUNT "; then
    echo "Already mounted... skipping mounting" >&2
  else
    echo -n "Mounting $VMTOOLS_DEVICE: "
    if mount -o $VMTOOLS_MOUNT_OPTIONS $VMTOOLS_DEVICE $VMTOOLS_MOUNT >/dev/null 2>&1; then 
      echo "Ok" 
    else 
      echo "Could not mount $VMTOOLS_DEVICE"
      exit 4
    fi
  fi

  VERSION=$(basename $(ls $VMTOOLS_MOUNT/VMwareTools-*.tar.gz | cut -d- -f2-) .tar.gz)

  if [ "$VERSION" = "" ]; then
    echo "Could not validate VMware Tools version" >&2
    exit 5
  else
    echo "Starting installation of VMware Tools version $VERSION"
  fi

  if [ -d /usr/src/vmware-tools-$VERSION ]; then
    echo -n "Removing old version of /usr/src/vmware-tools-${VERSION}: "
    rm -rf /usr/src/vmware-tools-$VERSION >/dev/null 2>&1 && echo "Ok" || echo "Error"
  fi
  if ! mkdir -p /usr/src/vmware-tools-$VERSION >/dev/null 2>&1; then 
    echo "Could not create /usr/src/vmware-tools-$VERSION"
    exit 6
  fi

  if [ -d /tmp/vmware-tools-distrib ]; then
    echo -n "Removing old version of /tmp/vmware-tools-distrib: "
    rm -rf /tmp/vmware-tools-distrib >/dev/null 2>&1 && echo "Ok" || echo "Error"
  fi

  echo -n "Extracting VMwareTools-${VERSION}: "
  if tar -C /tmp -zxf $VMTOOLS_MOUNT/VMwareTools-$VERSION.tar.gz >/dev/null 2>&1; then 
    echo "Ok"
  else 
    echo "Error"
    exit 7
  fi
  for TAR in /tmp/vmware-tools-distrib/lib/modules/source/*.tar; 
  do 
    echo -n "Extracting $TAR: "
    if tar -C /usr/src/vmware-tools-$VERSION -xf $TAR >/dev/null 2>&1; then
      echo "Ok"
    else
      echo "Error"
      exit 7
    fi
  done
else
  if [ -d /tmp/vmware-tools-distrib ]; then
    echo -n "Removing old version of /tmp/vmware-tools-distrib: "
    rm -rf /tmp/vmware-tools-distrib >/dev/null 2>&1 && echo "Ok" || echo "Error"
  fi

  echo -n "Extracting VMwareTools: "
  if tar -C /tmp -zxf $VMTOOLS_ARCHIVE >/dev/null 2>&1; then 
    echo "Ok"
  else 
    echo "Error"
    exit 7
  fi

  VERSION=$(cd /tmp/vmware-tools-distrib && grep -o -E "buildNr = '(.*)'" vmware-install.pl | sed -E "s/buildNr = '(.*)'/\1/; s/ build//")

  if [ "$VERSION" = "" ]; then
    echo "Could not validate VMware Tools version" >&2
    exit 5
  else
    echo "Starting installation of VMware Tools version $VERSION"
  fi

  if [ -d /usr/src/vmware-tools-$VERSION ]; then
    echo -n "Removing old version of /usr/src/vmware-tools-${VERSION}: "
    rm -rf /usr/src/vmware-tools-$VERSION >/dev/null 2>&1 && echo "Ok" || echo "Error"
  fi
  if ! mkdir -p /usr/src/vmware-tools-$VERSION >/dev/null 2>&1; then 
    echo "Could not create /usr/src/vmware-tools-$VERSION"
    exit 6
  fi

  for TAR in /tmp/vmware-tools-distrib/lib/modules/source/*.tar; 
  do 
    echo -n "Extracting $TAR: "
    if tar -C /usr/src/vmware-tools-$VERSION -xf $TAR >/dev/null 2>&1; then
      echo "Ok"
    else
      echo "Error"
      exit 7
    fi
  done
fi

echo -n "Generating /usr/src/vmware-tools-$VERSION/dkms.conf: "
cat > /usr/src/vmware-tools-$VERSION/dkms.conf <<EOF
PACKAGE_NAME=vmware-tools
PACKAGE_VERSION=$VERSION
MAKE_CMD_TMPL="make VM_UNAME=\$kernelver \
               MODULEBUILDDIR=\$dkms_tree/\$PACKAGE_NAME/\$PACKAGE_VERSION/build"

MAKE[0]="\$MAKE_CMD_TMPL -C vmblock-only VM_UNAME=\$kernelver &&   \\
         \$MAKE_CMD_TMPL -C vmci-only VM_UNAME=\$kernelver &&      \\
         \$MAKE_CMD_TMPL -C vmhgfs-only VM_UNAME=\$kernelver &&    \\
         \$MAKE_CMD_TMPL -C vmmemctl-only VM_UNAME=\$kernelver &&  \\
         \$MAKE_CMD_TMPL -C vmxnet-only VM_UNAME=\$kernelver &&    \\
         \$MAKE_CMD_TMPL -C vsock-only VM_UNAME=\$kernelver"
BUILT_MODULE_NAME[0]="vmblock"
BUILT_MODULE_NAME[1]="vmci"
BUILT_MODULE_NAME[2]="vmhgfs"
BUILT_MODULE_NAME[3]="vmmemctl"
BUILT_MODULE_NAME[4]="vmxnet"
BUILT_MODULE_NAME[5]="vsock"
BUILT_MODULE_LOCATION[0]="vmblock-only/"
BUILT_MODULE_LOCATION[1]="vmci-only/"
BUILT_MODULE_LOCATION[2]="vmhgfs-only/"
BUILT_MODULE_LOCATION[3]="vmmemctl-only/"
BUILT_MODULE_LOCATION[4]="vmxnet-only/"
BUILT_MODULE_LOCATION[5]="vsock-only/"
DEST_MODULE_LOCATION[0]="/kernel/fs/vmblock"
DEST_MODULE_LOCATION[1]="/kernel/drivers/misc"
DEST_MODULE_LOCATION[2]="/kernel/fs/vmhgfs"
DEST_MODULE_LOCATION[3]="/kernel/drivers/misc"
DEST_MODULE_LOCATION[4]="/kernel/drivers/net"
DEST_MODULE_LOCATION[5]="/kernel/drivers/misc"
AUTOINSTALL="YES"
EOF
echo "Ok"

if ! dpkg -L dkms >/dev/null 2>&1; then
  echo "Installing dkms: " 
  if apt-get -qq -y install dkms >/dev/null 2>&1; then
    echo "Ok"
  else
    echo "Error"
    exit 7
  fi
else 
  if dkms status | grep -q "^vmware-tools" ; then 
    echo -n "Removing old dkms definitions: "
    for VRSN in $(dkms status | awk '/^vmware-tools/{ver=$2; gsub(/[,:]/, "",ver); printf "%s\n", ver;}'); 
    do
      dkms remove -m vmware-tools -v $VRSN --all >/dev/null 2>&1 && echo -n "$VRSN "
      if [ -d /usr/src/vmware-tools-$VRSN -a "$VRSN" != "$VERSION" ]; then
        rm -rf /usr/src/vmware-tools-$VRSN >/dev/null 2>&1
      fi
    done
    echo
  fi
fi

DISTRIB=$(uname -r | cut -d- -f3)
if ! dpkg -L linux-headers-$DISTRIB >/dev/null 2>&1; then
  echo -n "Installing linux-headers-$DISTRIB: "
  if apt-get -qq -y install linux-headers-$DISTRIB >/dev/null 2>&1; then
    echo "Ok"
  else
    echo "Error"
    exit 7
  fi
fi

if ! dpkg -L linux-headers-$(uname -r) >/dev/null 2>&1; then
  echo -n "Installing linux-headers-$(uname -r): " 
  if apt-get -qq -y install linux-headers-$(uname -r) >/dev/null 2>&1; then
    echo "Ok"
  else
    echo "Error"
    exit 7
  fi
fi

if ! dpkg -L build-essential >/dev/null 2>&1; then 
  echo -n "Installing build-essential: "
  if apt-get -qq -y install build-essential >/dev/null 2>&1; then
    echo "Ok"
  else
    echo "Error"
    exit 7
  fi
fi

echo -n "Adding vmware-tools to dkms: "
if dkms add -m vmware-tools -v $VERSION >/dev/null 2>&1; then
  echo "Ok"
else
  echo "Error"
  exit 7
fi
echo -n "Building kernel modules for $(uname -r): "
if dkms build -m vmware-tools -v $VERSION -k $(uname -r) >/dev/null 2>&1; then
  echo "Ok"
else
  echo "Error"
  exit 7
fi
echo -n "Installing kernel modules for $(uname -r): "
if dkms install --force -m vmware-tools -v $VERSION -k $(uname -r) >/dev/null 2>&1; then
  echo "Ok"
else
  echo "Error"
  exit 7
fi

echo -n "Installing vmware-tools: "
if perl /tmp/vmware-tools-distrib/vmware-install.pl -d >/dev/null 2>&1; then
  echo "Ok"
else
  echo "Error"
  exit 7
fi

echo -n "Patching vmware-tools: "
(
  set +e
  cd /etc/vmware-tools
  # Allow vmware-tools to load kernel modules compiled by DKMS.
  patch -N -p0 >/dev/null 2>&1 <<"EOF"
--- services.sh.orig    2013-07-12 15:21:22.734631410 +0000
+++ services.sh 2013-07-12 15:31:04.786088356 +0000
@@ -866,7 +866,8 @@
    local module_path="`vmware_getModPath $1`"
    local module_name="`vmware_getModName $1`"
    /sbin/insmod -s -f "$module_path" >/dev/null 2>&1 || \
-       /sbin/insmod -s -f "$module_name" >/dev/null 2>&1 || exit 1
+       /sbin/insmod -s -f "$module_name" >/dev/null 2>&1 || \
+       /sbin/modprobe "$module_name" >/dev/null 2>&1 || exit 1
    return 0
 }

EOF
  sed -i 's/^answer VMHGFS_CONFED no$/answer VMHGFS_CONFED yes/' locations
)
if [[ "$?" = 0 ]]; then
  echo "Ok"
else
  echo "Error"
  exit 7
fi

echo "Done"

###################

set -x

# Now that VMWare Tools are installed, we can upgrade the kernel
apt-get -y dist-upgrade
apt-get -y install linux-generic-lts-raring linux-headers-generic-lts-raring
