class gitolite::params {
  $group_name      = 'git'
  $user_name       = 'git'
  $group_ensure    = true
  $user_ensure     = true
  $home_path       = "/home/${user_name}"
  $source_type     = 'git'
  $package_version = present
  $source_path     = 'git://github.com/sitaramc/gitolite'
  $key_user        = undef
  $pubkey          = undef
  $manage_perl     = false

  case $::osfamily {
    'redhat': {
      case $::operatingsystemmajrelease {
        '5': { $perl_package = 'perl-Time-modules' }
        '6': { $perl_package = 'perl-Time-HiRes' }
        default: { $perl_package = undef }
      }
    }
    'debian': { $perl_package = 'libtime-hires-perl' }
    default:  { $perl_package = undef }
  }
}
