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
# caas_magnum::magnum

class caas_magnum::magnum {

  notice('MODULAR: caas_magnum/magnum')

  $magnum          = hiera_hash('fuel-plugin-magnum', undef)
  $magnum_enabled  = pick($magnum['metadata']['enabled'], false)

  if ($magnum_enabled) {

    prepare_network_config(hiera('network_scheme', {}))

    $access_hash                = hiera_hash('access', {})
    $keystone_hash              = hiera_hash('keystone', {})
    $public_vip                 = hiera('public_vip')
    $database_vip               = hiera('database_vip')
    $management_vip             = hiera('management_vip')
    $region                     = hiera('region', 'RegionOne')
    $service_endpoint           = hiera('service_endpoint')
    $debug                      = hiera('debug', false)
    $verbose                    = hiera('verbose', true)
    $use_syslog                 = hiera('use_syslog', true)
    $use_stderr                 = hiera('use_stderr', false)
    $rabbit_ha_queues           = hiera('rabbit_ha_queues')
    $amqp_port                  = hiera('amqp_port')
    $amqp_hosts                 = hiera('amqp_hosts')
    $public_ssl_hash            = hiera_hash('public_ssl', {})
    $ssl_hash                   = hiera_hash('use_ssl', {})
    $external_dns               = hiera_hash('external_dns', {})
    $external_lb                = hiera('external_lb', false)
    $max_retries                = hiera('max_retries')
    $max_pool_size              = hiera('max_pool_size')
    $max_overflow               = hiera('max_overflow')
    $idle_timeout               = hiera('idle_timeout')

    $internal_auth_protocol     = get_ssl_property($ssl_hash, {}, 'keystone', 'internal', 'protocol', 'http')
    $internal_auth_address      = get_ssl_property($ssl_hash, {}, 'keystone', 'internal', 'hostname', [hiera('keystone_endpoint', ''), $service_endpoint, $management_vip])
    $auth_uri                   = "${internal_auth_protocol}://${internal_auth_address}:5000/"

    $admin_auth_protocol        = get_ssl_property($ssl_hash, {}, 'keystone', 'admin', 'protocol', 'http')
    $admin_auth_address         = get_ssl_property($ssl_hash, {}, 'keystone', 'admin', 'hostname', [hiera('keystone_endpoint', ''), $service_endpoint, $management_vip])
    $identity_uri               = "${admin_auth_protocol}://${admin_auth_address}:35357/"

    $public_protocol            = get_ssl_property($ssl_hash, $public_ssl_hash, 'magnum', 'public', 'protocol', 'http')
    $public_address             = get_ssl_property($ssl_hash, $public_ssl_hash, 'magnum', 'public', 'hostname', [$public_vip])

    $internal_protocol          = get_ssl_property($ssl_hash, {}, 'magnum', 'internal', 'protocol', 'http')
    $internal_address           = get_ssl_property($ssl_hash, {}, 'magnum', 'internal', 'hostname', [$management_vip])

    $admin_protocol             = get_ssl_property($ssl_hash, {}, 'magnum', 'admin', 'protocol', 'http')
    $admin_address              = get_ssl_property($ssl_hash, {}, 'magnum', 'admin', 'hostname', [$management_vip])

    $haproxy_stats_url = "http://${service_endpoint}:10000/;csv"

    $magnum_endpoint_type       = pick($magnum['magnum_endpoint_type'], 'internalURL')
    $heat_endpoint_type         = pick($magnum['heat_endpoint_type'], 'internalURL')
    $glance_endpoint_type       = pick($magnum['glance_endpoint_type'], 'internalURL')
    $barbican_endpoint_type     = pick($magnum['barbican_endpoint_type'], 'internalURL')
    $nova_endpoint_type         = pick($magnum['nova_endpoint_type'], 'internalURL')
    $cinder_endpoint_type       = pick($magnum['cinder_endpoint_type'], 'internalURL')
    $neutron_endpoint_type      = pick($magnum['neutron_endpoint_type'], 'internalURL')


    $public_url                 = "${public_protocol}://${public_address}:${bind_port}/v1"
    $internal_url               = "${internal_protocol}://${internal_address}:${bind_port}/v1"
    $admin_url                  = "${admin_protocol}://${admin_address}:${bind_port}/v1"

    $db_user                    = pick($magnum['db_user'], 'magnum')
    $db_name                    = pick($magnum['db_name'], 'magnum')
    $db_password                = $magnum['db_password']
    $read_timeout               = '60'
    $db_connection              = "mysql://${db_user}:${db_password}@${database_vip}/${db_name}?read_timeout=${read_timeout}"

    $rabbit_username            = hiera( $magnum['rabbit_user'], 'magnum')
    $rabbit_password            = $magnum['rabbit_password']

    $magnum_admin_password      = $magnum['auth_password']
    $magnum_admin_user          = pick($magnum['auth_name'], 'magnum')
    $magnum_admin_tenant_name   = pick($magnum['tenant'], 'services')

    $bind_host                  = get_network_role_property('magnum/api', 'ipaddr')

    $domain_name                = pick($magnum['domain_name'], 'magnum')
    $domain_admin               = pick($magnum['domain_admin'], 'magnum_admin')
    $domain_admin_email         = pick($magnum['domain_admin_email'], 'magnum_admin@localhost')
    $domain_password            = $magnum['domain_password']

    $admin_token                = $keystone_hash['admin_token']
    $admin_tenant               = $access_hash['tenant']
    $admin_email                = $access_hash['email']
    $admin_user                 = $access_hash['user']
    $admin_password             = $access_hash['password']

    validate_string($domain_password)

    $murano_settings_hash = hiera_hash('murano_settings', {})
    if has_key($murano_settings_hash, 'murano_repo_url') {
      $murano_repo_url = $murano_settings_hash['murano_repo_url']
    } else {
      $murano_repo_url = 'http://storage.apps.openstack.org'
    }

    class { '::osnailyfacter::wait_for_keystone_backends':}

    class { '::magnum::client': }

    class { '::magnum::db':
      database_connection    => $db_connection,
      database_idle_timeout  => $idle_timeout,
      database_max_pool_size => $max_pool_size,
      database_max_overflow  => $max_overflow,
      database_max_retries   => $max_retries,
    }

    class { '::magnum':
      rabbit_hosts    => $amqp_hosts,
      rabbit_port     => $amqp_port,
      rabbit_userid   => $rabbit_username,
      rabbit_password => $rabbit_password,
    }

  osnailyfacter::credentials_file { '/root/openrc':
    admin_user      => $admin_user,
    admin_password  => $admin_password,
    admin_tenant    => $admin_tenant,
    region_name     => $region,
    auth_url        => $auth_uri,
    murano_repo_url => $murano_repo_url,
  }

    class { '::magnum::keystone::domain':
      domain_name        => $domain_name,
      domain_admin       => $domain_admin,
      domain_admin_email => $domain_admin_email,
      domain_password    => $domain_password,
    }

    class { '::magnum::api':
      admin_password    => $magnum_admin_password,
      admin_user        => $magnum_admin_user,
      admin_tenant_name => $magnum_admin_tenant_name,
      auth_uri          => $auth_uri,
      identity_uri      => $identity_uri,
      host              => $bind_host,
    }

    class { '::magnum::conductor': }

    class { '::magnum::certificates': }

    class { '::magnum::config':
      magnum_config => {
        'magnum_client/region_name'     => {  value       => $region },
        'magnum_client/endpoint_type'   => {  value       => $magnum_endpoint_type },
        'heat_client/region_name'       => {  value       => $region },
        'heat_client/endpoint_type'     => {  value       => $heat_endpoint_type },
        'glance_client/region_name'     => {  value       => $region },
        'glance_client/endpoint_type'   => {  value       => $glance_endpoint_type },
        'barbican_client/region_name'   => {  value       => $region },
        'barbican_client/endpoint_type' => {  value       => $barbican_endpoint_type },
        'nova_client/region_name'       => {  value       => $region },
        'nova_client/endpoint_type'     => {  value       => $nova_endpoint_type },
        'cinder_client/region_name'     => {  value       => $region },
        'cinder_client/endpoint_type'   => {  value       => $cinder_endpoint_type },
        'neutron_client/region_name'    => {  value       => $region },
        'neutron_client/endpoint_type'  => {  value       => $neutron_endpoint_type },
      },
    }

    Osnailyfacter::Credentials_file <||>
      -> Class['::osnailyfacter::wait_for_keystone_backends']
        -> Class['::magnum::keystone::domain']
  }
}
