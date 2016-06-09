# == Class: magnum
#
# magnum base package & configuration
#
# === Parameters
#
# [*package_ensure*]
#  (Optional) Ensure state for package
#  Defaults to 'present'
#
# [*verbose*]
#   (Optional) Should the daemons log verbose messages
#   Defaults to undef.
#
# [*debug*]
#   (Optional) Should the daemons log debug messages
#   Defaults to undef.
#
# [*log_dir*]
#   (Optional) Directory where logs should be stored
#   If set to boolean 'false', it will not log to any directory
#   Defaults to undef.
#
# [*use_syslog*]
#   (Optional) Use syslog for logging.
#   Defaults to undef.
#
# [*use_stderr*]
#   (optional) Use stderr for logging
#   Defaults to undef.
#
# [*log_facility*]
#   (Optional) Syslog facility to receive log lines.
#   Defaults to undef.
#
# [*notification_driver*]
#  (Optional) Notification driver to use
#  Defaults to $::os_service_default
#
# [*rpc_backend*]
#  (optional) The rpc backend implementation to use, can be:
#  rabbit (for rabbitmq)
#  Defaults to 'rabbit'
#
# [*rabbit_host*]
#  (Optional) Host for rabbit server
#  Defaults to $::os_service_default
#
# [*rabbit_hosts*]
#  (Optional) List of clustered rabbit servers
#  Defaults to $::os_service_default
#
# [*rabbit_port*]
#  (Optional) Port for rabbit server
#  Defaults to $::os_service_default
#
# [*rabbit_userid*]
#  (Optional) Username used to connecting to rabbit
#  Defaults to $::os_service_default
#
# [*rabbit_virtual_host*]
#  (Optional) Virtual host for rabbit server
#  Defaults to $::os_service_default
#
# [*rabbit_password*]
#  (Optional) Password used to connect to rabbit
#  Defaults to $::os_service_default
#
# [*rabbit_use_ssl*]
#  (Optional) Connect over SSL for rabbit
#  Defaults to $::os_service_default
#
# [*kombu_ssl_ca_certs*]
#  (Optional) SSL certification authority file (valid only if rabbit SSL is enabled)
#  Defaults to $::os_service_default
#
# [*kombu_ssl_certfile*]
#  (Optional) SSL cert file (valid only if rabbit SSL is enabled)
#  Defaults to $::os_service_default
#
# [*kombu_ssl_keyfile*]
#  (Optional) SSL key file (valid only if rabbit SSL is enabled)
#  Defaults to $::os_service_default
#
# [*kombu_ssl_version*]
#  (Optional) SSL version to use (valid only if rabbit SSL is enabled).
#  Valid values are TLSv1, SSLv23 and SSLv3. SSLv2 may be available
#  on some distributions.
#  Defaults to $::os_service_default
#
# [*database_connection*]
#   (Optional) Url used to connect to database.
#   Defaults to "mysql://magnum:magnum@localhost:3306/magnum".
#
# [*database_idle_timeout*]
#   (Optional) Timeout when db connections should be reaped.
#   Defaults to $::os_service_default
#
# [*database_max_retries*]
#   (Optional) Maximum number of database connection retries during startup.
#   Setting -1 implies an infinite retry count.
#   Defaults to $::os_service_default
#
# [*database_retry_interval*]
#   (Optional) Interval between retries of opening a database connection.
#    Defaults to $::os_service_default
#
# [*database_min_pool_size*]
#   (Optional) Minimum number of SQL connections to keep open in a pool.
#   Defaults to $::os_service_default
#
# [*database_max_pool_size*]
#   (Optional) Maximum number of SQL connections to keep open in a pool.
#   Defaults to $::os_service_default
#
# [*database_max_overflow*]
#   (Optional) If set, use this value for max_overflow with sqlalchemy.
#   Defaults to $::os_service_default
#
# [*database_db_max_retries*]
#   (Optional) Maximum retries in case of connection error or deadlock error
#   before error is raised. Set to -1 to specify an infinite retry count.
#   Defaults to $::os_service_default
#
# [*region_name*]
#   (Optional) Region name for services. This is the
#   default region name that heat talks to service endpoints on.
#   Defaults to $::os_service_default
#
# [*magnum_endpoint_type*]
#   (Optional) Type of endpoint in Identity service
#   catalog to use for communication with the OpenStack
#   service.
#   Defaults to $::os_service_default
#
# [*heat_endpoint_type*]
#   (Optional) Type of endpoint in Identity service
#   catalog to use for communication with the OpenStack
#   service.
#   Defaults to $::os_service_default
#
# [*glance_endpoint_type*]
#   (Optional) Type of endpoint in Identity service
#   catalog to use for communication with the OpenStack
#   service.
#   Defaults to $::os_service_default
#
# [*barbican_endpoint_type*]
#   (Optional) Type of endpoint in Identity service
#   catalog to use for communication with the OpenStack
#   service.
#   Defaults to $::os_service_default
#
# [*nova_endpoint_type*]
#   (Optional) Type of endpoint in Identity service
#   catalog to use for communication with the OpenStack
#   service.
#   Defaults to $::os_service_default
#
# [*cinder_endpoint_type*]
#   (Optional) Type of endpoint in Identity service
#   catalog to use for communication with the OpenStack
#   service.
#   Defaults to $::os_service_default
#
# [*neutron_endpoint_type*]
#   (Optional) Type of endpoint in Identity service
#   catalog to use for communication with the OpenStack
#   service.
#   Defaults to $::os_service_default
#
class magnum(
  $package_ensure      = 'present',
  $verbose             = undef,
  $debug               = undef,
  $log_dir             = undef,
  $use_syslog          = undef,
  $use_stderr          = undef,
  $log_facility        = undef,
  $notification_driver = $::os_service_default,
  $rpc_backend         = 'rabbit',
  $rabbit_host         = $::os_service_default,
  $rabbit_hosts        = $::os_service_default,
  $rabbit_port         = $::os_service_default,
  $rabbit_userid       = $::os_service_default,
  $rabbit_virtual_host = $::os_service_default,
  $rabbit_password     = $::os_service_default,
  $rabbit_use_ssl      = $::os_service_default,
  $kombu_ssl_ca_certs  = $::os_service_default,
  $kombu_ssl_certfile  = $::os_service_default,
  $kombu_ssl_keyfile   = $::os_service_default,
  $kombu_ssl_version   = $::os_service_default,
  $database_connection     = undef,
  $database_idle_timeout   = $::os_service_default,
  $database_min_pool_size  = $::os_service_default,
  $database_max_pool_size  = $::os_service_default,
  $database_max_retries    = $::os_service_default,
  $database_retry_interval = $::os_service_default,
  $database_max_overflow   = $::os_service_default,
  $database_db_max_retries = $::os_service_default,
  $region_name             = $::os_service_default,
  $magnum_endpoint_type    = $::os_service_default,
  $heat_endpoint_type      = $::os_service_default,
  $glance_endpoint_type    = $::os_service_default,
  $barbican_endpoint_type  = $::os_service_default,
  $nova_endpoint_type      = $::os_service_default,
  $cinder_endpoint_type    = $::os_service_default,
  $neutron_endpoint_type   = $::os_service_default,
) {

  include ::magnum::params
  include ::magnum::logging
  include ::magnum::policy
  include ::magnum::db

  package { 'magnum-common':
    ensure => $package_ensure,
    name   => $::magnum::params::common_package,
    tag    => ['openstack', 'magnum-package'],
  }

  if $rpc_backend == 'rabbit' {

    if ! $rabbit_password {
      fail('Please specify a rabbit_password parameter.')
    }

    magnum_config {
      'DEFAULT/rpc_backend' :                        value => 'rabbit';
      'oslo_messaging_rabbit/rabbit_userid' :        value => $rabbit_userid;
      'oslo_messaging_rabbit/rabbit_password' :      value => $rabbit_password, secret => true;
      'oslo_messaging_rabbit/rabbit_virtual_host' :  value => $rabbit_virtual_host;
      'oslo_messaging_rabbit/rabbit_use_ssl' :       value => $rabbit_use_ssl;
      'oslo_messaging_rabbit/kombu_ssl_ca_certs' :   value => $kombu_ssl_ca_certs;
      'oslo_messaging_rabbit/kombu_ssl_certfile' :   value => $kombu_ssl_certfile;
      'oslo_messaging_rabbit/kombu_ssl_keyfile' :    value => $kombu_ssl_keyfile;
      'oslo_messaging_rabbit/kombu_ssl_version' :    value => $kombu_ssl_version;
    }

    if ! is_service_default($rabbit_hosts) and $rabbit_hosts {
      magnum_config { 'oslo_messaging_rabbit/rabbit_hosts':     value => join(any2array($rabbit_hosts), ',') }
    } else {
      magnum_config { 'oslo_messaging_rabbit/rabbit_host':      value => $rabbit_host }
      magnum_config { 'oslo_messaging_rabbit/rabbit_port':      value => $rabbit_port }
      magnum_config { 'oslo_messaging_rabbit/rabbit_hosts':     ensure => absent }
    }

    if !is_service_default($notification_driver) and $notification_driver {
      magnum_config {
        'DEFAULT/notification_driver': value => join(any2array($notification_driver), ',');
      }
    } else {
        magnum_config { 'DEFAULT/notification_driver': ensure => absent; }
    }
  } else {
    magnum_config { 'DEFAULT/rpc_backend': value => $rpc_backend }
  }

   magnum_config {
    'magnum_client/region_name' :       value => $region_name;
    'magnum_client/endpoint_type' :     value => $magnum_endpoint_type;
    'heat_client/region_name' :         value => $region_name;
    'heat_client/endpoint_type' :       value => $heat_endpoint_type;
    'glance_client/region_name' :       value => $region_name;
    'glance_client/endpoint_type' :     value => $glance_endpoint_type;
    'barbican_client/region_name' :     value => $region_name;
    'barbican_client/endpoint_type' :   value => $barbican_endpoint_type;
    'nova_client/region_name' :         value => $region_name;
    'nova_client/endpoint_type' :       value => $nova_endpoint_type;
    'cinder_client/region_name' :       value => $region_name;
    'cinder_client/endpoint_type' :     value => $cinder_endpoint_type;
    'neutron_client/region_name' :      value => $region_name;
    'neutron_client/endpoint_type' :    value => $neutron_endpoint_type;
   }

}
