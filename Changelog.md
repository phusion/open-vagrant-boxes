## 2014-05-11

 * The Ubuntu 12.04 boxes have been upgraded to kernel 3.13 (Trusty kernel). This is because even the updated VMWare Tools still occasionally caused kernel panics on kernel 3.8. In our tests, we've observed that VMWare Tools does not cause any kernel panics on kernel 3.13.
 * No changes in the Ubuntu 14.04 boxes.

## 2014-04-30

 * The Ubuntu 12.04 VirtualBox box in release 2014-02-22 was broken: the VirtualBox guest additions weren't correctly installed because the kernel was incorrectly installed. This has now been fixed.
 * The Ubuntu 12.04 VMWare Fusion box now loads the VMWare Tools kernel modules during startup, so that Vagrant doesn't have to wait so long at the "Waiting for HGFS kernel module" phase.

## 2014-04-22

 * There are now base boxes available based on Ubuntu 14.04. See the README for details.
 * Upgraded VMWare Tools to 9.6.2-1688356 (from VMWare Fusion 6.0.3). This is a major improvement over the VMWare Tools included in the last release (9.6.0-1294478, from VMWare Fusion 6.0.1):

    * Fixes the [file corruption bug](https://communities.vmware.com/thread/462303) in VMWare Tools 9.6.1-1378637 (from VMWare Fusion 6.0.2).
    * Fixes compatibility with kernel 3.13.
    * Fixes a number of bugs that could cause the kernel to crash.

   If you experienced any crashing/freezing problems with our VMWare Fusion boxes before, then this upgrade will probably help.

## 2014-02-01

 * Downgraded VMWare Tools to 9.6.0-1294478 because of [a file corruption bug in HGFS](https://communities.vmware.com/thread/462303).
 * The VMWare Fusion box now disables automatic updates of VMWare Tools, to prevent upgrading to the most recent version, which contains the HGFS file corruption bug.

## 2014-01-31

 * We now download and use a specific, recent version of VMWare Tools (9.6.1-1378637). This way the build will always succeed no matter which VMWare Fusion version the user is using. This version of VMWare Tools also happens to work with kernel 3.8 without needing patches.
 * Upgraded Veewee and reworked a lot stuff to make the build process more reliable.
 * The VirtualBox box is now compatible with VirtualBox <= 4.2.
 * Fixed some shared folder warnings when using the VirtualBox box. These warnings were caused by the fact that the box used to reference directories that only exist on the image building machine.
 * The kernel has been upgraded to 3.8.0-35.

## 2013-11-09

 * Fixed VMWare kernel modules in the VMWare Fusion image. The kernel modules were not being properly installed because of incompatibilities with kernel 3.8.

## 2013-11-08, update 2

 * Enabled the memory cgroup and swap accounting, required by some Docker features.

## 2013-11-08

 * Initial release
