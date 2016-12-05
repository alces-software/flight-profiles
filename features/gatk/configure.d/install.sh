#!/bin/bash

# Installer for Genome Analysis Toolkit (GATK)

RAW_TARBALL="/tmp/GenomeAnalysisTK-3.5.tar.bz2"

if ! type -p java; then
  yum -y -q install java-1.8.0-openjdk
fi

if [[ -f $RAW_TARBALL ]]; then
  installdir="/opt/gatk/"

  mkdir "$installdir"

  echo "Installing GATK to $installdir..."

  pushd "$installdir"

  tar -xf "$RAW_TARBALL"

  popd

  mkdir -p "$cw_ROOT/etc/modules/apps/"
  cp "`dirname "$0"`"/../resources/modulefile "$cw_ROOT/etc/modules/apps/gatk"
  cat <<EOF
******************************

Installation complete. A modulefile has been installed for using GATK. To
enable it run:

  alces module load apps/gatk

Once enabled you can then use GATK by running e.g.

  GenomeAnalysisTK [-jvm-args] -R reference.fasta -T GATKToolName -OPTION1 value1 -OPTION2 value2...

You can now delete the release file by running:

  rm $RAW_TARBALL

******************************
EOF

else
  cat <<EOF
******************************
  Please download the GATK release file and copy it to

  $RAW_TARBALL

  Then, restart the customization process by running

  alces customize trigger configure profile-gatk

  Installation will then continue.

******************************
EOF
fi
