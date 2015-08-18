name 'rippled'
maintainer 'Dmitry Grigorenko'
maintainer_email 'grigorenko.d@gmail.com'
version '0.1.0'
license          'Apache v2.0'
description      'Compiles, installs and configures rippled, a ripple network daemon'
supports         'ubuntu', '>= 14.04'
source_url 'https://github.com/compositor/rippled-cookbook'
depends 'apt'
issues_url 'https://github.com/compositor/rippled-cookbook/issues'
long_description IO.read(File.join
  (File.dirname(__FILE__), 'README.md')
) 