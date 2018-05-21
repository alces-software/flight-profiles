#!/bin/bash

cw_ROOT=/opt/clusterware
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DATA_DIR="${DIR}"/clusterware-www-static-dashboard

# If this is not a Flight Launch cluster, replace the use of Flight Manage
# with a static dashboard.
if ! grep -q '^cw_CLUSTER_CUSTOMIZER_features=.*\blaunch-compat\b' ${cw_ROOT}/etc/cluster-customizer.rc; then
    # Remove obsolete configuration files.
    if [ -f "${cw_ROOT}/etc/alces-flight-www/server-https.d/redirect-https-to-launch-service.conf" ]; then
        rm "${cw_ROOT}/etc/alces-flight-www/server-https.d/redirect-https-to-launch-service.conf" 
    fi
    if [ -f "${cw_ROOT}/etc/alces-flight-www/server-https.d/cluster-vpn.conf" ]; then
        rm "${cw_ROOT}/etc/alces-flight-www/server-https.d/cluster-vpn.conf"
    fi

    # Install updated cluster-vpn nginx config.
    sed -e "s,_ROOT_,${cw_ROOT},g" \
        "${DATA_DIR}"/etc/alces-flight-www/cluster-vpn.conf.template > \
        "${cw_ROOT}"/etc/alces-flight-www/server-https.d/cluster-vpn.conf

    # Copy static dashboard into place.
    cp -ar "${DATA_DIR}"/default/* "${cw_ROOT}"/var/lib/alces-flight-www/flight/

    source "${cw_ROOT}"/etc/flight.rc
    RELEASE="$(echo ${cw_FLIGHT_release})"
    sed -e "s,_RELEASE_,${RELEASE},g" \
        -i "${cw_ROOT}/var/lib/alces-flight-www/flight/index.html"
fi
