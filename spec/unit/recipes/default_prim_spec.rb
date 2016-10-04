#
# Cookbook Name:: custom_mysql
# Spec:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'custom_mysql::default' do
  context 'When all attributes are default, with mysql-primary role, on rhel family' do
    cached(:chef_run) do
      ChefSpec::ServerRunner.new do |node, server|
        node.automatic['os'] = 'linux'
        node.automatic['platform_family'] = 'rhel'
        node.chef_environment = 'kitchen'
        server.create_environment('kitchen', default_attributes: { 'mysql-multi': { slaves: ['33.33.33.72'] } } )
        server.create_data_bag('mysql',
                                 'secrets' => {
                                   'server_repl_password' => 'repl1cat0r!',
                                   'slave_user' => 'repl'
                                 }
                               )
        server.create_role('mysql-primary')
      end.converge('role[mysql-primary]', described_recipe)
    end

    it 'creates the mysql user' do
      expect(chef_run).to create_user('mysql')
    end

    it 'creates the /etc/mysql directory' do
      expect(chef_run).to create_directory('/etc/mysql')
    end

    it 'includes the mysql-multi cookbook' do
      expect(chef_run).to include_recipe('mysql-multi')
    end

    it 'creates the /etc/mysql/conf.d directory' do
      expect(chef_run).to create_directory('/etc/mysql/conf.d')
    end

    it 'renders the /etc/mysql/conf.d/my.cnf file' do
      expect(chef_run).to render_file('/etc/mysql/conf.d/my.cnf')
    end

    it 'opens the mysql firewall port' do
      expect(chef_run).to add_firewalld_service('mysql')
    end

    it 'includes the mysql-multi::mysql_master cookbook' do
      expect(chef_run).to include_recipe('mysql-multi::mysql_master')
    end

    it 'renders the master.cnf file' do
      expect(chef_run).to render_file('/etc/mysql/conf.d/master.cnf')
    end
  end
end
