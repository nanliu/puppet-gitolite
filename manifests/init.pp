# == Class: gitolite
#
# Manages gitolite v3
#
# === Parameters
#
# [*group_name*]
#   Group owner of the git directories. Defaults to 'git.' This group will be
#   created if $group_ensure is set to 'true.'
# [*user_name*]
#   Owner of the git directories. Defaults to 'git.' This user will be created
#   if $user_ensure is set to 'true.'
# [*group_ensure*]
#   If set to 'true,' the group specified in group_name will be set to
#   ensure => present.
# [*user_ensure*]
#   If set to 'true,' the user specified in user_name will be set to
#   ensure => present.
# [*home_path*]
#   Home directory for the user_name user.
# [*source_type*]
#   Must be one of 'package,' 'tarball' or 'git.' Defaults to 'git.'
# [*package_version*]
#   If source_type is set to 'package,' package_version will be passed as the
#   value for ensure. Defaults to 'present.'
# [*source_path*]
#   The location at which the gitolite tarball, package or git repository is
#   located. In the case of a git repository, the URL must be of the formats
#   accepted by the puppetlabs-vcsrepo type. Defaults to
#   'git://github.com/sitaramc/gitolite'
# [*key_user*]
#   The username corresponding to the key passed in pubkey. If this value
#   changes, the gitolite install and setup commands will be executed.
#   *required*
# [*pubkey*]
#   Public key for the user passed in key_user. If this key changes, the
#   gitolite install and setup commands will be executed.
#   *required*
# [*manage_perl*]
#   If this is set to true, the Perl package for Time::HiRes will be installed
#   if necessary. Defaults to 'false.'
#
# === Examples
#
#  class { gitolite:
#    user_name = 'git_alpha',
#    source_type = 'package',
#    package_version = '1.2',
#    source_path = 'http://myserver.com/gitolite.rpm',
#    key_user = 'ted',
#    pubkey = 'ssh-rss AAAAA.....'
#  }
#
# === Authors
#
# Eric Shamow <eric@puppetlabs.com>
#
# === Copyright
#
# Copyright 2014 Puppet Labs
#
class gitolite(
  $group_name      = $gitolite::params::group_name,
  $user_name       = $gitolite::params::user_name,
  $group_ensure    = $gitolite::params::group_ensure,
  $user_ensure     = $gitolite::params::user_ensure,
  $home_path       = $gitolite::params::home_path,
  $source_type     = $gitolite::params::source_type,
  $package_version = $gitolite::params::package_version,
  $source_path     = $gitolite::params::source_path,
  $key_user        = $gitolite::params::key_user,
  $pubkey          = $gitolite::params::pubkey,
  $manage_perl     = $gitolite::params::manage_perl
) inherits gitolite::params {

  if ($key_user == undef or $pubkey == undef) {
    fail('Must define key_user and pass pubkey')
  }

  if ($manage_perl == true and member(['redhat'], $::osfamily) == false) {
    fail("Perl package is undefined for osfamily ${::osfamily}.")
  }

  if $manage_perl == 'package' {
    package { $gitolite::params::perl_package:
      ensure => installed,
    }
  }

  if $group_ensure == true {
    group { $group_name:
      ensure => present,
    }
  }

  if $user_ensure == true {
    user { $user_name:
      ensure     => present,
      gid        => $group_name,
      managehome => true,
    }
  }

  file { $home_path:
    ensure => directory,
    owner  => $user_name,
    group  => $group_name,
    mode   => '0750',
  } ->

  file { "${home_path}/bin":
    ensure  => directory,
    owner   => $user_name,
    group   => $group_name,
    mode    => '0750',
    recurse => true,
  } ->

  file { "${home_path}/repositories":
    ensure  => directory,
    owner   => $user_name,
    group   => $group_name,
    mode    => '0750',
    recurse => true,
  }

  file { 'admin_key':
    ensure  => file,
    path    => "${home_path}/${key_user}.pub",
    owner   => $user_name,
    group   => $group_name,
    mode    => '0750',
    content => $pubkey,
  }

  case $source_type {
    'package': {
      package { 'gitolite':
        ensure    => $package_version,
        source    => $source_path,
        notify    => Exec['install_gitolite'],
      }
    }
    'tarball': {
      staging::file { 'gitolite':
        source    => $source_path,
        notify    => Exec['install_gitolite'],
      }
    }
    'git': {
      vcsrepo { "${home_path}/gitolite":
        ensure    => present,
        provider  => git,
        user      => $user_name,
        source    => $source_path,
        notify    => Exec['install_gitolite'],
      }
    }
    default: { fail("source_type ${source_type} is undefined. Must be one of package, tarball, git.") }
  }

  exec { 'install_gitolite':
    command     => "${home_path}/gitolite/install -ln ${home_path}/bin",
    user        => $user_name,
    refreshonly => true,
    notify      => Exec['setup_gitolite'],
    subscribe   => [File["${home_path}/bin"], File['admin_key']],
    before      => File["${home_path}/repositories"],
  }

  exec { 'setup_gitolite':
    command     => "${home_path}/bin/gitolite setup -pk ${home_path}/${key_user}.pub",
    user        => $user_name,
    environment => "HOME=${home_path}",
    refreshonly => true,
    require     => File["${home_path}/bin"],
    before      => File["${home_path}/repositories"],
  }
}
