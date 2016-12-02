#!/bin/bash

# Installer for Queue (scripting framework for Genome Analysis Toolkit)

RAW_TARBALL="/tmp/Queue-3.5.tar.bz2"

if ! type -p java; then
  yum -y -q install java-1.8.0-openjdk
fi

if [[ -f $RAW_TARBALL ]]; then
  installdir="/opt/gatk-queue/"

  mkdir "$installdir"

  echo "Installing Queue to $installdir..."

  pushd "$installdir"

  tar -xf "$RAW_TARBALL"

  popd
  cp "`dirname "$0"`"/../resources/modulefile "$cw_ROOT/etc/modules/services/gatk-queue"
  cat <<EOF
******************************

Installation complete. A modulefile has been installed for using Queue. To
enable it run:

  alces module load services/gatk-queue

Once enabled you can then use Queue by running e.g.

  Queue [-jvm-args] -S somescript.scala

You can now delete the release file by running:

  rm $RAW_TARBALL

******************************
EOF

  rm -rf "$tempdir"
else
  cat <<EOF
******************************
  Please download the Queue release file and copy it to

  $RAW_TARBALL

  Then, restart the customization process by running

  alces customize trigger configure profile-gatk-queue

  Installation will then continue.

******************************
EOF
fi
