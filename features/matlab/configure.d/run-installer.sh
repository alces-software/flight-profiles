#!/bin/bash

# Wrapper for Matlab installer.

if [[ -f /tmp/R2016b_glnxa64_dvd1.iso && -f /tmp/R2016b_glnxa64_dvd2.iso ]]; then
  tempdir=$(mktemp -d -t customize-matlab-XXXXXX)
  installdir=$(mktemp -d -t customize-matlab-XXXXXX)

  sudo yum install -qy libXtst

  echo "Extracting files from DVD images..."

  mount -o loop /tmp/R2016b_glnxa64_dvd1.iso "$tempdir"
  cp -r "$tempdir"/* "$installdir"
  umount "$tempdir"

  mount -o loop /tmp/R2016b_glnxa64_dvd2.iso "$tempdir"
  cp -r "$tempdir"/* "$installdir"
  umount "$tempdir"

  read -p "Please enter your File Installation Key (xxxxx-xxxxx-xxxxx-xxxxx...): " file_installation_key

  read -e -p "Please enter the path to your license file (license.lic): " license_file

  cat > /tmp/matlab_install_settings.txt <<EOF
agreeToLicense=yes
mode=silent
destinationFolder=/opt/matlab
fileInstallationKey=$file_installation_key
licensePath=$license_file
EOF

  "$installdir"/install -inputFile /tmp/matlab_install_settings.txt

  if [[ $? -eq 0 ]]; then
    echo "Installation completed. Matlab available in /opt/matlab"
  else
    echo "Installation failed. See above for error output."
  fi

  rm /tmp/matlab_install_settings.txt
  rm -rf "$tempdir"
  rm -rf "$installdir"
else
  cat <<EOF
******************************
  Please download the Matlab R2016b ISO installer files
  from the following URL:

  https://uk.mathworks.com/downloads/web_downloads/select_iso?noent=y&publisher=MathWorks&release_name=R2016b

  Then, please copy the two .iso files to /tmp and run the following
  command:

  alces customize trigger configure profile-matlab

  You will need your File Installation Key, and your license file (.lic) should
  be available somewhere on the file system.

  Installation will then continue.

******************************
EOF
fi
