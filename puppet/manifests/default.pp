# http://www.puppetcookbook.com/
$ar_databases = ['activerecord_unittest', 'activerecord_unittest2']
$as_vagrant   = 'sudo -u vagrant -H bash -l -c'
$home         = '/home/vagrant'

Exec {
  path => ['/usr/sbin', '/usr/bin', '/sbin', '/bin']
}

# --- Preinstall Stage ---------------------------------------------------------

stage { 'preinstall':
  before => Stage['main']
}

class apt_get_update {
  exec { 'apt-get -y update':
    unless => "test -e ${home}/.rvm"
  }
}
class { 'apt_get_update':
  stage => preinstall
}

# --- SQLite -------------------------------------------------------------------

package { ['sqlite3', 'libsqlite3-dev']:
  ensure => installed;
}

# --- MySQL --------------------------------------------------------------------

# class install_mysql {
#   class { 'mysql': }

#   class { 'mysql::server':
#     config_hash => { 'root_password' => '' }
#   }

#   database { $ar_databases:
#     ensure  => present,
#     charset => 'utf8',
#     require => Class['mysql::server']
#   }

#   database_user { 'rails@localhost':
#     ensure  => present,
#     require => Class['mysql::server']
#   }

#   database_grant { ['rails@localhost/activerecord_unittest', 'rails@localhost/activerecord_unittest2']:
#     privileges => ['all'],
#     require    => Database_user['rails@localhost']
#   }

#   package { 'libmysqlclient15-dev':
#     ensure => installed
#   }
# }
# class { 'install_mysql': }

# --- PostgreSQL ---------------------------------------------------------------
# Intruction https://github.com/mrhieu/puppet-postgresql

class install_postgres {
  class { 'postgresql': }

  class { 'postgresql::server': }

  pg_database { $ar_databases:
    ensure   => present,
    encoding => 'UTF8',
    require  => Class['postgresql::server']
  }

  # pg_user { 'rails':
  #   ensure  => present,
  #   require => Class['postgresql::server']
  # }

  pg_user { 'ltt':
    ensure    => present,
    password  => '123456',
    superuser => true,
    require   => Class['postgresql::server']
  }

  package { 'libpq-dev':
    ensure => installed
  }

  package { 'postgresql-contrib':
    ensure  => installed,
    require => Class['postgresql::server'],
  }
}
class { 'install_postgres': }

# --- Memcached ----------------------------------------------------------------

class { 'memcached': }

# --- Packages -----------------------------------------------------------------

package { 'curl':
  ensure => installed
}

package { 'build-essential':
  ensure => installed
}

package { 'git-core':
  ensure => installed
}

# Nokogiri dependencies.
package { ['libxml2', 'libxml2-dev', 'libxslt1-dev']:
  ensure => installed
}

# ExecJS runtime.
package { 'nodejs':
  ensure => installed
}

# For Capybara-webkit Rails gem
package { ['libqt4-dev', 'libqtwebkit-dev']:
  ensure => installed
}

# For Image Magik
package { 'libmagickwand-dev':
  ensure => installed
}

# For Redis server
package { 'redis-server':
  ensure => installed
}

# --- Elasticsearch ------------------------------------------------------------

# # https://gist.github.com/wingdspur/2026107
# package { 'openjdk-7-jre-headless':
#   ensure => installed
# }
# exec { 'download_elasticsearch':
#   command => "${as_vagrant} 'wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-0.90.7.deb'",
#   creates => "${home}/elasticsearch-0.90.7.deb",# Only download if not exist
#   require => Package['openjdk-7-jre-headless']
# }
# exec { 'install_elasticsearch':
#   command => "sudo dpkg -i ${home}/elasticsearch-0.90.7.deb",
#   require => Exec['download_elasticsearch']
#   # onlyif => "test -d ${home}/elasticsearch-0.90.7.deb"
# }

# --- Ruby ---------------------------------------------------------------------

exec { 'install_rvm':
  command => "${as_vagrant} 'curl -L https://get.rvm.io | bash -s stable'",
  creates => "${home}/.rvm/bin/rvm",
  require => Package['curl']
}

exec { 'install_ruby':
  # We run the rvm executable directly because the shell function assumes an
  # interactive environment, in particular to display messages or ask questions.
  # The rvm executable is more suitable for automated installs.
  #
  # Thanks to @mpapis for this tip.
  command => "${as_vagrant} '${home}/.rvm/bin/rvm install 1.9.3 --latest-binary --autolibs=enabled && rvm --fuzzy alias create default 1.9.3'",
  creates => "${home}/.rvm/bin/ruby",
  require => Exec['install_rvm']
}

# exec { 'install_bundler':
#   command => "${as_vagrant} 'gem install bundler --no-rdoc --no-ri'",
#   # creates => "${home}/.rvm/bin/bundle",
#   require => Exec['install_ruby']
# }

exec { 'install_rails':
  command => "${as_vagrant} 'gem install rails -v 3.2.11'",
  require => Exec['install_ruby']
}

# --- Before bundles installed -------------------------------------------------

# bundle update debugger