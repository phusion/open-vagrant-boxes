set -ex

cd /tmp

set +e
/etc/init.d/virtualbox-guest-utils stop
/etc/init.d/virtualbox-guest-x11 stop
rmmod vboxguest
set -e
apt-get -y purge virtualbox-guest-x11 virtualbox-guest-dkms virtualbox-guest-utils

export VMTOOLS_ARCHIVE=/home/vagrant/_latest_vmware_tools.tar.gz

set +x

###################

#!/bin/bash
# Automatic install and configure VMware Tools
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


echo -n "Patching vmware-tools: "
set +e
(
  set -e
  cd /tmp/vmware-tools-distrib
  # Enable automatic recompiling of vmware-tools kernel modules on kernel upgrades.
  patch -N -p0 >/dev/null 2>&1 <<"EOF"
--- bin/vmware-config-tools.pl.orig 2014-01-30 17:56:40.570846915 +0100
+++ bin/vmware-config-tools.pl  2014-01-30 17:56:51.980548609 +0100
@@ -10837,7 +10837,7 @@
 EOF

    $ans = get_persistent_answer($msg, 'AUTO_KMODS_ENABLED_ANSWER', 'yesno',
-                                'no');
+                                'yes');
    db_add_answer('AUTO_KMODS_ENABLED', $ans);
 }

EOF
)
status=$?
set -e
if [[ "$status" = 0 ]]; then
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

echo "Done"

###################

set -x

# Load the hgfs module immediately at boot. This makes 'vagrant up' faster at
# the at "Waiting for HGFS kernel module to load" stage.
echo vmhgfs >> /etc/modules
