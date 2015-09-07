# rippled Cookbook
	
This cookbook compiles and installs a [Ripple](https://ripple.com) node (version 0.29.0). At the time of writing Ripple Labs does not provide a precompiled package for the most recent release, therefore the only installation method available is via sources.

The cookbook generally follows instructions published at [here](https://wiki.ripple.com/Ubuntu_build_instructions) with the following improvements:
- allow to bind on privileged ports
- use upstart for the daemon


## Attributes

Please refer to rippled example configuration in sources for the full list of settings [souces](https://github.com/ripple/rippled/blob/master/doc/rippled-example.cfg). 

All attributes within <code>node["rippled"]["config"]</code> will be converted to the content of `rippled.cfg`. A `key` from <code>node["rippled"]["config"][key]</code> becomes a section. A corresponding value might be a string (converts to a single string in the section), an array (each element goes as a string in the section), a map (converts to a list of key=value strings), `nil` (to suppress default attributes, the section is not created then). It is clear from examples:

An array
```ruby
node["rippled"]["config"]["server"] = ["port_rpc_admin_local", "port_peer", "port_ws_admin_local"]
```
becomes a section (mind `server` -> `[server]` transformation done by the recipe)
```
[server]
port_rpc_admin_local
port_peer
port_ws_admin_local
```

A single value
```ruby
node["rippled"]["config"]["node_size"] = "medium"
```
becomes a section
```
[node_size]
medium
```

A map
```ruby
node["rippled"]["config"]["port_peer"] = {
	"port" => "51235",
	"ip" => "0.0.0.0",
	"protocol" => "peer"
}
```
becomes a section
```
[port_peer]
port=51235
ip=0.0.0.0
protocol=peer
```

A `nil`
```ruby
node["rippled"]["config"]["port_ws_admin_local"] = nil
```
removes `port_ws_admin_local` section

Generally speaking, sections of `rippled.cfg` contain lines with either values or key-value pairs. The only mix is `[server]` and putting a key-value there is syntax shugar and thus can be easily avoided. If you still need a mix, you can use the following construction

```ruby
default["rippled"]["config"]["server"] = ["port_rpc_admin_local", "#port_ws_public", "ssl_key = /etc/ssl/private/server.key", "ssl_cert = /etc/ssl/certs/server.crt"]
```

The default attributes merely repeat default rippled configuration from [souces](https://github.com/ripple/rippled/blob/master/doc/rippled-example.cfg). For better version tracking a copy of this example used to derive the attributes is saved in this cookbook at materials/rippled-example.cfg

If the following pathes are specified (explicitly or with default values), the reciept will create corresponding folders for under `node['rippled']['user']` ownership:
* `["rippled"]["config"]["node_db"]["path"]`
* `["rippled"]["config"]["database_path"]`
* `["rippled"]["rippled"]["config"]["debug_logfile"]`

All other attributes are listed below.


<table>
  <tr>
    <td>Attribute</td>
    <td>Description</td>
    <td>Default</td>
  </tr>
  <tr>
    <td><code>node['rippled']['git_repository']</code></td>
    <td>Git repository of rippled sources</td>
    <td><code>https://github.com/ripple/rippled.git</code></td>
  </tr>
  <tr>
    <td><code>node['rippled']['git_revision']</code></td>
    <td>Git revision to check out</td>
    <td><code>0.29.0</code></td>
  </tr>
  <tr>
    <td><code>node['rippled']['run_tests']</code></td>
    <td>Run internal tests, <code>true</code> or <code>false</code></td>
    <td><code>true</code></td>
  </tr>
  <tr>
    <td><code>node['rippled']['cmd_params']</code></td>
    <td>
    	Additional command line parameters to the deamon<br>
    	Do not add <code>--conf</code> or <code>--fg</code> here, neigher add parameters that will cause the deamon to exit (like <code>--help</code>)
    </td>
    <td><code>--net</code></td>
  </tr>  
  <tr>
    <td><code>node['rippled']['config']</code></td>
    <td>Content of rippled.cfg (described above)</td>
    <td><i>identical to rippled-example.cfg</i></td>
  </tr>  
  <tr>
    <td><code>node['rippled']['user']</code></td>
    <td>User to run the daemon</td>
    <td><code>rippled</code></td>
  </tr>
  <tr>
    <td><code>node['rippled']['group']</code></td>
    <td>Group to create for the user</td>
    <td><code>rippled</code></td>
  </tr>
  <tr>
    <td><code>node['rippled']['pid_path']</code></td>
    <td>Path to pid-file</td>
    <td><code>/var/run/rippled.pid</code></td>
  </tr>
  <tr>
    <td><code>node['rippled']['binary_path']</code></td>
    <td>Where to install the executable</td>
    <td><code>/usr/bin/rippled</code></td>
  </tr>
  <tr>
    <td><code>node['rippled']['config_path']</code></td>
    <td>Where to install the config file</td>
    <td><code>/etc/rippled/rippled.cfg</code></td>
  </tr>
  <tr>
    <td><code>node['rippled']['packages']</code></td>
    <td>List of packages to install, do not edit</td>
    <td><i>cookbook implementation specific</i></td>
  </tr>
 </table>


## Supported Platforms
- Ubuntu 14.04


## Known issues
- You need at least 16G memory to compile rippled. If memory is insufficient, g++ fails with an internal error. See `.kitchen.yml`
<!--
- Tests use nodejs from from ppa which conflicts with default ubuntu npm. You will not be able to apt-get npm (this will fail with an error)
-->

## How to update this cookbook to the next rippled version
* Copy `rippled/doc/rippled-example.cfg` to `materials/rippled.cfg`
* Reflect any changes in `["rippled"]["config"]` attributes
* Bump rippled version in `["rippled"]["git_revision"]` attribute and in this README
* Bump cookbook version


Recipes
=======

* rippled::default
Builds the rippled from source, configures, installs and runs.


License and Author
==================

|                      |                                             |
|:---------------------|:--------------------------------------------|
| **Author:**          | Dmitry Grigorenko (<grigorenko.d@gmail.com>)
| **License:**         | Apache License, Version 2.0

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
