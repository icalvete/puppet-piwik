define piwik::archive (

  $hour   = '*',
  $minute = 5,
  $user   = 'www-data'

) {

  cron{ "${name}_piwik_archive_cron":
    command => "/usr/bin/php /opt/piwik/console core:archive",
    user    => $user,
    hour    => $hour,
    minute  => $minute,
  }
}
