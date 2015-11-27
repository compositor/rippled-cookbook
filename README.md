# Rippled Cookbook

## Overview

This cookbook compiles and installs a [Ripple](https://ripple.com) node (version 0.30.0-hf1). At the time of writing Ripple Labs does not provide a precompiled package for the most recent release, therefore the only installation method available is via sources.

The cookbook generally follows instructions published at [here](https://wiki.ripple.com/Ubuntu_build_instructions) with the following improvements:
- allow to bind on privileged ports
- customized `init.d` script based on one from Ripple Labs provided ubuntu package

## Attributes

Please refer to rippled example configuration in sources for the full list of settings [souces](https://github.com/ripple/rippled/blob/master/doc/rippled-example.cfg).

All attributes within `node["rippled"]["config"]` will be converted to the content of `rippled.cfg`. A `key` from `node["rippled"]["config"][key]` becomes a section. A corresponding value might be a string (converts to a single string in the section), an array (each element goes as a string in the section), a map (converts to a list of key=value strings), `nil` (to suppress default attributes, the section is not created then). It is clear from examples:

An array

    node["rippled"]["config"]["server"] = ["port_rpc_admin_local", "port_peer", "port_ws_admin_local"]

becomes a section (mind `server` -> `[server]` transformation done by the recipe)

    [server]
    port_rpc_admin_local
    port_peer
    port_ws_admin_local

A single value

    node["rippled"]["config"]["node_size"] = "medium"

becomes a section

    [node_size]
    medium

A map

    node["rippled"]["config"]["port_peer"] = {
        "port" => "51235",
            "ip" => "0.0.0.0",
            "protocol" => "peer"
    }

becomes a section

    [port_peer]
    port=51235
    ip=0.0.0.0
    protocol=peer

A `nil`

    node["rippled"]["config"]["port_ws_admin_local"] = nil

removes `port_ws_admin_local` section

Generally speaking, sections of `rippled.cfg` contain lines with either values or key-value pairs. The only mix is `[server]` and putting a key-value there is syntax sugar and thus can be easily avoided. If you still need a mix, you can use the following construction

    default["rippled"]["config"]["server"] = ["port_rpc_admin_local", "#port_ws_public", "ssl_key = /etc/ssl/private/server.key", "ssl_cert = /etc/ssl/certs/server.crt"]

The default attributes merely repeat default rippled configuration from [souces](https://github.com/ripple/rippled/blob/master/doc/rippled-example.cfg). For better version tracking a copy of this example used to derive the attributes is saved in this cookbook at materials/rippled-example.cfg

If the following paths are specified (explicitly or with default values), the recipe will create corresponding folders for under `node['rippled']['user']` ownership:

* `["rippled"]["config"]["node_db"]["path"]`
* `["rippled"]["config"]["database_path"]`
* `["rippled"]["rippled"]["config"]["debug_logfile"]`

All other attributes are listed below.


| **Attribute**                       | **Description**                                         | **Default**                                    |
|:------------------------------------|:--------------------------------------------------------|:-----------------------------------------------|
| `node['rippled']['git_repository']` | Git repository of rippled sources                       | `https://github.com/ripple/rippled.git`        |
| `node['rippled']['git_revision']`   | Git revision to check out                               | `0.30.0-hf1` |
| `node['rippled']['run_tests']`      | Run internal tests, `true` or `false`                   | `true`                                         |
| `node['rippled']['cmd_params']`     | Additional command line parameters to the daemon (\*) | `--net`                                        |
| `node['rippled']['config']`         | Content of rippled.cfg (described above)                | _identical to rippled-example.cfg_             |
| `node['rippled']['user']`           | User to run the daemon                                  | `rippled`                                      |
| `node['rippled']['group']`          | Group to create for the User                            | `rippled`                                      |
| `node['rippled']['pid_path']`       | Path to pid-file                                        | `/var/run/rippled.pid`                         |
| `node['rippled']['binary_path']`    | Where to install the executable                         | `/usr/bin/rippled`                             |
| `node['rippled']['config_path']`    | Where to install the config pid-file                    | `/etc/rippled/rippled.cfg`                     |

(\*) Do not add `--conf` or `--fg` here, neither add parameters that will cause the daemon to exit (like `--help`)

## Supported Platforms
- Ubuntu 14.04


## Known issues
- You need at least 16G memory to compile rippled. If memory is insufficient, g++ fails with an internal error. See `.kitchen.yml`
- `service status rippled` fails from non-privileged user because cannot read the config file. The file might have validation keys and thus restricted on purpose. If this issue bothers anybody, permissions shall be made configurable via chef attribures.

## rippled versions, cookbook versioning

This cookbook follows [semantic versioning](http://semver.org/).

Here is how to update the cookbook for a newer rippled version.
* Copy `rippled/doc/rippled-example.cfg` to `materials/rippled.cfg`
* Reflect any changes in `["rippled"]["config"]` attributes
* Bump rippled version in `["rippled"]["git_revision"]` attribute and in this README
* Bump cookbook version (since we alter the default value for `git_revision`, it is a breaking change)
* Update changelog
* `knife cookbook site share rippled Other -VV`


## Recipes

* `rippled::default`
Builds the rippled from source, configures, installs and runs.


## License and Author

|                      |                                              |
|:---------------------|:---------------------------------------------|
| **Author:**          | Dmitry Grigorenko (<grigorenko.d@gmail.com>) |
| **License:**         | Apache License, Version 2.0                  |

```text
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
```

## Changelog

### v0.3.0, November 27, 2015

* Bump rippled version to 0.30.0-hf1
* Fix documentation
