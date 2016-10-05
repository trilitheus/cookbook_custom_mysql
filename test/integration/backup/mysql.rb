describe package('mysql-community-server') do
 it {should be_installed}
end

describe service('mysqld') do
  it { should be_enabled }
  it { should be_running }
end

describe port(3306) do
  it { should be_listening }
end

describe file('/etc/mysql/conf.d/my.cnf') do
  its('content') { should match /server-id = 2/ }
end
