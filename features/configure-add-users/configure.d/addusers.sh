#!/bin/bash
#################################################################
# Script: adduser.sh
# Date: 04/04/17
# Desc: Adds the users in userlist.cfg and groups in grouplist.cfg
#
# Preconditions:
#   The list files must be stored in client s3-clusterware-bucket
#     -> <s3-clusterware-bucket>/configure-add-users/userlist.cfg
#     -> <s3-clusterware-bucket>/configure-add-users/grouplist.cfg
#   Format for users:  username UID, primary_GID [, secondary_GID ...]
#   Format for groups: groupname, GID
#   Secondary groups must be included in grouplist.cfg
#
# NOTE:
#   The primary group will be made automatically if not included
#   Blank and lines starting with '#' in the list files are ignored
##################################################################
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Display help
function displayHelp {
  cat << EOF >&2
******** CONFIGURE-ADD-USERS ********
'configure-add-users' requires a list of users and groups to run.
These files must be located in your s3 bucket

Examples files can be found in:
$DIR

******** Group List ********
S3 LOCATION:
<s3-clusterware-bucket>/configure-add-users/grouplist.cfg

FORMAT:
<group_name>, <group_id>

******** User List ********
S3 LOCATION:
<s3-clusterware-bucket>/configure-add-users/userlist.cfg

FORMAT:
<user_name>, <user_id>, <primary_group_id> [, other_gid_1, other_gid_2 ...]

NOTE:
If the primary_group does not exist, it will automatically be created with
the same name as the user.

The secondary groups are optional by must be defined in the group list
EOF
}

# Sets credentials for connecting to S3
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

# Pulls the user and groups list from client's S3 bucket
showHelp=""
s3UserFile=${cw_CLUSTER_CUSTOMIZER_bucket}/configure-add-users/userlist.cfg
s3GroupFile=${cw_CLUSTER_CUSTOMIZER_bucket}/configure-add-users/grouplist.cfg
userFile="$(mktemp /tmp/cluster-customizer.user-list.XXXXXXXX)"
groupFile="$(mktemp /tmp/cluster-customizer.group-list.XXXXXXXX)"
if [ -n "${cw_CLUSTER_CUSTOMIZER_bucket}" ]; then
  out=$(${cw_ROOT}/opt/s3cmd/s3cmd -c ${s3cfg} --force get $s3UserFile $userFile 2>&1 >/dev/null)
  if [[ "$?" -ne 0 ]]; then
    echo "ERROR: Could not locate user list: $out" >&2
    showHelp=true
  fi
  out=$(${cw_ROOT}/opt/s3cmd/s3cmd -c ${s3cfg} --force get $s3GroupFile $groupFile 2>&1 >/dev/null)
  if [[ "$?" -ne 0 ]]; then
    echo "ERROR: Could not locate group list: $out" >&2
    showHelp=true
  fi
fi

# Adds group ($1 groupname, $2 gid)
function addGroupHelper() {
  out=$(groupadd -g $2 $1 2>&1)
  if [[ "$?" -ne 0 ]]; then
    echo "ERROR: Could not add group $1, $out" >&2
    showHelp=true
  fi
}

# Adds user ($1 username, $2 uid, $3 gid, $4+ secondary gids)
function addUserHelper() {
  # Creates a primary user group if it doesn't exist
  getent group $3 >/dev/null || addGroupHelper $1 $3

  # Adds the user
  out=$(adduser -u $2 -g $3 $1 2>&1)
  if [[ "$?" -ne 0 ]]; then
    echo "ERROR: Could not add user $1, $out" >&2
    showHelp=true
  fi

  # Adds user to additional groups
  args=("$@")
  for ((i=3; i < $#; i++)); do
    out=$(usermod -aG ${args[$i]} $1 2>&1)
    if [[ "$?" -ne 0 ]]; then
      echo "ERROR: Could not add $1 (user) to ${args[$i]} (gid), $out" >&2
      showHelp=true
    fi
  done
}

# Reads the groups from the list
delim="\s*,\s*"
while read -r line || [[ -n "$line" ]]; do
  #Validates input
  regex="^[a-z][a-z0-9]*$delim[0-9]+$"
  if [[ "$line" =~ $regex ]]; then
    addGroupHelper $(echo $line | sed "s/$delim/ /g")
  elif [[ $line ]] && ! [[ $line =~ ^# ]]; then
    echo "ERROR: Unrecognised group format: $line" 1>&2
    showHelp=true
  fi
done < $groupFile

# Reads the users from the list
while read -r line || [[ -n "$line" ]]; do
  # Validates input
  regex="^[a-z][a-z0-9]*($delim[0-9]+){2,}$"
  if [[ "$line" =~ $regex ]]; then
    addUserHelper $(echo $line | sed "s/$delim/ /g")
  elif [[ $line ]] && ! [[ $line =~ ^# ]]; then
    echo "ERROR: Unrecognised user format: $line" 1>&2
    showHelp=true
  fi
done < $userFile

# Deletes temporary files
rm -f $s3cfg
rm -f $userFile
rm -f $groupFile

# Sets exit code
if [[ $showHelp ]]; then
  displayHelp
  exit 1
else
  exit 0
fi
