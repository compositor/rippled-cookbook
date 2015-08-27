############################### How to build ###########################

# Packages needed to be installed to compile. This is for convenience and is not meant to be overwritten
default['rippled']['packages'] = %w{g++ git scons exuberant-ctags pkg-config protobuf-compiler libprotobuf-dev libssl-dev python-software-properties libboost1.57-all-dev nodejs libcap2-bin}
# ctags is a virtual package provided by 2 packages, you must explicitly select one to install
# nodejs is for js tests
# libcap2-bin is used by the cookbook inself

# repository that is cloned to be compiled
default['rippled']['git_repository'] = 'https://github.com/ripple/rippled.git'
default['rippled']['git_revision'] = '0.29.0'
default['rippled']['run_tests'] = 'true'

############################### Daemon ###########################
default["rippled"]["service_name"] = "rippled"

# User and group
default["rippled"]["user"] = "rippled"
default["rippled"]["group"] = "rippled"

# Paths
default["rippled"]["pid_path"] = "/var/run/rippled.pid"
default["rippled"]["binary_path"] = "/usr/bin/rippled"
default["rippled"]["config_path"] = "/etc/rippled/rippled.cfg"

# Do not add --conf or --fg here, neigher add parameters that will cause the deamon to exit (like --help)
# TODO: support array here
default['rippled']['cmd_params'] = "--net"
###################################### Mere copy of rippled-example.cfg #################################

default["rippled"]["config"]["server"] = ["port_rpc_admin_local", "port_peer", "port_ws_admin_local"]
# "port_ws_public", "ssl_key = /etc/ssl/private/server.key", "ssl_cert = /etc/ssl/certs/server.crt"

default["rippled"]["config"]["port_rpc_admin_local"] = {
	"port" => "5005",
	"ip" => "127.0.0.1",
	"admin" => "127.0.0.1",
	"protocol" => "http"
}

default["rippled"]["config"]["port_peer"] = {
	"port" => "51235",
	"ip" => "0.0.0.0",
	"protocol" => "peer"
}

default["rippled"]["config"]["port_ws_admin_local"] = {
	"port" => "6006",
	"ip" => "127.0.0.1",
	"admin" => "127.0.0.1",
	"protocol" => "ws"
}

default["rippled"]["config"]["node_size"] = "medium"

default["rippled"]["config"]["node_db"] = {
	"type" => "RocksDB",
	"path" => "/var/lib/rippled/db/rocksdb",
	"open_files" => "2000",
	"filter_bits" => "12",
	"cache_mb" => "256",
	"file_size_mb" => "8",
	"file_size_mult" => "2",
	"online_delete" => "2000",
	"advisory_delete" => "0"
}

default["rippled"]["config"]["database_path"] = "/var/lib/rippled/db"

default["rippled"]["config"]["debug_logfile"] = "/var/log/rippled/debug.log"

default["rippled"]["config"]["sntp_servers"] = ["time.windows.com", "time.apple.com", "time.nist.gov", "pool.ntp.org"]

# currently only a single value but logically it's an array
default["rippled"]["config"]["ips"] = ["r.ripple.com 51235"]

default["rippled"]["config"]["validators"] = [
	"n949f75evCHwgyP4fPVgaHqNHxUVN15PsJEZ3B3HnXPcPjcZAoy7    RL1",
	"n9MD5h24qrQqiyBC8aeqqCWvpiBiYQ3jxSr91uiDvmrkyHRdYLUj    RL2",
	"n9L81uNCaPgtUJfaHh89gmdvXKAmSt5Gdsw2g1iPWaPkAHW5Nm4C    RL3",
	"n9KiYM9CgngLvtRCQHZwgC2gjpdaZcCcbt3VboxiNFcKuwFVujzS    RL4",
	"n9LdgEtkmGB9E2h3K4Vp7iGUaKuq23Zr32ehxiU8FWY7xoxbWTSA    RL5"
]

default["rippled"]["config"]["validation_quorum"] = "3"

default["rippled"]["config"]["rpc_startup"] = '{ "command": "log_level", "severity": "warning" }'

default["rippled"]["config"]["ssl_verify"] = "1"

################################# End of the mere copy ########################################



################################# Customization ###############################################
default["rippled"]["config"]["node_db"] = nil #["path"] = "/var/lib/rippled/db/rocksdb2"
default["rippled"]["config"]["database_path"] = "/var/lib/rippled/db2"
default["rippled"]["rippled"]["config"]["debug_logfile"] = "/var/log/rippled2"
