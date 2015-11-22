#
# = Class: apcupsd
#
# This class manages APC UPS daemon
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
# [*service*]
#   Type: string
#   Name of the service. Defaults are provided on $::osfamily basis.
#
# [*status*]
#   Type: string, default: 'enabled'
#   Define the provided service status. Available values affect both the
#   ensure and the enable service arguments:
#   * 'enabled':     ensure => running, enable => true
#   * 'disabled':    ensure => stopped, enable => false
#   * 'running':     ensure => running, enable => undef
#   * 'stopped':     ensure => stopped, enable => undef
#   * 'activated':   ensure => undef  , enable => true
#   * 'deactivated': ensure => undef  , enable => false
#   * 'unmanaged':   ensure => undef  , enable => undef
#
# [*file_mode*]
# [*file_owner*]
# [*file_group*]
#   Type: string, default: '0600'
#   Type: string, default: 'root'
#   Type: string, default 'root'
#   File permissions and ownership information assigned to config files.
#
# [*file_apcupsd_conf*]
#   Type: string, default on $::osfamily basis
#   Path to apcuspd.conf.
#
# [*my_class*]
#   Type: string, default: undef
#   Name of a custom class to autoload to manage module's customizations
#
# [*noops*]
#   Type: boolean, default: undef
#   Set noop metaparameter to true for all the resources managed by the module.
#   If true no real change is done is done by the module on the system.
#
# [*upscable*]
#   Type: string, default: usb
#   Defines the type of cable connecting the UPS to your computer. Possible
#   generic choices for <cable> are: simple, smart, ether, usb. Specific cable
#   model number may be used also.
#
# [*upstype*]
#   Type: string, default: usb
#   Corresponds to the type of UPS you have.
#
# [*device*]
#   Type: string, default: blank
#   Sometimes referred to as a port. For USB UPSes, please leave the param blank.
#   For other UPS types, you must specify an appropriate port or address.
#
# [*batterylevel*]
#   Type: integer, default: 20
#   Initiate a shutdown if a battery level drops below this value.
#
# [*minutes*]
#   Type: integer, default: 5
#   Initiate a shutdown if the remaining runtime in minutes (as calculated internally
#   by the UPS) is below or equal this value.
#
# [*upsmode*]
#   Type: string, default: 'disable'
#   Normally disable unless you share an UPS using an APC ShareUPS card.
#
class apcupsd (
  $ensure            = $::apcupsd::params::ensure,
  $package           = $::apcupsd::params::package,
  $version           = $::apcupsd::params::version,
  $service           = $::apcupsd::params::service,
  $status            = $::apcupsd::params::status,
  $file_mode         = $::apcupsd::params::file_mode,
  $file_owner        = $::apcupsd::params::file_owner,
  $file_group        = $::apcupsd::params::file_group,
  $file_apcupsd_conf = $::apcupsd::params::file_apcupsd_conf,
  $dependency_class  = $::apcupsd::params::dependency_class,
  $my_class          = $::apcupsd::params::my_class,
  $noops             = undef,
  $upscable          = 'usb',
  $upstype           = 'usb',
  $device            = '',
  $batterylevel      = '20',
  $minutes           = '5',
  $upsmode           = 'disable',
) inherits apcupsd::params {

  ### Input parameters validation
  validate_re($ensure, ['present','absent'], 'Valid values are: present, absent')
  validate_string($package)
  validate_string($version)
  validate_string($service)
  validate_re($status,  ['enabled','disabled','running','stopped','activated','deactivated','unmanaged'], 'Valid values are: enabled, disabled, running, stopped, activated, deactivated and unmanaged')
  validate_re($upsmode, ['disable','share'], 'Valid values are: disable and share')

  ### Internal variables (that map class parameters)
  if $ensure == 'present' {
    $package_ensure = $version ? {
      ''      => 'present',
      default => $version,
    }
    $service_enable = $status ? {
      'enabled'     => true,
      'disabled'    => false,
      'running'     => undef,
      'stopped'     => undef,
      'activated'   => true,
      'deactivated' => false,
      'unmanaged'   => undef,
    }
    $service_ensure = $status ? {
      'enabled'     => 'running',
      'disabled'    => 'stopped',
      'running'     => 'running',
      'stopped'     => 'stopped',
      'activated'   => undef,
      'deactivated' => undef,
      'unmanaged'   => undef,
    }
    $file_ensure = present
  } else {
    $package_ensure = 'absent'
    $service_enable = undef
    $service_ensure = stopped
    $file_ensure    = absent
  }

  ### Extra classes
  if $dependency_class { include $dependency_class }
  if $my_class         { include $my_class         }


  package { 'apcupsd':
    ensure => $package_ensure,
    name   => $package,
    noop   => $noops,
  }

  service { 'apcupsd':
    ensure  => $service_ensure,
    name    => $service,
    enable  => $service_enable,
    require => Package['apcupsd'],
    noop    => $noops,
  }

  # set defaults for file resource in this scope.
  File {
    ensure  => $file_ensure,
    owner   => $file_owner,
    group   => $file_group,
    mode    => $file_mode,
    notify  => Service['apcupsd'],
    noop    => $noops,
  }

  file { $file_apcupsd_conf :
    content => template('apcupsd/apcupsd.conf.erb'),
  }

}
# vi:syntax=puppet:filetype=puppet:ts=4:et:nowrap:
