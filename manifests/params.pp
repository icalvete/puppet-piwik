class piwik::params {

  case $::operatingsystem {
    /^(Debian|Ubuntu)$/: {
    }
    default: {
      fail ("${::operatingsystem} not supported.")
    }
  }

  $version               = '3.2.0'
  $root_path             = '/opt'
  $repo_scheme           = 'http'
  $repo_domain           = 'builds.piwik.org'
  $repo_port             = false
  $repo_user             = false
  $repo_pass             = false
  $repo_path             = ''
  $repo_resource         = 'piwik-PIWIKVERSION.tar.gz'
}
