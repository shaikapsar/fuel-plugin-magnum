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

    $admin_protocol            = get_ssl_property($ssl_hash, {}, 'magnum', 'admin', 'protocol', 'http')
    $admin_address             = get_ssl_property($ssl_hash, {}, 'magnum', 'admin', 'hostname', [$management_vip])

    $magnum_endpoint_type      = pick($magnum['magnum_endpoint_type'], 'internalURL')
    $heat_endpoint_type        = pick($magnum['heat_endpoint_type'], 'internalURL')
    $glance_endpoint_type      = pick($magnum['glance_endpoint_type'], 'internalURL')
    $barbican_endpoint_type    = pick($magnum['barbican_endpoint_type'], 'internalURL')
    $nova_endpoint_type        = pick($magnum['nova_endpoint_type'], 'internalURL')
    $cinder_endpoint_type      = pick($magnum['cinder_endpoint_type'], 'internalURL')
    $neutron_endpoint_typ      = pick($magnum['neutron_endpoint_type'], 'internalURL')


    $public_url                = "${public_protocol}://${public_address}:${bind_port}/v1"
    $internal_url              = "${internal_protocol}://${internal_address}:${bind_port}/v1"
    $admin_url                 = "${admin_protocol}://${admin_address}:${bind_port}/v1"

    $db_user                   = pick($magnum['db_user'], 'magnum')
    $db_name                   = pick($magnum['db_name'], 'magnum')
    $db_password               = $magnum['db_password']
    $read_timeout              = '60'
    $db_connection             = "mysql://${db_user}:${db_password}@${database_vip}/${db_name}?read_timeout=${read_timeout}"

    $rabbit_username = hiera( $magnum['rabbit_user'], 'magnum')
    $rabbit_password = $magnum['rabbit_password']

    $admin_password       = $magnum['auth_password']
    $admin_user           = pick($magnum['auth_name'], 'magnum')
    $admin_tenant_name    = pick($magnum['tenant'], 'services')

    $bind_host            = get_network_role_property('magnum/api', 'ipaddr')

    class { '::magnum::client': }

    class { '::magnum':
      debug                  => $debug,
      verbose                => $verbose,
      use_syslog             => $use_syslog,
      use_stderr             => $use_stderr,
      rabbit_hosts           => $amqp_hosts,
      rabbit_port            => $amqp_port,
      rabbit_userid          => $rabbit_username,
      rabbit_password        => $rabbit_password,
      database_connection    => $db_connection,
      database_idle_timeout  => $idle_timeout,
      database_max_pool_size => $max_pool_size,
      database_max_overflow  => $max_overflow,
      database_max_retries   => $max_retries,
      region_name            => $region,
      magnum_endpoint_type   => $magnum_endpoint_type,
      heat_endpoint_type     => $heat_endpoint_type,
      glance_endpoint_type   => $glance_endpoint_type,
      barbican_endpoint_type => $barbican_endpoint_type,
      nova_endpoint_type     => $nova_endpoint_type,
      cinder_endpoint_type   => $cinder_endpoint_type,
      neutron_endpoint_type  => $neutron_endpoint_type,
    }

    class { '::magnum::api':
      admin_password    => $admin_password,
      admin_user        => $admin_user,
      admin_tenant_name => $admin_tenant_name,
      auth_uri          => $auth_uri,
      identity_uri      => $identity_uri,
      host              => $bind_host,
    }

    class { '::magnum::conductor': }

    class { '::magnum::certificates': }

    class { '::magnum::config':
      magnum_config => {
        'trust/trustee_domain_admin_password' => { value        => $magnum['domain_password'] },
      },
    }

  }
}
