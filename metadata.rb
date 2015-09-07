name 'rippled'
maintainer 'Dmitry Grigorenko'
maintainer_email 'grigorenko.d@gmail.com'
version '0.2.2'
license          'Apache v2.0'
description      'Compiles, installs and configures rippled, a ripple network daemon'
supports         'ubuntu', '>= 14.04'
# causes AWS to fail source_url 'https://github.com/compositor/rippled-cookbook'
depends 'apt'
# causes AWS to fail issues_url 'https://github.com/compositor/rippled-cookbook/issues'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
