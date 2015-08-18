#
# Cookbook Name:: rippled
# Recipe:: default
#
# Copyright (c) 2015 Dmitry Grigorenko, All Rights Reserved.

include_recipe 'apt::default'

user = node['rippled']['user']
group = node['rippled']['group']
binary_folder = node['rippled']['binary_folder']

group group do
  action :create
end

user user do
  action :create
  gid group
end


# https://wiki.ripple.com/Rippled_build_instructions
# https://wiki.ripple.com/Ubuntu_build_instructions

# add-apt-repository -y ppa:boost-latest/ppa ; sudo apt-get update ; apt-get -y upgrade ; 
# sudo apt-get -y install git scons ctags pkg-config protobuf-compiler libprotobuf-dev libssl-dev python-software-properties libboost1.57-all-dev nodejs; 
# git clone https://github.com/ripple/rippled.git ; cd rippled/ ; git checkout master ; scons ; ./build/rippled --unittest ; sudo apt-get install npm; npm test


# does not contain proper packages
#apt_repository 'boost' do
#  uri 'ppa:boost-latest/ppa'
#  distribution node['lsb']['codename'] 
#end

# for boost
apt_repository 'rippled' do
  uri 'http://mirrors.ripple.com/ubuntu/'
  distribution 'trusty'
  components ['stable', 'contrib']
  key 'http://mirrors.ripple.com/mirrors.ripple.com.gpg.key'
  arch 'amd64'
end


node['rippled']['packages'].each do |pkg|
  package pkg
end


# The path maps to /tmp/kitchen/cache/rippled
git Chef::Config[:file_cache_path] + '/rippled' do
  repository node[:rippled][:git_repository]
  revision node[:rippled][:git_revision]
  action :sync
end

############## Build and configure ######################
# npm test fails with 
# oot@default-ubuntu-1404:/tmp/kitchen/cache/rippled# npm test

# > rippled@0.0.1 test /tmp/kitchen/cache/rippled
# > mocha test/websocket-test.js test/server-test.js test/*-test.{js,coffee}

# /usr/bin/env: node: No such file or directory
# npm ERR! weird error 127
# npm WARN This failure might be due to the use of legacy binary "node"
# npm WARN For further explanations, please read
# /usr/share/doc/nodejs/README.Debian

# npm ERR! not ok code 0
 bash 'install_rippled_build' do
   cwd Chef::Config[:file_cache_path] + '/rippled'
   code <<-EOH
     scons
     ./build/rippled --unittest 
     EOH
#      npm test
end

# install binary
# file node[:rippled][:binary] do
#   owner user
#   group group
#   mode 0755
#   content ::File.open(Chef::Config[:file_cache_path] + '/rippled/build/rippled').read
#   action :create
# end

ruby_block "copy_bin" do
  block do
    FileUtils.cp Chef::Config[:file_cache_path] + '/rippled/build/rippled', node[:rippled][:binary]
  end
end


rock_db_folder = node[:rippled][:rock_db_folder]
operational_db_folder = node[:rippled][:operational_db_folder]
debug_logfile_path = node[:rippled][:debug_logfile_folder] + '/debug.log'

[rock_db_folder, operational_db_folder, node[:rippled][:debug_logfile_folder]].each do |folder|
  directory folder do
    owner user
    group group
    mode '0755'
    recursive true
    action :create
  end
end

# upstart script
template "/etc/init/rippled.conf" do
  source "rippled.conf.erb"
  mode "0644"
  owner "root"
  group "root"
  variables({
    :user => user,
    :group => group,
    :binary => node[:rippled][:binary],
    :config => node[:rippled][:config],
    :rock_db_folder => rock_db_folder,
    :operational_db_folder => operational_db_folder,
    :debug_logfile_path => debug_logfile_path
  })
end

execute 'allow_to_bind_to_any_port' do
  command "setcap 'cap_net_bind_service=+ep' " + node[:rippled][:binary]
end

# rippled config
template node[:rippled][:config] do
  source "rippled.cfg.erb"
  mode "0600"
  owner user
  group group
  variables({
    :rock_db_folder => rock_db_folder,
    :operational_db_folder => operational_db_folder,
    :debug_logfile_path => debug_logfile_path
  })
end


service 'rippled' do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :start => true, :stop => true, :restart => true
  action [:enable, :start]
end

