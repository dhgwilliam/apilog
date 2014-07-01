class rethink::repo {
  yumrepo { 'rethinkdb':
    baseurl  => 'http://download.rethinkdb.com/centos/6/x86_64/',
    descr    => 'RethinkDB',
    enabled  => '1',
    gpgcheck => '0',
  }
}

stage { 'yumrepo': before => Stage['main'], }
class { 'rethink::repo': stage => 'yumrepo', }

rbenv::install { 'root':
  home => '/root',
}

rbenv::compile { 'root/ruby2.1.1':
  user   => 'root',
  home   => '/root',
  ruby   => '2.1.1',
  global => true,
}

package { 'rethinkdb':
  ensure => latest,
}

Exec {
  cwd     => '/vagrant',
  path    => '/root/.rbenv/shims:/root/.rbenv/bin:/sbin:/bin:/usr/sbin:/usr/bin',
}

exec { 'rethinkdb':
  command => 'rethinkdb --bind all 2>&1 > /dev/null &',
  unless  => 'pgrep rethinkdb',
  require => Package['rethinkdb'],
}

rbenv::gem { 'bundle':
  user => 'root',
  ruby => '2.1.1',
  home => '/root',
}

exec { 'bundle install':
  unless  => 'bundle check',
  require => [ Rbenv::Compile['root/ruby2.1.1'], Rbenv::Gem['bundle'] ],
}

exec { 'bundle exec shotgun -Ilib -p 4567 -o 0.0.0.0 2>&1 >> /vagrant/tmp/shotgun.log &':
  unless  => 'pgrep shotgun',
  require => [ Exec['bundle install'], Exec['rethinkdb'] ],
}


