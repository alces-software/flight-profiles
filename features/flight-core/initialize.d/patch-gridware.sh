#!/bin/bash
if grep -q "ENV.has_key?('cw_GRIDWARE_userspace')" \
        /opt/clusterware/opt/gridware/lib/alces/packager/config.rb; then
    echo "Patching /opt/clusterware/opt/gridware/lib/alces/packager/config.rb"
    sed -i -e "s/ENV.has_key?('cw_GRIDWARE_userspace')/(ENV['cw_GRIDWARE_userspace'] || \"\") != \"\"/g" \
        /opt/clusterware/opt/gridware/lib/alces/packager/config.rb
fi
