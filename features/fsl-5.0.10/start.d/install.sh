#==============================================================================
# Copyright (C) 2017 Stephen F. Norledge and Alces Software Ltd.
#
# This file/package is part of Alces Clusterware.
#
# Alces Clusterware is free software: you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License
# as published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# Alces Clusterware is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this package.  If not, see <http://www.gnu.org/licenses/>.
#
# For more information on the Alces Clusterware, please visit:
# https://github.com/alces-software/clusterware
#==============================================================================
setup() {
    local a xdg_config
    IFS=: read -a xdg_config <<< "${XDG_CONFIG_HOME:-$HOME/.config}:${XDG_CONFIG_DIRS:-/etc/xdg}"
    for a in "${xdg_config[@]}"; do
        if [ -e "${a}"/clusterware/config.rc ]; then
            source "${a}"/clusterware/config.rc
            break
        fi
    done
    if [ -z "${cw_ROOT}" ]; then
        echo "$0: unable to locate clusterware configuration"
        exit 1
    fi
    kernel_load
}

_fetch_app_from_s3() {
    local bucket s3cfg
    bucket="$1"
    s3cfg="$(mktemp /tmp/cluster-customizer.s3cfg.XXXXXXXX)"
    cat <<EOF > "${s3cfg}"
[default]
access_key = "${cw_CLUSTER_CUSTOMIZER_access_key_id}"
secret_key = "${cw_CLUSTER_CUSTOMIZER_secret_access_key}"
security_token = ""
use_https = True
check_ssl_certificate = True
EOF
    ${cw_ROOT}/opt/s3cmd/s3cmd -c ${s3cfg} get ${bucket}/apps/${_APP}/${_PACKAGE} ${_WORKDIR}/${_PACKAGE}
    rm -f ${s3cfg}
}

_install_prereqs() {
  yum install -y -e0 libpng12 libmng
}

_show_help() {
  cat <<EOF
******************************************************************************

  Please download the ${_APP_NAME} installation file(s) from
  ${_DOWNLOAD_URL}.

  Copy the installation archive to ${_WORKDIR} on this machine:

    ${_WORKDIR}/${_PACKAGE}

  For repeatable installation, upload to your Alces Flight S3
  customization bucket:

    ${bucket}/apps/${_APP}/${_PACKAGE}

  Once you have placed the files in one of these locations, run the
  following command:

    alces customize trigger configure feature-${_APP}-${_APP_VER}

  Installation will then continue.

******************************************************************************
EOF
}

_show_completed_message() {
  cat <<EOF
${_APP_NAME} installation completed.

EOF
}

_setup_logdir() {
  mkdir -p ${_LOGDIR}
}

_unpack_tarball() {
  echo "Unpacking tarball ${_PACKAGE} ..."
  mkdir -p ${_INSTALLDIR}
  tar -xvf ${_WORKDIR}/${_PACKAGE} \
      --directory ${_INSTALLDIR} \
      2>&1 > ${_LOGDIR}/${_APP}-${PPID}-untar
  chown -R root:gridware ${_INSTALLDIR}
}

_install_modulefile() {
  echo "Installing and Configuring modulefiles..."
  mkdir -p /opt/apps/etc/modules/apps/${_APP}
  cp ${_RESOURCES_DIR}/modulefile "/opt/apps/etc/modules/apps/${_APP}/${_APP_VER}"
  if ! grep -q /opt/apps/etc/modules /opt/clusterware/etc/modulerc/modulespath; then
      echo "/opt/apps/etc/modules" >> /opt/clusterware/etc/modulerc/modulespath
  fi
}

_install_app() {
    local bucket fetched_from_s3
    if [ ! -f ${_WORKDIR}/${_PACKAGE} ]; then
        files_load_config cluster-customizer
        if [ "${cw_CLUSTER_CUSTOMIZER_bucket}" ]; then
            bucket="${cw_CLUSTER_CUSTOMIZER_bucket}"
        elif network_is_ec2; then
            bucket="s3://alces-flight-$(network_ec2_hashed_account)"
        else
            echo "Unable to determine bucket name for application download."
            return 0
        fi
        _fetch_app_from_s3 "${bucket}"
        fetched_from_s3=true
        if [ ! -f ${_WORKDIR}/${_PACKAGE} ]; then
            wget ${_DOWNLOAD_URL} -O ${_WORKDIR}/${_PACKAGE}
        fi
    fi
    if [ -f ${_WORKDIR}/${_PACKAGE} ]; then
        _setup_logdir
        _install_prereqs
        _unpack_tarball
        _install_modulefile
        if [ "${fetched_from_s3}" ]; then
            rm -f ${_WORKDIR}/${_PACKAGE}
        fi
        _show_completed_message
    else
        _show_help
    fi
}

main() {
    local role
    role="$2"
    if [ "$role" == "master" ]; then
        _install_app
    else
       echo "Unable to determine role for instance"
       exit 1
    fi
}

setup
require files
require network
require handler
require ruby
require distro
require serviceware

_VENDOR="the Analysis Group, FMRIB, Oxford, UK."
_APP_NAME=FSL
_VENDOR_EMAIL=https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FSL
_APP=fsl
_APP_VER=5.0.10
_PACKAGE=fsl-5.0.10.tar.gz
_WORKDIR=/tmp
_LOGDIR=/var/log/clusterware/customizer/feature-${_APP}/${_APP_VER}
_INSTALLDIR=/opt/apps/fsl/5.0.10
_APP_MODULE_PATH=/opt/apps/
_RESOURCES_DIR="$(handler_dir)/../resources"
_DOWNLOAD_URL=https://s3-eu-west-1.amazonaws.com/alces-flight/Gridware/fsl-5.0.10.tar.gz

main "$@"
