class piwik::config {

  file {'options_sql_file':
    ensure  => present,
    path    => "${piwik::root_path}/options.sql",
    mode    => '0664',
    content => template("${module_name}/options.sql.erb"),
    require => File['piwik_file_permisions']
  }

  exec {'apply_options_sql_file':
    command  => "/usr/bin/mysql -h ${piwik::db_host} -u${piwik::db_user} -p${piwik::db_pass} ${piwik::db_name} < ${piwik::root_path}/options.sql",
    user     => 'root',
    require  => File['options_sql_file'],
    onlyif   => "/bin/echo \"SELECT count(*) FROM option;\" | /usr/bin/mysql -N -h ${piwik::db_host} -u${piwik::db_user} -p${piwik::db_pass} ${piwik::db_name} | /bin/grep -w 0",
    provider => 'shell'
  }

  file {'users_sql_file':
    ensure  => present,
    path    => "${piwik::root_path}/users.sql",
    mode    => '0664',
    content => template("${module_name}/users.sql.erb"),
    require => File['piwik_file_permisions']
  }

  exec {'apply_users_sql_file':
    command  => "/usr/bin/mysql -h ${piwik::db_host} -u${piwik::db_user} -p${piwik::db_pass} ${piwik::db_name} < ${piwik::root_path}/users.sql",
    user     => 'root',
    require  => File['users_sql_file'],
    unless   => "/bin/echo \"SELECT login FROM user;\" | /usr/bin/mysql -N -h ${piwik::db_host} -u${piwik::db_user} -p${piwik::db_pass} ${piwik::db_name} | /bin/grep -w token",
    provider => 'shell'
  }

  piwik::user {$piwik::admin:
    password => $piwik::admin_password,
    email    => $piwik::admin_email,
    alias    => 'admin',
    admin    => true,
    require  => Exec['apply_schema_sql_file', 'apply_options_sql_file', 'apply_users_sql_file']
  }

  piwik::site {'test':
    url     => 'http://test.org',
    require => Exec['apply_schema_sql_file', 'apply_options_sql_file', 'apply_users_sql_file']
  }

  #
  # DEPRECATED
  #
  # https://support.maxmind.com/geolite-legacy-discontinuation-notice/

/*
  cron{ 'update_piwik_geoip_database':
    command => "/usr/bin/flock /tmp/update_piwik_geoip_database /usr/bin/curl -s http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz | /bin/gunzip > ${piwik::root_path}/piwik/misc/GeoLiteCity.dat",
    user    => 'root',
    hour    => '0',
    minute  => '0',
    weekday => '7'
  }
*/
}
