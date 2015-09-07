#
# Cookbook Name:: rippled
# Spec:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'rippled::default' do
  context 'When all attributes are default, on ubuntu 14.04 platform' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'ubuntu')
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      chef_run # This should not raise an error
    end

    it 'starts rippled service' do
    	expect(chef_run).to start_service('rippled')
    end
  end
end
