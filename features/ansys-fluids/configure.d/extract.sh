#!/bin/bash

# Wrapper for Ansys Fluids Install
role="$2"
if [ "$role" == "master" ]; then
    tmpdir=/tmp/
    package=FLUIDS_170_LINX64.tar
    license=ansys-fluids-license.lic
    installdir=/opt/apps/ansys-fluids
    packagepath=${tmpdir}${package}
    licensepath=${tmpdir}${license}
    version="v170"

    require files
    require network

    files_load_config cluster-customizer
    s3cfg="$(mktemp /tmp/cluster-customizer.s3cfg.XXXXXXXX)"
    cat <<EOF > "${s3cfg}"
[default]
access_key = "${cw_CLUSTER_CUSTOMIZER_access_key_id}"
secret_key = "${cw_CLUSTER_CUSTOMIZER_secret_access_key}"
security_token = ""
use_https = True
check_ssl_certificate = True
EOF
    if [ -n "${cw_CLUSTER_CUSTOMIZER_bucket}" ]; then   
	echo ${cw_CLUSTER_CUSTOMIZER_bucket}
        ${cw_ROOT}/opt/s3cmd/s3cmd -c ${s3cfg} get ${cw_CLUSTER_CUSTOMIZER_bucket}/apps/ansys-fluids/${package} ${packagepath}
        ${cw_ROOT}/opt/s3cmd/s3cmd -c ${s3cfg} get ${cw_CLUSTER_CUSTOMIZER_bucket}/apps/ansys-fluids/${license} ${licensepath}     
    elif network_is_ec2; then
        bucket="s3://alces-flight-$(network_ec2_hashed_account)"
	echo $bucket
        ${cw_ROOT}/opt/s3cmd/s3cmd get ${bucket}/apps/ansys-fluids/${package} ${packagepath}
        ${cw_ROOT}/opt/s3cmd/s3cmd get ${bucket}/apps/ansys-fluids/${license} ${licensepath}
    else
         echo "Unable to determine bucket name for customizations"
         return 0
    fi
    if [[ -f $packagepath && -f $licensepath ]]; then
        mkdir -p $installdir/${version}/archive
	cd $installdir
	echo "Unpacking Ansys Fluids install files..."
        mkdir -p ${tmpdir}/ansys-fluids
	tar -xvf $packagepath --directory ${tmpdir}/ansys-fluids
	mkdir -p ${installdir}/${version}/license
	cp $licensepath ${installdir}/${version}/license/ansys-fluids.lic
	${tmpdir}/ansys-fluids/INSTALL -silent -install_dir ${installdir}/${version}/.
        mkdir -p ${installdir}/${version}/licmanager
        ${tmpdir}/ansys-fluids/INSTALL.LM -licfilepath ${installdir}/${version}/license/ansys-fluids.lic -silent -install_dir ${installdir}/${version}/licmanager
	if [[ $? -eq 0 ]]; then
	   mkdir -p /opt/apps/etc/modules/apps
	   cp "`dirname "$0"`"/../resources/modulefile "/opt/apps/etc/modules/apps/ansys-fluids"
           if ! grep -q /opt/apps/etc/modules /opt/clusterware/etc/modulerc/modulespath; then
	        echo "/opt/apps/etc/modules" >> /opt/clusterware/etc/modulerc/modulespath
	fi
      cat <<EOF
 ******************************

Installation complete. A modulefile has been installed for using Ellexus Mistral . To enable it run:

   alces module load apps/ansys-fluids

You can now delete the installer file by running

   rm $packagepath
   
******************************
EOF
      else
	echo "Installation failed. See above for error output."
      fi

    else
      cat <<EOF
******************************
  Please download the Ansys Fluids all-in-one tarball from 
  the download link provided when you purchased Ansys Fluids.
      
  If you do not have a download link, please contact Ansys Support 
  at info@ansys.com.

  Then, please copy the License file and the zip archive in the S3 
  customized bucket for this cluster:
  s3://alces-flight-$(network_ec2_hashed_account)/apps/ansys-fluids/ansys-fluids.lic
  s3://alces-flight-$(network_ec2_hashed_account)/apps/ansys-fluids/FLUIDS_170_LINX64.tar
      
  respectively and run the following command:

    alces customize trigger configure feature-ansys-fluids

  Installation will then continue.

******************************
EOF
    fi
else
    #This isn't a master node
    if ! grep -q /opt/apps/etc/modules /opt/clusterware/etc/modulerc/modulespath; then
      echo "/opt/apps/etc/modules" >> /opt/clusterware/etc/modulerc/modulespath
    fi
fi
