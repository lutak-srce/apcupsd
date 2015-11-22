#
# = Class: apcupsd::web
#
# This class manages Web interface for APC UPS monitoring daemon.
#
#
# == Parameters
#
# [*ensure*]
#   Type: string, default: 'present'
#   Manages package installation and class resources. Possible values:
#   * 'present' - Install package, ensure files are present (default)
#   * 'absent'  - Stop service and remove package and managed files
#
# [*package*]
#   Type: string, default on $::osfamily basis
#   Manages the name of the package.
#
# [*version*]
#   Type: string, default: undef
#   If this value is set, the defined version of package is installed.
#   Possible values are:
#   * 'x.y.z' - Specific version
#   * latest  - Latest available
#
# [*file_mode*]
# [*file_owner*]
# [*file_group*]
#   Type: string, default: '0600'
#   Type: string, default: 'root'
#   Type: string, default 'root'
#   File permissions and ownership information assigned to config files.
#
# [*file_hosts_conf*]
#   Type: string, default on $::osfamily basis
#   Path to hosts.conf.
#
# [*noops*]
#   Type: boolean, default: undef
#   Set noop metaparameter to true for all the resources managed by the module.
#   If true no real change is done is done by the module on the system.
#
# [*hosts*]
#   Type: array, default: []
#   Array of strings containing entries for UPSes to monitor.
#
class apcupsd::web (
  $ensure            = $::apcupsd::params::ensure,
  $package           = $::apcupsd::params::package,
  $version           = $::apcupsd::params::version,
  $file_mode         = $::apcupsd::params::file_mode,
  $file_owner        = $::apcupsd::params::file_owner,
  $file_group        = $::apcupsd::params::file_group,
  $file_hosts_conf   = $::apcupsd::params::file_hosts_conf,
  $dependency_class  = $::apcupsd::params::dependency_class,
  $my_class          = $::apcupsd::params::my_class,
  $noops             = undef,
  $hosts             = [],
) inherits apcupsd::params {

  ### Input parameters validation
  validate_re($ensure, ['present','absent'], 'Valid values are: present, absent')
  validate_string($package)
  validate_string($version)

  ### Internal variables (that map class parameters)
  if $ensure == 'present' {
    $package_ensure = $version ? {
      ''      => 'present',
      default => $version,
    }
    $file_ensure = present
  } else {
    $package_ensure = 'absent'
    $file_ensure    = absent
  }

  ### Extra classes
  if $dependency_class { include $dependency_class }
  if $my_class         { include $my_class         }


  package { 'apcupsdweb':
    ensure => $package_ensure,
    name   => $package,
    noop   => $noops,
  }

  # set defaults for file resource in this scope.
  File {
    ensure  => $file_ensure,
    owner   => $file_owner,
    group   => $file_group,
    mode    => $file_mode,
    noop    => $noops,
  }

  file { $file_hosts_conf :
    content => template('apcupsd/hosts.conf.erb'),
  }

}
# vi:syntax=puppet:filetype=puppet:ts=4:et:nowrap:
