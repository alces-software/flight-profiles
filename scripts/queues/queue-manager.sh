#!/bin/bash
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

_queues_cluster_uuid() {
  if [ -z "${cw_CLUSTER_uuid}" ]; then
      files_load_config config config/cluster
  fi
  echo "${cw_CLUSTER_uuid}"
}

_queues_endpoint() {
  local uuid
  uuid="$(_queues_cluster_uuid)"
  echo "${_QUEUES_ENDPOINT_URL:-https://launch.alces-flight.com}/api/v1/clusters/${uuid}/compute-queue-actions"
}

main() {
  files_load_config instance config/cluster
  if [ "${cw_INSTANCE_role}" != "master" ]; then
      return 0
  fi

  ruby_run <<RUBY
require 'json'
require 'open-uri'

def log(message)
  @log ||= File.open('/var/log/clusterware/queue-creator-2', 'a')
  @log.puts("#{Time.now.strftime('%b %e %H:%M:%S')} #{message}")
end

class Retry < RuntimeError; end
retries = 0

ACTION_TO_COMPUTE_COMMAND = {
  'CREATE' => 'addq',
  'MODIFY' => 'modq',
  'DELETE' => 'delq',
}.freeze

ACTION_TO_VERB = {
  'CREATE' => 'Adding',
  'MODIFY' => 'Modifying',
  'DELETE' => 'Deleting',
}.freeze

begin
  uri = URI.parse('$(_queues_endpoint)')
  uri.query = [
    uri.query,
    'filter[status]=PENDING',
    'filter[action]=CREATE,MODIFY,DELETE',
  ].compact.join('&')
  log("Downloading pending compute queue actions from #{uri}")
  response = JSON.parse(uri.open.read)
rescue OpenURI::HTTPError
  log("Download failed: #{\$!.message}")
else
  response['data'].each do |queue_action|
    self_link = queue_action['links']['self']
    # XXX Mark as in progress
    # XXX How do we send API requests from within Ruby?
    

    attrs = queue_action['attributes']
    spec = attrs['name']
    action = attrs['action']
    desired = attrs['desired'].to_s
    min = attrs['min'].to_s
    max = attrs['max'].to_s
    uuid = queue_action['id']
    log("#{ACTION_TO_VERB[action]} queue: #{spec} (#{desired}/#{min}-#{max}) (#{uuid})")
    begin
      IO.popen(['${_ALCES}', 'compute', ACTION_TO_COMPUTE_COMMAND[action],
                spec, desired, min, max,
                :err=>[:child, :out]]) do |io|
        while !io.eof?
          line = io.readline
          log(line)
          raise Retry.new if line =~ /operation in progress/
        end
      end
    rescue Retry
      if (retries += 1) < 20
        log('Operation in progress; retrying in 6s...')
        sleep 6
        retry
      end
    end
  end
ensure
  @log && @log.close
end
RUBY
}

setup
require files
require ruby

_ALCES="${cw_ROOT}"/bin/alces

main "$@"
