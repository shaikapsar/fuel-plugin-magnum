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
# caas_magnum::rabbitmq

class caas_magnum::rabbitmq {

  notice('MODULAR: caas_magnum/rabbitmq')

  $magnum          = hiera_hash('fuel-plugin-magnum', undef)
  $magnum_enabled  = pick($magnum['metadata']['enabled'], false)

  if ($magnum_enabled) {

    $network_scheme  = hiera_hash('network_scheme')

    $rabbit_username = hiera($magnum['rabbit_user'], 'magnum')
    $rabbit_password = $magnum['rabbit_password']

    rabbitmq_user { $rabbit_username :
      admin    => true,
      password => $rabbit_password,
      provider => 'rabbitmqctl',
    }

    rabbitmq_user_permissions { "${rabbit_username}@/":
      configure_permission => '.*',
      write_permission     => '.*',
      read_permission      => '.*',
      provider             => 'rabbitmqctl',
    }

  }
}
