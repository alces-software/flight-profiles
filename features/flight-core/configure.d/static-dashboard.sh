#!/bin/bash

cw_ROOT=/opt/clusterware
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if ! grep -q '^cw_CLUSTER_CUSTOMIZER_features=.*\blaunch-compat\b' ${cw_ROOT}/etc/cluster-customizer.rc; then
    # Nothing to do this is a Flight Launch cluster.
    :
else
    # This is not a Flight Launch cluster. Replace the use of Flight Manage
    # with a static dashboard.

    # Remove obsolete configuration files.
    if [ -f "${cw_ROOT}/etc/alces-flight-www/server-https.d/redirect-https-to-launch-service.conf" ]; then
        rm "${cw_ROOT}/etc/alces-flight-www/server-https.d/redirect-https-to-launch-service.conf" 
    fi
    if [ -f "${cw_ROOT}/etc/alces-flight-www/server-https.d/cluster-vpn.conf" ]; then
        rm "${cw_ROOT}/etc/alces-flight-www/server-https.d/cluster-vpn.conf"
    fi

    # Install updated cluster-vpn nginx config.
    sed -e "s,_ROOT_,${cw_ROOT},g" \
        "${DIR}"/static-dashboard/etc/alces-flight-www/cluster-vpn.conf.template > \
        "${cw_ROOT}"/etc/alces-flight-www/server-https.d/cluster-vpn.conf

    # Copy static dashboard into place.
    cp -ar "${DIR}"/static-dashboard/default/* "${cw_ROOT}"/var/lib/alces-flight-www/flight/

    source "${cw_ROOT}"/etc/flight.rc
    RELEASE="$(echo ${cw_FLIGHT_release})"
    sed -e "s,_RELEASE_,${RELEASE},g" \
        -i "${cw_ROOT}/var/lib/alces-flight-www/flight/index.html"
fi
