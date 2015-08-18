# Packages needed to be installed to compile
# ctags is a virtual package provided by 2 packages, you must explicitly select one to install
default['rippled']['packages'] = %w{g++ git scons exuberant-ctags pkg-config protobuf-compiler libprotobuf-dev libssl-dev python-software-properties libboost1.57-all-dev libcap2-bin}
#  nodejs npm for js tests which are not included
# libcap2-bin is used by the cookbook inself

# repository that is cloned to be compiled
default['rippled']['git_repository'] = 'https://github.com/ripple/rippled.git'
default['rippled']['git_revision'] = '0.29.0'


# User and group
default["rippled"]["user"] = "rippled"
default["rippled"]["group"] = "rippled"

# Paths
default["rippled"]["binary"] = "/usr/bin/rippled"
default["rippled"]["config"] = "/etc/rippled.cfg"

default["rippled"]["rock_db_folder"] = "/var/lib/rippled/db/rocksdb"
default["rippled"]["operational_db_folder"] = "/var/lib/rippled/db"
default["rippled"]["debug_logfile_folder"] = "/var/log/rippled"
