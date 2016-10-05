# This file is only used when running chef in local mode during image creation
# cd /home/vagrant/cookbooks/custom_mysql && sudo chef-client -z -c client.rb -o 'recipe[custom_mysql],role[mysql-primary/backup]'
cookbook_path '/home/vagrant/cookbooks'
role_path '/home/vagrant/cookbooks/custom_mysql/roles'
data_bag_path '/home/vagrant/cookbooks/custom_mysql/data_bags'
environment_path '/home/vagrant/cookbooks/custom_mysql/environments'
environment 'kitchen'
local_mode 'true'
log_level :info
