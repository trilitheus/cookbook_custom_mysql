if node['roles'].include? 'mysql-primary'
  server_id = 1
elsif node['roles'].include? 'mysql-backup'
  server_id = 2
end

if 'kitchen'.include?(node.chef_environment)
  secret = Chef::DataBagItem.load('mysql', 'secrets')
  node.set['mysql-multi']['server_repl_password'] = secret['server_repl_password']
  node.set['mysql-multi']['slave_user'] = secret['slave_user']
  Chef::Log.fatal("REPL PASSWORD IS #{secret['server_repl_password']}")
else
  secret_file = Chef::EncryptedDataBagItem.load_secret(node['secret_file'])
  secret = Chef::EncryptedDataBagItem.load('mysql', 'secrets', secret_file)
  node.set['mysql-multi']['server_repl_password'] = secret['server_repl_password']
end

user 'mysql'

directory '/etc/mysql' do
  owner 'mysql'
  group 'mysql'
end

include_recipe 'mysql-multi'

d = resources(directory: '/etc/mysql/conf.d')
d.owner('mysql')
d.group('mysql')

t = resources(template: '/etc/mysql/conf.d/my.cnf')
t.owner('mysql')
t.group('mysql')
t.variables(serverid: server_id,
            cookbook_name: 'mysql-multi',
            bind_address: node['mysql-multi']['bind_ip'])

firewalld_service 'mysql' unless node['virtualization']['system'] == 'docker'

if node.roles.include?('mysql-primary')
  include_recipe 'mysql-multi::mysql_master'
  p_t = resources(template: '/etc/mysql/conf.d/master.cnf')
  p_t.owner('mysql')
  p_t.group('mysql')
end

if node.roles.include?('mysql-backup')
  include_recipe 'mysql-multi::mysql_slave'
  b_t = resources(template: '/etc/mysql/conf.d/slave.cnf')
  b_t.owner('mysql')
  b_t.group('mysql')
end
