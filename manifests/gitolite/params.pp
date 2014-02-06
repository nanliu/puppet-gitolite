class gitolite::params {
  $group_name      = 'git'
  $user_name       = 'git'
  $group_ensure    = true
  $user_ensure     = true
  $home_path       = "/home/${user}"
  $source_type     = 'git'
  $package_version = present
  $source_path     = 'git://github.com/sitaramc/gitolite'
  $key_user        = undef
  $pubkey          = undef
  $manage_perl     = false

  case $::osfamily {
    'redhat': { $perl_package = 'perl-Time-HiRes' }
    default:  { $perl_package = undef }
  }
}
