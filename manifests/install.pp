class piwik::install {

  $source       = "${piwik::repo_scheme}://${piwik::repo_domain}/${piwik::repo_path}/${piwik::repo_resource}"

  wget::fetch {'piwik_get_package':
    source      => $source,
    user        => $piwik::repo_user,
    password    => $piwik::repo_pass,
    destination => "/tmp/${piwik::repo_resource}",
    timeout     => 0,
    verbose     => false,
  }

  exec {'piwik_install_package':
    cwd     => $piwik::root_path,
    command => "/bin/tar xvfz /tmp/${piwik::repo_resource}",
    require => Wget::Fetch['piwik_get_package'],
    unless  => "/usr/bin/test -d ${piwik::root_path}/piwik",
  }

  file {'piwik_file_permisions':
    ensure  => directory,
    path    => "${piwik::root_path}/piwik",
    owner   => 'www-data',
    group   => 'www-data',
    recurse => true,
    require => Exec['piwik_install_package']
  }

  $piwik_servername = $piwik::url
  apache2::site{'piwik.vhost.conf':
    source  => "${module_name}/piwik.vhost.conf.erb",
    require => Class['roles::apache2_server']
  }

  file {'piwik_config_file':
    ensure  => present,
    path    => "${piwik::root_path}/piwik/config/config.ini.php",
    mode    => '0664',
    owner   => 'www-data',
    group   => 'www-data',
    content => template("${module_name}/config.ini.php.erb"),
    require => File['piwik_file_permisions'],
    backup  => true
  }

  file {'schema_sql_file':
    ensure  => present,
    path    => "${piwik::root_path}/schema.sql",
    mode    => '0664',
    content => template("${module_name}/schema.sql.erb"),
    require => File['piwik_file_permisions']
  }

  exec {'apply_schema_sql_file':
    command  => "/usr/bin/mysql -h ${piwik::db_host} -u${piwik::db_user} -p${piwik::db_pass} ${piwik::db_name} < ${piwik::root_path}/schema.sql",
    user     => 'root',
    require  => File['schema_sql_file'],
    unless   => "/bin/echo \"SHOW TABLES FROM ${piwik::db_name} LIKE 'user%';\" | /usr/bin/mysql -N -h ${piwik::db_host} -u${piwik::db_user} -p${piwik::db_pass} ${piwik::db_name} | wc -l | /bin/grep -w 5",
    provider => 'shell'
  }
}

