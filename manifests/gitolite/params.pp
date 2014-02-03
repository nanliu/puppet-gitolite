class gitolite::params {
  $group           = 'git'
  $user            = 'git'
  $homedir         = "/home/${user}"
  $source_type     = 'git'
  $source_location = 'git://github.com/sitaramc/gitolite'

  case $::osfamily {
    'redhat': { $perl_package = 'perl-Time-HiRes' }
    default:  { fail("Perl package is undefined for ${operatingsystem}") }
  }
}
