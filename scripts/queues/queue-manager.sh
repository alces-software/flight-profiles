#!/bin/bash
#==============================================================================
# Copyright (C) 2017-2018 Stephen F. Norledge and Alces Software Ltd.
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

_queues_load_personality() {
  if [ -z "${_QUEUES_PERSONALITY_LOADED}" ]; then
    eval $(_queues_extract_personality)
    _QUEUES_PERSONALITY_LOADED=true
  fi
}

_queues_extract_personality() {
  ruby_run <<RUBY
require 'yaml'
p_file = '${cw_ROOT}/etc/personality.yml'
begin
  if File.exists?(p_file)
    personality = YAML.load_file(p_file)
    if queues_config = personality['queue-manager']
      queues_config.each do |key, value|
        puts "_QUEUES_#{key}=#{value}"
      end
    end
  end
end
RUBY
}

_queues_auth_password() {
  if [ -z "${cw_CLUSTER_auth_token}" ]; then
      files_load_config auth config/cluster
  fi
  echo "${cw_CLUSTER_auth_token}"
}

_queues_cluster_uuid() {
  if [ -z "${cw_CLUSTER_uuid}" ]; then
      files_load_config config config/cluster
  fi
  echo "${cw_CLUSTER_uuid}"
}

_queues_endpoint() {
  local uuid
  uuid="$(_queues_cluster_uuid)"
  echo "${_QUEUES_endpoint_url:-https://launch-api.alces-flight.com}/api/v1/clusters/${uuid}/compute-queue-actions"
}

main() {
    files_load_config instance config/cluster
    if [ "${cw_INSTANCE_role}" != "master" ]; then
        return 0
    fi

    if files_lock "launch-queue-management"; then
        trap files_unlock EXIT
        _queues_load_personality
        local feature_dir

        feature_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")"/../ && pwd)"

        export cw_UI_disable_spinner=true
        ruby_exec "${feature_dir}/share/queue-manager.rb" \
            "${_ALCES}" \
            "$(_queues_endpoint)" \
            "$(_queues_cluster_uuid)" \
            "$(_queues_auth_password)"
    else
        echo "Locking failed; unable to process launch compute actions queue"
        return 1
    fi
}

setup
require files
require ruby

_ALCES="${cw_ROOT}"/bin/alces

main "$@"
