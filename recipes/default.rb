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

firewalld_service 'mysql'

include_recipe 'mysql-multi::mysql-master' if node.roles.include('mysql-primary')
include_recipe 'mysql-multi::mysql-slave' if node.roles.include('mysql-backup')
