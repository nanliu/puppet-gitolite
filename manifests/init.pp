# == Class: gitolite
#
# Full description of class gitolite here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { gitolite:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2014 Your name here, unless otherwise noted.
#
# NOTE: RIGHT NOW REQUIRES GIT AND PERL-TIME-HIRES
class gitolite(
  $group           = $gitolite::params::group,
  $user            = $gitolite::params::user,
  $manage_group    = true,
  $manage_user     = true,
  $homedir         = $gitolite::params::homedir,
  $source_type     = $gitolite::params::source_type,
  $package_version = present,
  $source_location = $gitolite::params::source_location,
  $key_user        = undef,
  $pubkey          = undef,
  $manage_perl     = false,
) inherits gitolite::params {

  if ($key_user == undef or $pubkey == undef) {
    fail("Must define key_user and pass pubkey")
  }

  if $manage_perl == 'package' {
    package { $gitolite::params::perl_package:
      ensure => installed,
    }
  }

  if $manage_group == true {
    group { $group:
      ensure => present,
    }
  }

  if $manage_user == true {
    user { $user:
      ensure     => present,
      gid        => $group,
      managehome => true,
    }
  }

  file { "${homedir}":
    ensure => directory,
    owner => $user,
    group => $group,
    mode => '0750',
  } ->

  file { "${homedir}/bin":
    ensure => directory,
    owner  => $user,
    group  => $group,
    mode   => '0750',
    recurse => true,
  } ->

  file { "${homedir}/repositories":
    ensure => directory,
    owner  => $user,
    group  => $group,
    mode   => '0750',
    recurse => true,
  }

  file { 'admin_key':
    path    => "${homedir}/${key_user}.pub",
    ensure  => file,
    owner   => $user,
    group   => $group,
    mode    => '0750',
    content => $pubkey,
  }

  case $source_type {
    'package': {
      package { 'gitolite':
        ensure    => $package_version,
        source    => $source_location,
        notify    => Exec['install_gitolite'],
      }
    }
    'tarball': {
      staging::file { 'gitolite':
        source    => $source_location,
        notify    => Exec['install_gitolite'],
      }
    }
    'git': {
      vcsrepo { "${homedir}/gitolite":
        ensure    => present,
        provider  => git,
        user      => $user,
        source    => $source_location,
        notify    => Exec['install_gitolite'],
      }
    }
    default: { fail("source_type ${source_type} is undefined. Must be one of package, tarball, git.") }
  }

  exec { 'install_gitolite':
    command     => "${homedir}/gitolite/install -ln ${homedir}/bin",
    user        => $user,
    refreshonly => true,
    notify      => Exec['setup_gitolite'],
    require     => [File["${homedir}/bin"], File['admin_key']],
    before      => File["${homedir}/repositories"],
  }

  exec { 'setup_gitolite':
    command     => "${homedir}/bin/gitolite setup -pk ${homedir}/${key_user}.pub",
    user        => $user,
    environment => "HOME=${homedir}",
    refreshonly => true,
    require => File["${homedir}/bin"],
    before  => File["${homedir}/repositories"],
  }

}
