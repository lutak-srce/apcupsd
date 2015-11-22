#
# = Class: apcupsd::params
#
# This class provides defaults for apcuspd and apcupsd::web classes
#
class apcupsd::params {
  $ensure           = 'present'
  $version          = undef
  $status           = 'enabled'
  $file_mode        = '0644'
  $file_owner       = 'root'
  $file_group       = 'root'

  $dependency_class = undef
  $my_class         = undef

  # install package depending on major version
  case $::osfamily {
    default: {}
    /(RedHat|redhat|amazon)/: {
      $package           = 'apcupsd'
      $package_web       = 'apcupsd-cgi'
      $service           = 'apcupsd'
      $file_apcupsd_conf = '/etc/apcupsd/apcupsd.conf'
      $file_hosts_conf   = '/etc/apcupsd/hosts.conf'
    }
    /(debian|ubuntu)/: {
    }
  }

}
