#
# Cookbook Name:: custom_mysql
# Spec:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'custom_mysql::default' do
  context 'When all attributes are default, with mysql-backup role, on rhel family' do
    cached(:chef_run) do
      ChefSpec::ServerRunner.new do |node, server|
        node.automatic['os'] = 'linux'
        node.automatic['platform_family'] = 'rhel'
        node.chef_environment = 'kitchen'
        node.automatic['virtualization']['system'] = 'vmware'
        server.create_environment('kitchen', default_attributes: { 'mysql-multi': { master: '33.33.33.71' } } )
        server.create_data_bag('mysql',
                                 'secrets' => {
                                   'server_repl_password' => 'repl1cat0r!',
                                   'slave_user' => 'repl'
                                 }
                               )
        server.create_role('mysql-backup')
      end.converge('role[mysql-backup]', described_recipe)
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

    it 'includes the mysql-multi::mysql_slave cookbook' do
      expect(chef_run).to include_recipe('mysql-multi::mysql_slave')
    end

    it 'renders the slave.cnf file' do
      expect(chef_run).to render_file('/etc/mysql/conf.d/slave.cnf')
    end
  end
end
