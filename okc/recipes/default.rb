Chef::Log.info("I am a message from the #{recipe_name} recipe in the #{cookbook_name} cookbook.")

include_recipe 'apache2'
include_recipe 'okc::okc_env'

# write apache config files
# /etc/httpd/sites-available/#{application}.conf Include directives:
#  Include /etc/httpd/sites-available/okcra_api.conf.d/rewrite[-ssl]*
#  Include /etc/httpd/sites-available/okcra_api.conf.d/local[-ssl]*
node[:deploy].each do |application, deploy|
  # directory to drop config files into
  # ensure names are local[-ssl]* or rewrite[-ssl]*
  vhost_config_dir = "#{node[:apache][:dir]}/sites-available/#{application}.conf.d"

  directory vhost_config_dir do
  	owner 'root'
    group 'root'
    mode  '0644'
    action :create
  end
  
  # permanent redirect from http to https
  template "#{vhost_config_dir}/local_redirect2https.conf" do
  	source 'redirect.conf.erb'
    owner 'root'
    group 'root'
    mode  '0644'
    variables ({
    	:deploy => deploy,
    	:application => application
    })
    action :create
    notifies :restart, "service[apache2]"
  end

  # rewrite /* to /index.php/*
  template "#{vhost_config_dir}/rewrite-ssl.conf" do
  	source 'rewrite.conf.erb'
    owner 'root'
    group 'root'
    mode  '0644'
    action :create
    notifies :restart, "service[apache2]"
  end
end