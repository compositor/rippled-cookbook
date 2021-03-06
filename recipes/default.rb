#
# Cookbook Name:: rippled
# Recipe:: default
#
# Copyright (c) 2015 Dmitry Grigorenko, All Rights Reserved.

# At a high level the recipe follows these instructions
# https://wiki.ripple.com/Rippled_build_instructions
# https://wiki.ripple.com/Ubuntu_build_instructions
# add-apt-repository -y ppa:boost-latest/ppa ; sudo apt-get update ; apt-get -y upgrade ;
# sudo apt-get -y install git scons ctags pkg-config protobuf-compiler libprotobuf-dev libssl-dev python-software-properties libboost1.57-all-dev nodejs;
# git clone https://github.com/ripple/rippled.git ; cd rippled/ ; git checkout master ; scons ; ./build/rippled --unittest ; sudo apt-get install npm; npm test

include_recipe 'apt::default'

user = node['rippled']['user']
group = node['rippled']['group']

group group do
  action :create
end

user user do
  action :create
  comment 'rippled system user'
  system true
  shell '/bin/false'
  gid group
end

############## Install pre-requirements and build  ######################

# for boost. Rippled needs at least 1.57 and the latest at 'ppa:boost-latest/ppa' is 1.55
apt_repository 'rippled' do
  uri 'http://mirrors.ripple.com/ubuntu/'
  distribution node['lsb']['codename']
  components ['stable', 'contrib']
  key 'http://mirrors.ripple.com/mirrors.ripple.com.gpg.key'
  arch 'amd64'
end

# Rippled requires gcc 5.1 or higher
apt_repository 'gcc' do
  uri 'ppa:ubuntu-toolchain-r/test'
  distribution node['lsb']['codename']
end

# https://wiki.ripple.com/Ubuntu_build_instructions : Add more recent node repository (tests do not work without it)
# apt_repository 'nodejs' do
#  uri 'ppa:chris-lea/node.js'
#  distribution node['lsb']['codename']
# end

# Packages needed to be installed to compile. This is for convenience and is not meant to be overwritten
packages = %w{g++-5 git scons exuberant-ctags pkg-config protobuf-compiler libprotobuf-dev libssl-dev python-software-properties libboost1.57-all-dev libcap2-bin}
# ctags is a virtual package provided by 2 packages, you must explicitly select one to install
# EXCLUDE nodejs is for js tests
# libcap2-bin is used by the cookbook inself
packages.each do |pkg|
  package pkg
end

bash 'gcc_version' do
  code <<-EOH
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-5 60 --slave /usr/bin/g++ g++ /usr/bin/g++-5
  EOH
end

# The path maps to /tmp/kitchen/cache/rippled
source_path = Chef::Config[:file_cache_path] + '/rippled'

git source_path do
  repository node['rippled']['git_repository']
  revision node['rippled']['git_revision']
  action :sync
end

bash 'build_rippled' do
   cwd source_path
   code <<-EOH
     scons
     EOH
end

########### Directories structure for data ##################

directory node["rippled"]["config"]["node_db"]["path"] do
  owner user
  group group
  mode '0755'
  recursive true
end

directory node["rippled"]["config"]["database_path"] do
  owner user
  group group
  recursive true
end

if node["rippled"]["config"].attribute?("debug_logfile") and not node["rippled"]["config"]["debug_logfile"].nil?
  log_dir = File.dirname(node["rippled"]["config"]["debug_logfile"])
  directory log_dir do
    owner user
    group group
    mode '0755'
    recursive true
  end
end


# rippled config

config_dir = File.dirname(node['rippled']['config_path'])

## TODO: the same trick for binary and other locations
directory config_dir do
  owner "root"
  group "root"
  recursive true
end

template node['rippled']['config_path'] do
  source "rippled.cfg.erb"
  mode "0600"
  owner user
  group group
  helper(:cfg) { node["rippled"]["config"] }
  notifies :restart, 'service[rippled]', :delayed
end

template "/etc/init.d/rippled" do
  source "rippled-initd.sh.erb"
  mode "0755"
  owner "root"
  group "root"
  variables({
    :user => user,
    :group => group,
    :pid_path => node['rippled']['pid_path'],
    :binary_path => node['rippled']['binary_path'],
    :config_path => node['rippled']['config_path'],
    :cmd_params => node['rippled']['cmd_params']
  })
  notifies :restart, 'service[rippled]', :delayed
end


# service shall be known here already
# setcap to allow binding to any port
built_binary = source_path + '/build/rippled'
target_binary = node['rippled']['binary_path']
bash "copy-rippled" do
  cwd Chef::Config[:file_cache_path]
  code <<-EOF
    service rippled stop
    sleep 2
    cp #{built_binary}  #{target_binary}
    setcap 'cap_net_bind_service=+ep'  #{target_binary}
    service rippled start
  EOF
  not_if ('cmp ' + built_binary + ' ' + target_binary)
end

service 'rippled' do
  supports :status => true, :start => true, :stop => true, :restart => true, :fetch => true, :uptime => true, :startconfig => true, :command => true, :test => true, :clean => true
  action [:enable, :start]
end

bash 'test_rippled' do
    cwd source_path
    code <<-EOH
      ./build/rippled --unittest
      EOH
    only_if { node["rippled"]["run_tests"] == 'true' }
end

bash "check-service-is-running" do
  code <<-EOF
    ps ax | grep -v grep | grep rippled > /dev/null
  EOF
end

# npm tests require to stop service and to install custom packages, do not implement them in the recipe for now
# npm install
# npm test

# ##################### Upstart version just in case ####################
# template "/etc/init/rippled.conf" do
#   source "rippled.conf.erb"
#   mode "0644"
#   owner "root"
#   group "root"
#   variables({
#     :user => user,
#     :group => group,
#     :binary => node['rippled']['binary_path'],
#     :config => node['rippled']['config_path']
#   })
#   notifies :restart, 'service[rippled]', :delayed
# end

# service 'rippled' do
#   provider Chef::Provider::Service::Upstart
#   supports :status => true, :start => true, :stop => true, :restart => true
#   action [:enable, :start]
# end
