#
# Cookbook Name:: rippled
# Recipe:: default
#
# Copyright (c) 2015 Dmitry Grigorenko, All Rights Reserved.

# At a high level follows these instructions
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

# for boost. Rippled needs at least 1.57 and the latest at 'ppa:boost-latest/ppa' is 1.55
apt_repository 'rippled' do
  uri 'http://mirrors.ripple.com/ubuntu/'
  distribution node['lsb']['codename']
  components ['stable', 'contrib']
  key 'http://mirrors.ripple.com/mirrors.ripple.com.gpg.key'
  arch 'amd64'
end

# https://wiki.ripple.com/Ubuntu_build_instructions : Add more recent node repository (tests do not work without it)
apt_repository 'nodejs' do
 uri 'ppa:chris-lea/node.js'
 distribution node['lsb']['codename']
end

node['rippled']['packages'].each do |pkg|
  package pkg
end

# The path maps to /tmp/kitchen/cache/rippled
source_path = Chef::Config[:file_cache_path] + '/rippled'

git source_path do
  repository node['rippled']['git_repository']
  revision node['rippled']['git_revision']
  action :sync
end

############## Build and configure ######################
bash 'build_rippled' do
   cwd source_path
   code <<-EOH
     scons
     EOH
end


ruby_block "copy_bin" do
  block do
    FileUtils.cp source_path + '/build/rippled', node['rippled']['binary_path']
  end
end

execute 'allow_to_bind_to_any_port' do
  command "setcap 'cap_net_bind_service=+ep' " + node['rippled']['binary_path']
end

########### Directories structure for data ##################

dirs_to_create = []
if (not node["rippled"]["config"]["node_db"].nil?) and node["rippled"]["config"]["node_db"].attribute?("path")
    dirs_to_create.push(node["rippled"]["config"]["node_db"]["path"])
end

if node["rippled"]["config"].attribute?("database_path")
  dirs_to_create.push(node["rippled"]["config"]["database_path"])
end

if node["rippled"]["config"].attribute?("debug_logfile")
  dirs_to_create.push(File.dirname(node["rippled"]["config"]["debug_logfile"]))
end

dirs_to_create.each do |dir|
  directory dir do
    owner user
    group group
    mode '0755'
    recursive true
    action :create
  end
end

# rippled config

config_dir = File.dirname(node['rippled']['config_path'])

## TODO: the same trick for binary and other locations
directory config_dir do
  owner user
  group group
  recursive true
end

template node['rippled']['config_path'] do
  source "rippled.cfg.erb"
  mode "0755"
#  owner user
#  group group
  helper(:cfg) { node[:rippled][:config] }
  notifies :restart, 'service[rippled]', :delayed
end

template "/etc/init.d/rippled" do
  source "rippled-initd.sh.erb"
  mode "0755"
  owner "root"
  group "root"
  variables({
    :name => node['rippled']['service_name'],
    :user => user,
    :group => group,
    :pid_path => node['rippled']['pid_path'],
    :binary_path => node['rippled']['binary_path'],
    :config_path => node['rippled']['config_path'],
    :cmd_params => node['rippled']['cmd_params']
  })
end

service node['rippled']['service_name'] do
 supports :status => true, :start => true, :stop => true, :restart => true, :fetch => true, :uptime => true, :startconfig => true, :command => true, :test => true, :clean => true
 action [:enable, :start]
end

#      service rippled stop
bash 'test_rippled' do
    cwd source_path
    code <<-EOH
      ./build/rippled --unittest
      npm install 
      npm test
      EOH
    notifies :start, 'service[rippled]', :immediately
    only_if { node["rippled"]["run_tests"] == 'true' } 
end


# upstart script
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
# ##################### Run ####################
# service 'rippled' do
#   provider Chef::Provider::Service::Upstart
#   supports :status => true, :start => true, :stop => true, :restart => true
#   action [:enable, :start]
# end
