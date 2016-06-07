#
# Copyright (C) 2016 AT&T Inc, Services.
#
# Author: Shaik Apsar
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# caas_magnum::firewall

class caas_magnum::firewall {

  notice('MODULAR: caas_magnum/firewall')

  $magnum          = hiera_hash('fuel-plugin-magnum', undef)
  $magnum_enabled  = pick($magnum['metadata']['enabled'], false)

  if ($magnum_enabled) {

    $network_scheme  = hiera_hash('network_scheme')

    $magnum_api_port  = hiera($magnum['magnum_api_port'], 9511)
    $magnum_networks  = get_routable_networks_for_network_role($network_scheme, 'magnum/api')

    openstack::firewall::multi_net {'511 magnum-api':
      port        => $magnum_api_port,
      proto       => 'tcp',
      action      => 'accept',
      source_nets => $magnum_networks,
    }
  }
}
