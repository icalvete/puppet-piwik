define piwik::user (

  $ensure     = 'present',
  $password   = undef,
  $email      = 0,
  $user_alias = '',
  $admin      = false
) {
  include piwik

  if !$token_auth {
    $token_auth_final = $piwik::admin_token_auth
  } else {
    $token_auth_final = $token_auth
  }

  case $ensure {
    'present' : {
   
      if !$password {
        fail("password param is mandatory.")
      }

      exec { "create_piwik_user_${name}":
        command => "/usr/bin/curl --silent --insecure --header 'Host: ${piwik::url}' 'https://localhost/?module=API&method=UsersManager.addUser&userLogin=${name}&password=${password}&email=${email}&alias=${user_alias}&token_auth=${token_auth_final}'",
        user    => 'root',
        unless  => "/usr/bin/curl --silent --insecure --header 'Host: ${piwik::url}' 'https://localhost/?module=API&method=UsersManager.userExists&userLogin=${name}&token_auth=${token_auth_final}&format=json' | /bin/grep true"
      }

      exec { "set_admin_piwik_user_${name}":
        command => "/usr/bin/curl --silent --insecure --header 'Host: ${piwik::url}' 'https://localhost/?module=API&method=UsersManager.setSuperUserAccess&userLogin=${name}&hasSuperUserAccess=${admin}&token_auth=${token_auth_final}'",
        user    => 'root',
        require => Exec["create_piwik_user_${name}"]
      }
    }
    'absent': {
      exec { "delete_piwik_user_${name}":
        command => "/usr/bin/curl --silent --insecure --header 'Host: ${piwik::url}' 'https://localhost/?module=API&method=UsersManager.deleteUser&userLogin=${name}&token_auth=${token_auth_final}'",
        user    => 'root',
      }
    }
    default: { err ( "Unknown ensure value: '$ensure'" ) }
  }
}
