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
