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
class gitolite(
  $group           = $gitolite::params::group,
  $user            = $gitolite::params::user,
  $homedir         = $gitolite::params::homedir,
  $source_type     = $gitolite::params::source_type,
  $package_version = present,
  $source_location = $gitolite::params::source_location,
  $key_user        = undef,
  $pubkey          = undef,
) inherits gitolite::params {

  if ($key_user == undef or $pubkey == undef) {
    fail("Must define key_user and pass pubkey")
  }

  group { $group:
    ensure => present,
  }

  user { $user:
    ensure     => present,
    gid        => $group,
    managehome => true,
  }

  file { "${homedir}/bin":
    ensure => directory,
    owner  => $user,
    group  => $group,
    mode   => '0700',
  }

  file { 'admin_key':
    path    => "${homedir}/${key_user}.pub":
    ensure  => file,
    owner   => $user,
    group   => $group,
    mode    => '0700',
    content => $pubkey,
  }

  case $source_type {
    'package': {
      package { 'gitolite':
        ensure    => $package_version,
        source    => $source_location,
        subscribe => File['admin_key'],
        notify    => Exec['install_gitolite'],
      }
    }
    'tarball': {
      staging::file { 'gitolite':
        source    => $source_location,
        subscribe => File['admin_key'],
        notify    => Exec['install_gitolite'],
      }
    }
    'git': {
      vcsrepo { "${homedir}/gitolite":
        ensure    => present,
        provider  => git,
        user      => $user,
        source    => $source_location,
        subscribe => File['admin_key'],
        notify    => Exec['install_gitolite'],
      }
    }
    default: { fail("source_type ${source_type} is undefined. Must be one of package, tarball, git.") }
  }

  exec { 'install_gitolite':
    command     => "${homedir}/gitolite install -ln"
    user        => $user,
    refreshonly => true,
    notify      => Exec['setup_gitolite']
  }

  exec { 'setup_gitolite':
    command     => "${homedir}/bin/gitolite setup -pk ${homedir}/${key_user}.pub",
    user        => $user,
    refreshonly => true,
  }
}
