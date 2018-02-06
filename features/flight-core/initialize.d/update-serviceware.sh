#!/bin/bash
if grep -q 'clusterware-dropbox-cli-v2.0.0' /opt/clusterware/etc/serviceware.rc; then
    sed -i -e 's/clusterware-dropbox-cli-v2.0.0-cw1_8/clusterware-dropbox-cli-v2.0.1-cw1_9/g' \
        /opt/clusterware/etc/serviceware.rc
fi

if grep -q 'gridware-20171121-cw1_9' /opt/clusterware/etc/serviceware.rc; then
    sed -i -e 's/gridware-20171121-cw1_9/gridware-20180116-cw2_0/g' \
        /opt/clusterware/etc/serviceware.rc
    rm -rf /opt/clusterware/opt/gridware
    /opt/clusterware/bin/alces service install gridware
    sed -i -e 's/cw_GRIDWARE_prefer_binary=false/cw_GRIDWARE_prefer_binary=true/g' \
        /opt/clusterware/etc/gridware.rc
fi
