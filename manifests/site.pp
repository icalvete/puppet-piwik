define piwik::site (

  $ensure     = 'present',
  $url        = undef,
  $ecommerce  = 0,
  $timezone   = 'Europe/Madrid',
  $currency   = EUR,
  $token_auth = undef,
) {
  include piwik

  if !$token_auth {
    $token_auth_final = $piwik::admin_token_auth
  } else {
    $token_auth_final = $token_auth
  }

  case $ensure {
    'present' : {

      if !$url {
        fail("url param is mandatory.")
      }

      exec { "create_piwik_site_${name}":
        command => "/usr/bin/curl --insecure --header 'Host: ${piwik::url}' 'https://localhost/?module=API&method=SitesManager.addSite&siteName=$name&urls=${url}&ecommerce=${ecommerce}&timezone=${timezone}&currency=${currency}&token_auth=${token_auth_final}'",
        user    => 'root',
        unless  => "/usr/bin/curl --silent --insecure --header 'Host: ${piwik::url}' 'https://localhost/?module=API&method=SitesManager.getAllSites&token_auth=${token_auth_final}&format=json' | /bin/grep ${name}"
      }
    }
    'absent': {

      if !$id {
        fail("id param is mandatory.")
      }

      exec { "create_piwik_site_${name}":
        command => "/usr/bin/curl --insecure --header 'Host: ${piwik::url}' 'https://localhost/?module=API&method=SitesManager.deleteSite&idSite=${id}&token_auth=${token_auth_final}'",
        user    => 'root',
      }
    }
    default: { err ( "Unknown ensure value: '$ensure'" ) }
  }
}
