#!/bin/bash

# Wrapper for Ellexus Mistral install.

require files
require network

files_load_config cluster-customizer
if [ -z "${cw_CLUSTER_CUSTOMIZER_bucket}" ]; then
	if network_is_ec2; then
		bucket="alces-flight-$(network_ec2_hashed_account)"
	else
		echo "Unable to determine bucket name for customizations"
		return 0
	fi
fi
s3cfg="$(mktemp /tmp/cluster-customizer.s3cfg.XXXXXXXX)"
cat <<EOF > "${s3cfg}"
[default]
access_key = "${cw_CLUSTER_CUSTOMIZER_access_key_id}"
secret_key = "${cw_CLUSTER_CUSTOMIZER_secret_access_key}"
security_token = ""
use_https = True
check_ssl_certificate = True
EOF

${cw_ROOT}/opt/s3cmd/s3cmd -c ${s3cfg} get ${cw_CLUSTER_CUSTOMIZER_bucket}/apps/mistral/mistral_2.9.4_x86_64.zip /tmp/mistral_2.9.4_x86_64.zip
${cw_ROOT}/opt/s3cmd/s3cmd -c ${s3cfg} get ${cw_CLUSTER_CUSTOMIZER_bucket}/apps/mistral/ellexusmistral-license.lic /tmp/ellexusmistral-license.lic

package=/tmp/mistral_2.9.4_x86_64.zip
license=/tmp/ellexusmistral-license.lic
installdir=/opt/apps/ellexusmistral
version="2.9.4"

if [[ -f $package && -f $license ]]; then

  mkdir -p $installdir
  cd $installdir
  echo "Unpacking Ellexus Mistral install files..."
  unzip -q $package
  mv mistral_2.9.4_x86_64 $version
  mkdir -p ${installdir}/${version}/license
  cp $license ${installdir}/${version}/license/ellexusmistral-license.lic
  if [[ $? -eq 0 ]]; then
       mkdir -p /opt/apps/etc/modules/apps
       cp "`dirname "$0"`"/../resources/modulefile "/opt/apps/etc/modules/apps/ellexusmistral"
  cat <<EOF
******************************

Installation complete. A modulefile has been installed for using Ellexus Mistral . To enable it run:

  alces module load apps/ellexusmistral

You can now delete the installer file by running

  rm $package
  
******************************
EOF
  else
    echo "Installation failed. See above for error output."
  fi

else
  cat <<EOF
******************************
  Please download the Ellexus Mistral all-in-one zip archive from 
  the download link provided when you purchased Mistral.
  
  If you do not have a download link, please contact Ellexus Support 
  at info@ellexus.com.

  Then, please copy the License file and the zip archive in the S3 
  customized bucket for this cluster:
  s3://alces-flight-$(network_ec2_hashed_account)/apps/ellexusmistral/ellexusmistral-license.lic
  s3://alces-flight-$(network_ec2_hashed_account)/apps/ellexusmistral/mistral_2.9.4_x86_64.zip 
  
  respectively and run the following command:

  alces customize trigger configure feature-ellexusmistral

  Installation will then continue.

******************************
EOF
fi
