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

main() {
  local hostname
  
  files_load_config instance config/cluster
  if [ "${cw_INSTANCE_role}" != "master" ]; then
      return 0
  fi

  hostname=$(hostname -s)
  member_load_vars $hostname

  ruby_run <<RUBY
require 'yaml'

SCHEDULER_HANDLERS = {
  'gridscheduler' => 'cluster-sge',
  'openlava' => 'cluster-openlava',
  'pbspro' => 'cluster-pbspro',
  'slurm' => 'cluster-slurm',
  'torque' => 'cluster-torque'
}

def log(message)
  @log ||= File.open('/var/log/clusterware/scheduler-installer.log', 'a')
  @log.puts("#{Time.now.strftime('%b %e %H:%M:%S')} #{message}")
end

p_file = '${cw_ROOT}/etc/personality.yml'
begin
  if File.exists?(p_file)
    personality = YAML.load_file(p_file)
    if scheduler = personality['scheduler']
      log("Enabling scheduler profile: #{scheduler}")
      IO.popen(['${_ALCES}', 'handler', 'enable',
                SCHEDULER_HANDLERS[scheduler],
                :err=>[:child, :out]]) do |io|
        log(io.readline) until io.eof?
      end
      IO.popen(["${cw_ROOT}/etc/handlers/#{SCHEDULER_HANDLERS[scheduler]}/configure",
                :err=>[:child, :out]]) do |io|
        log(io.readline) until io.eof?
      end
      IO.popen(["${cw_ROOT}/etc/handlers/#{SCHEDULER_HANDLERS[scheduler]}/member-join",
                :err=>[:child, :out]], 'r+') do |io|
        io.puts("${hostname} ${cw_MEMBER_ip} ${cw_MEMBER_role} ${cw_MEMBER_tags}")
        io.close_write
        log(io.readline) until io.eof?
      end
      log("Configuring slave for scheduler: #{scheduler}")
      IO.popen(['${_ALCES}', 'customize', 'slave',
                'add', "feature/#{scheduler}",
                :err=>[:child, :out]]) do |io|
        log(io.readline) until io.eof?
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
require member

_ALCES="${cw_ROOT}"/bin/alces

main "$@"
