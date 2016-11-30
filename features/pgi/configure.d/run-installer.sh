#!/bin/bash

# Wrapper for PGI Community Edition installer.

if [[ -f /tmp/pgilinux-2016-1610-x86_64.tar.gz ]]; then
  tempdir=$(mktemp -d -t customize-pgi-XXXXXX)

  yum install -q -y gcc-c++

  pushd "$tempdir"

  tar -xf /tmp/pgilinux-2016-1610-x86_64.tar.gz

  export PGI_SILENT=true
  export PGI_ACCEPT_EULA=accept
  export PGI_INSTALL_DIR=/opt/pgi
  export PGI_INSTALL_TYPE=single  # 'network' an option - for investigation

  ./install

  popd

  rm -rf "$tempdir"

  mkdir -p "$cw_ROOT"/etc/modules/compilers/
  cp /opt/pgi/modulefiles/pgi/16.10 "$cw_ROOT"/etc/modules/compilers/pgi
  cat <<EOF
******************************

Installation complete. A modulefile has been installed for using PGI. To enable
it run:

  alces module enable compilers/pgi

You can now delete the installer file by running

  rm /tmp/pgilinux-2016-1610-x86_64.tar.gz

******************************
EOF
else
  cat <<EOF
******************************
  Please download the PGI Community Edition installer file from the following
  URL:

  http://www.pgroup.com/products/community.htm

  Then, please copy the file to

  /tmp/pgilinux-2016-1610-x86_64.tar.gz

  and restart the customization process by running

  alces customize trigger configure profile-pgi

  Installation will then continue.

******************************
EOF
fi
