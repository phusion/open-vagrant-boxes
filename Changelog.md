## 2014-01-30

 * We now download and use a specific, recent version of VMWare Tools (9.6.1-1378637). This way the build will always succeed no matter which VMWare Fusion version the user is using. This version of VMWare Tools also happens to work with kernel 3.8 without needing patches.
 * Upgraded Veewee and reworked a lot stuff to make the build process more reliable.

## 2013-11-09

 * Fixed VMWare kernel modules in the VMWare Fusion image. The kernel modules were not being properly installed because of incompatibilities with kernel 3.8.

## 2013-11-08, update 2

 * Enabled the memory cgroup and swap accounting, required by some Docker features.

## 2013-11-08

 * Initial release