#!/bin/bash

# Wrapper for StarCCM+ installer.

if [[ -f /tmp/STAR-CCM+11.02.010_01_linux-x86_64-r8.tar.gz ]]; then
  tempdir=$(mktemp -d -t customize-starccm-XXXXXX)

  yum install -y -q redhat-lsb.i686

  pushd "$tempdir"

  tar -xf /tmp/STAR-CCM+11.02.010_01_linux-x86_64-r8.tar.gz

  # -DINSTALLFLEX=false prevents installation of a local license server
  # -DADDSYSTEMPATH=false prevents root's bash profile being munged - it
  #    wouldn't affect cluster users' $PATHs anyway
  starccm+_11.02.010/STAR-CCM*.bin -i silent -DINSTALLFLEX=false -DADDSYSTEMPATH=false

  popd
  cp "`dirname "$0"`"/../resources/modulefile "$cw_ROOT/etc/modules/services/starccm+"
  cat <<EOF
******************************

Installation complete. A modulefile has been installed for using STAR-CCM+. To
enable it run:

  alces module enable services/starccm+

******************************
EOF

  rm -rf "$tempdir"
else
  cat <<EOF
******************************
  Please download the STAR-CCM+ installer file and copy it to

  /tmp/STAR-CCM+11.02.010_01_linux-x86_64-r8.tar.gz

  Then, restart the customization process by running

  alces customize trigger configure profile-starccm+

  Installation will then continue.

  A configured license server reachable from the cluster network will be
  required to run STAR-CCM+.

******************************
EOF
fi
