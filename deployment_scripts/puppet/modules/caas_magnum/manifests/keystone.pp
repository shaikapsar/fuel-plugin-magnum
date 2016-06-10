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
# caas_magnum::keystone

class caas_magnum::keystone {

  notice('MODULAR: caas_magnum/keystone')

  $magnum          = hiera_hash('fuel-plugin-magnum', undef)
  $magnum_enabled  = pick($magnum['metadata']['enabled'], false)

  if ($magnum_enabled) {

    $management_vip     = hiera('management_vip')
    $public_ssl_hash    = hiera_hash('public_ssl', {})
    $ssl_hash           = hiera_hash('use_ssl', {})
    $public_vip         = hiera('public_vip')

    $public_protocol     = get_ssl_property($ssl_hash, $public_ssl_hash, 'magnum', 'public', 'protocol', 'http')
    $public_address      = get_ssl_property($ssl_hash, $public_ssl_hash, 'magnum', 'public', 'hostname', [$public_vip])

    $internal_protocol   = get_ssl_property($ssl_hash, {}, 'magnum', 'internal', 'protocol', 'http')
    $internal_address    = get_ssl_property($ssl_hash, {}, 'magnum', 'internal', 'hostname', [$management_vip])

    $admin_protocol      = get_ssl_property($ssl_hash, {}, 'magnum', 'admin', 'protocol', 'http')
    $admin_address       = get_ssl_property($ssl_hash, {}, 'magnum', 'admin', 'hostname', [$management_vip])

    $region              = pick($magnum['region'], hiera('region', 'RegionOne'))
    $password            = $magnum['auth_password']
    $auth_name           = pick($magnum['auth_name'], 'magnum')
    $email               = pick($magnum['email'], 'magnum@localhost')
    $configure_user      = pick($magnum['configure_user'], true)
    $configure_user_role = pick($magnum['configure_user_role'], true)
    $configure_endpoint  = pick($magnum['configure_endpoint'], true)
    $service_name        = pick($magnum['service_name'], 'magnum')
    $tenant              = pick($magnum['tenant'], 'services')

    validate_string($public_address)
    validate_string($password)

    $bind_port = '9511'

    $public_url          = "${public_protocol}://${public_address}:${bind_port}/v1"
    $internal_url        = "${internal_protocol}://${internal_address}:${bind_port}/v1"
    $admin_url           = "${admin_protocol}://${admin_address}:${bind_port}/v1"

    Class['::osnailyfacter::wait_for_keystone_backends']
      -> Class['::magnum::keystone::auth']

    class {'::osnailyfacter::wait_for_keystone_backends': }

    class { '::magnum::keystone::auth':
      configure_user      => $configure_user,
      configure_user_role => $configure_user_role,
      configure_endpoint  => $configure_endpoint,
      service_name        => $service_name,
      region              => $region,
      auth_name           => $auth_name,
      password            => $password,
      email               => $email,
      tenant              => $tenant,
      public_url          => $public_url,
      internal_url        => $internal_url,
      admin_url           => $admin_url,
    }

  }
}
