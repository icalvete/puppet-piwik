class piwik (

  $version               = $piwik::params::version,
  $root_path             = $piwik::params::root_path,
  $repo_scheme           = $piwik::params::repo_scheme,
  $repo_domain           = $piwik::params::repo_domain,
  $repo_port             = $piwik::params::repo_port,
  $repo_user             = $piwik::params::repo_user,
  $repo_pass             = $piwik::params::repo_pass,
  $repo_path             = $piwik::params::repo_path,
  $repo_resource         = regsubst($piwik::params::repo_resource, 'PIWIKVERSION', $version),
  $visit_standard_length = 1800,
  $host                  = 'piwik',
  $domain                = 'vagrant.net',
  $admin                 = undef,
  $admin_password        = undef,
  $admin_email           = undef,
  $admin_token_auth      = undef,
  $db_host               = 'localhost',
  $db_user               = 'root',
  $db_pass               = '',
  $db_name               = 'piwik',
  $ssl_cert              = false,
  $ssl_cert_key          = false,
  $ssl_cert_ca           = false,

) inherits piwik::params {

  $url = "${host}.${domain}"
  $piwik_servername = $url

  if !$admin {
    fail('admin param is mandatory.')
  }

  if !$admin_password {
    fail('admin_password param is mandatory.')
  }

  if !$admin_email {
    fail('admin_email param is mandatory.')
  }

  if !$admin_token_auth {
    fail('admin_token_auth param is mandatory.')
  }

  anchor {'piwik::begin':
    before => Class['piwik::install']
  }
  class {'piwik::install':
    require => Anchor['piwik::begin']
  }
  class {'piwik::config':
    require => Class['piwik::install']
  }
  class {'piwik::service':
    subscribe => Class['piwik::config']
  }
  anchor {'piwik::end':
    require => Class['piwik::service']
  }
}
