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
# caas_magnum::domain
#
# TODO(shaikapsar): workaround for bugfix https://bugs.launchpad.net/puppet-magnum/+bug/1581372
class caas_magnum::domain {

  notice('MODULAR: caas_magnum/domain')

  $magnum          = hiera_hash('fuel-plugin-magnum', undef)
  $magnum_enabled  = pick($magnum['metadata']['enabled'], false)

  if ($magnum_enabled) {

    $access_hash                = hiera_hash('access', {})
    $management_vip             = hiera('management_vip')
    $region                     = hiera('region', 'RegionOne')
    $service_endpoint           = hiera('service_endpoint')
    $public_ssl_hash            = hiera_hash('public_ssl', {})
    $ssl_hash                   = hiera_hash('use_ssl', {})

    $domain_name                = pick($magnum['domain_name'], 'magnum')
    $domain_admin               = pick($magnum['domain_admin'], 'magnum_admin')
    $domain_admin_email         = pick($magnum['domain_admin_email'], 'magnum_admin@localhost')
    $domain_password            = $magnum['domain_password']

    $admin_tenant               = $access_hash['tenant']
    $admin_user                 = $access_hash['user']
    $admin_password             = $access_hash['password']
    $default_domain_id          = 'Default'
    $identity_api_version       = '3'

    $internal_auth_protocol     = get_ssl_property($ssl_hash, {}, 'keystone', 'internal', 'protocol', 'http')
    $internal_auth_address      = get_ssl_property($ssl_hash, {}, 'keystone', 'internal', 'hostname', [hiera('keystone_endpoint', ''), $service_endpoint, $management_vip])
    $auth_uri                   = "${internal_auth_protocol}://${internal_auth_address}:5000/"
    $magnum_auth_uri            = "${auth_uri}v${identity_api_version}"

    validate_string($domain_password)

    $murano_settings_hash = hiera_hash('murano_settings', {})
    if has_key($murano_settings_hash, 'murano_repo_url') {
      $murano_repo_url = $murano_settings_hash['murano_repo_url']
    } else {
      $murano_repo_url = 'http://storage.apps.openstack.org'
    }

    $murano_hash    = hiera_hash('murano', {})
    $murano_plugins = pick($murano_hash['plugins'], {})
    if has_key($murano_plugins, 'glance_artifacts_plugin') {
      $murano_glare_plugin = $murano_plugins['glance_artifacts_plugin']['enabled']
    } else {
      $murano_glare_plugin = false
    }

    package { 'python-openstackclient' :
      ensure => 'installed',
    }

    osnailyfacter::credentials_file { '/root/openrc':
      admin_user          => $admin_user,
      admin_password      => $admin_password,
      admin_tenant        => $admin_tenant,
      region_name         => $region,
      auth_url            => $auth_uri,
      murano_repo_url     => $murano_repo_url,
      murano_glare_plugin => $murano_glare_plugin,
    }

    if roles_include('primary-magnum') {

      Package ['python-openstackclient']
        -> Class['::osnailyfacter::wait_for_keystone_backends']
          -> Class['::magnum::keystone::domain']

      class { '::osnailyfacter::wait_for_keystone_backends': }

      class { '::magnum::keystone::domain':
        domain_name        => $domain_name,
        domain_admin       => $domain_admin,
        domain_admin_email => $domain_admin_email,
        domain_password    => $domain_password,
      }

    }
  }
}
