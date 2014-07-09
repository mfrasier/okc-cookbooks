Chef::Log.info("I am a message from the #{recipe_name} recipe in the #{cookbook_name} cookbook.")

include_recipe 'apache2'
include_recipe 'okc::okc_env'

# write apache config files
node[:deploy].each do |application, deploy|
  rewrite_config = "#{node[:apache][:dir]}/sites-available/#{application}.conf.d/rewrite"
  local_config = "#{node[:apache][:dir]}/sites-available/#{application}.conf.d/local"
  rewrite_config_ssl = "#{node[:apache][:dir]}/sites-available/#{application}.conf.d/rewrite-ssl"
  local_config_ssl = "#{node[:apache][:dir]}/sites-available/#{application}.conf.d/local-ssl"
  
  # create extra config dirs
  [rewrite_config, local_config, rewrite_config_ssl, local_config_ssl].each do |dir|
    directory dir do
  	  owner 'root'
  	  group 'root'
  	  mode  '0644'
  	  action :create
  	end
  end
  
  # permanent redirect from http to https
  template "#{local_config}/redirect.conf" do
  	source 'redirect.conf.erb'
    owner 'root'
    group 'root'
    mode  '0644'
    variables ({
    	:deploy => deploy,
    	:application => application
    })
    action :create
  end

  # rewrite /* to /index.php/*
  template "#{rewrite_config_ssl}/rewrite.conf" do
  	source 'rewrite.conf.erb'
    owner 'root'
    group 'root'
    mode  '0644'
    action :create
  end
end