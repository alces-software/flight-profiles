#!/bin/bash
if grep -q 'dmidecode' /opt/clusterware/lib/functions/network.functions.sh; then
    pushd /opt/clusterware
    patch -p1 <<'PATCH'
diff --git a/lib/functions/network.functions.sh b/lib/functions/network.functions.sh
index 386178b..27bd630 100644
--- a/lib/functions/network.functions.sh
+++ b/lib/functions/network.functions.sh
@@ -176,8 +176,8 @@ network_cidr_to_mask() {
 
 network_is_ec2() {
   [ -f /sys/hypervisor/uuid ] && [ "$(head -c3 /sys/hypervisor/uuid)" == "ec2" ] ||
-      [ "$(dmidecode -s baseboard-manufacturer)" == "Amazon Corporate LLC" ] ||
-      [ "$(dmidecode -s baseboard-manufacturer)" == "Amazon EC2" ] ||
+      [ "$(cat /sys/devices/virtual/dmi/id/board_vendor)" == "Amazon Corporate LLC" ] ||
+      [ "$(cat /sys/devices/virtual/dmi/id/board_vendor)" == "Amazon EC2" ] ||
       [ "${cw_TEST_ec2}" == "true" ]
 }
 
PATCH
    popd
fi
