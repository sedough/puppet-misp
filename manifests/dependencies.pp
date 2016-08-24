
class misp::dependencies inherits misp {

  ensure_packages( [	'gcc', # Needed for compiling Python modules
    'git', # Needed for pulling the MISP code and those for some dependencies
    'zip', 'redis', 'mariadb', #'httpd',# already defined by apache module
    'python-devel', 'python-pip', 'python-lxml', 'python-dateutil', 'python-six', 'python-lxml', 'python-dateutil', 'python-six', # Python related packages
    'libxslt-devel', 'zlib-devel',
    'rh-php56', 'rh-php56-php-fpm', 'rh-php56-php-devel', 'rh-php56-php-mysqlnd', 'rh-php56-php-mbstring', 'php-pecl-redis', 'php-pear',# PHP related packages
    'php-mbstring', #Required for Crypt_GPG
    'haveged',
    'mod_ssl', #Required for ssl connection
  ],
    { 'ensure' => 'present' }
  )

  exec { "pear update-channels pear.php.net" :
    command => "/usr/bin/pear update-channels pear.php.net",
    require => [Package['php-pear']]
  }

  exec {"pear install Crypt_GPG":
    command => "/usr/bin/pear install Crypt_GPG",
    creates => '/usr/bin/Crypt_GPG',
    unless => '/usr/bin/pear list | grep Crypt_GPG',
    require => Exec['pear update-channels pear.php.net']
  }

  exec {"pip install importlib":
    command => "/usr/bin/pip install importlib",
    unless => "/usr/bin/pip list | grep importlib",
  }

  service { 'rh-php56-php-fpm':
    enable => true,
    ensure => 'running',
    subscribe => File['/etc/opt/rh/rh-php56/php.d/99-redis.ini'], #Needs the subscribe, cannot notify a service
  }

  service { 'haveged':
    enable => true,
    ensure => 'running',
  }

  service { 'redis':
    enable => true,
    ensure => 'running',
  }
}