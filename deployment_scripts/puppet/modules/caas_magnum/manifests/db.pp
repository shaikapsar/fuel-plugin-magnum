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
# caas_magnum::db

class caas_magnum::db {

  notice('MODULAR: caas_magnum/db')

  $magnum          = hiera_hash('fuel-plugin-magnum', undef)
  $magnum_enabled  = pick($magnum['metadata']['enabled'], false)

  if ($magnum_enabled) {

    $mysql_hash       = hiera_hash('mysql', {})
    $management_vip   = hiera('management_vip', undef)
    $database_vip     = hiera('database_vip', undef)

    $mysql_root_user     = pick($mysql_hash['root_user'], 'root')
    $mysql_db_create     = pick($mysql_hash['db_create'], true)
    $mysql_root_password = $mysql_hash['root_password']

    $db_user     = pick($magnum['db_user'], 'magnum')
    $db_name     = pick($magnum['db_name'], 'magnum')
    $db_password = $magnum['db_password']

    validate_string($db_password)

    $db_host          = pick($magnum['metadata']['db_host'], $database_vip)
    $db_create        = pick($magnum['metadata']['db_create'], $mysql_db_create)
    $db_root_user     = pick($magnum['metadata']['root_user'], $mysql_root_user)
    $db_root_password = pick($magnum['metadata']['root_password'], $mysql_root_password)

    $allowed_hosts = [ 'localhost', '127.0.0.1', '%' ]

    if ($db_create) {

      class { '::openstack::galera::client':
        custom_setup_class => hiera('mysql_custom_setup_class', 'galera'),
      }

      class { '::magnum::db::mysql':
        user          => $db_user,
        password      => $db_password,
        dbname        => $db_name,
        allowed_hosts => $allowed_hosts,
      }

      class { '::osnailyfacter::mysql_access':
        db_host     => $db_host,
        db_user     => $db_root_user,
        db_password => $db_root_password,
      }

      Class['::openstack::galera::client'] ->
        Class['::osnailyfacter::mysql_access'] ->
          Class['::magnum::db::mysql']
    }
  }
}
