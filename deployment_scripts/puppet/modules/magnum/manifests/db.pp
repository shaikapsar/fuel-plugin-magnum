# == Class: magnum::db
#
#  Configure the magnum database
#
# === Parameters
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
class magnum::db (
  $database_connection     = 'mysql://magnum:magnum@localhost:3306/magnum',
  $database_idle_timeout   = $::os_service_default,
  $database_min_pool_size  = $::os_service_default,
  $database_max_pool_size  = $::os_service_default,
  $database_max_retries    = $::os_service_default,
  $database_retry_interval = $::os_service_default,
  $database_max_overflow   = $::os_service_default,
  $database_db_max_retries = $::os_service_default,
) {

  # NOTE(shaikapsar): In order to keep backward compatibility we rely on the pick function
  # to use magnum::<myparam> if magnum::db::<myparam> isn't specified.
  $database_connection_real     = pick($::magnum::database_connection, $database_connection)
  $database_idle_timeout_real   = pick($::magnum::database_idle_timeout, $database_idle_timeout)
  $database_min_pool_size_real  = pick($::magnum::database_min_pool_size, $database_min_pool_size)
  $database_max_pool_size_real  = pick($::magnum::database_max_pool_size, $database_max_pool_size)
  $database_max_retries_real    = pick($::magnum::database_max_retries, $database_max_retries)
  $database_retry_interval_real = pick($::magnum::database_retry_interval, $database_retry_interval)
  $database_max_overflow_real   = pick($::magnum::database_max_overflow, $database_max_overflow)
  $database_db_max_retries_real = pick($::magnum::database_db_max_retries, $database_db_max_retries)

  validate_re($database_connection,
    '^(mysql(\+pymysql)?|postgresql):\/\/(\S+:\S+@\S+\/\S+)?')

  case $database_connection {
    /^mysql:\/\//: {
      $backend_package = false
      require 'mysql::bindings'
      require 'mysql::bindings::python'
    }
    /^postgresql:\/\//: {
      $backend_package = false
      require 'postgresql::lib::python'
    }
    /^sqlite:\/\//: {
      $backend_package = $::magnum::params::sqlite_package
    }
    default: {
      fail('Unsupported backend configured')
    }
  }

  if $backend_package and !defined(Package[$backend_package]) {
    package {'magnum-backend-package':
      ensure => present,
      name   => $backend_package,
      tag    => 'openstack',
    }
  }
  magnum_config {
    'database/connection':              value => $database_connection_real, secret => true;
    'database/idle_timeout':            value => $database_idle_timeout_real;
    'database/min_pool_size':           value => $database_min_pool_size_real;
    'database/max_retries':             value => $database_max_retries_real;
    'database/retry_interval':          value => $database_retry_interval_real;
    'database/max_pool_size':           value => $database_max_pool_size_real;
    'database/max_overflow':            value => $database_max_overflow_real;
    'database/database_db_max_retries': value => $database_max_overflow_real;
  }

}
