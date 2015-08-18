# rippled

This cookbook compiles and installs a [Ripple](https://ripple.com) node (version 0.29.0). At the time of writing Ripple Labs does not provide a precompiled package for the most recent release, therefore the only installation method available is via sources.

The cookbook generally follows instructions published at (https://wiki.ripple.com/Ubuntu_build_instructions) with the following improvements:
- allow to bind on privileged ports
- use upstart for the daemon

## Supported Platforms
- Ubuntu 14.04

## Attributes
These attributes control pathes in the ripple configuration file.
- `["rippled"]["rock_db_folder"]` Path to RockDB. Default: `/var/lib/rippled/db/rocksdb`
- `["rippled"]["operational_db_folder"]` Sets `[database_path]` parameter. Default: `/var/lib/rippled/db`
- `["rippled"]["debug_logfile_folder"]` A folder for `debug.log`. Default: `/var/log/rippled`

## Known issues
- You need at least 16G memory to compile rippled. It memory is insufficient, g++ fails with an internal error.
- Only a few basic parameters are supported for the configuration. Contributors are welcome.


