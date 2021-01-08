# nutyx-yao-helpers
Scripts to make easier the packager's life on NuTyX and Yaolinux

May needs improvments, but works fine for Yaolinux distro.

Chsource is for comparing source since Yao and Arch packages, put it in a "For" loop in collection directory to verify a whole collection

Compver is for updating version of various packages, put it in a "For" loop in collection directory to verify a whole collection

Searchdeps is for detecting Runtime dependencies in /srv/www directory. Prevents various shared libraries problems.

Create-pkg is to make a Pkgfile template in the correct directories in git/$VERSION/. This package have to be adapted to nutyx, due to recents collections changes.

Make-iso-nutyx.in is an automated Iso generator, special made for NuTyX.

Configvm and startvm are two script that help people to start a Qemu VM in Cli, not specific to a distro. Need to be adapted due to ovmf package and various place that some specific files are positionned.
