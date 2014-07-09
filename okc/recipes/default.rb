Chef::Log.info("I am a message from the #{recipe_name} recipe in the #{cookbook_name} cookbook.")

include_recipe 'apache2'
include_recipe okc::okc_env

application_name = deploy[:domains].first
rewrite_config = "#{node[:apache][:dir]}/sites-available/#{application_name}.conf.d/rewrite"
local_config = "#{node[:apache][:dir]}/sites-available/#{application_name}.conf.d/local"

# create extra config dirs
directory rewrite_config do
	owner 'root'
	group 'root'
	mode  '0644'
	action :create
end

directory local_config do
	owner 'root'
	group 'root'
	mode 00644
	action :create
end

# create permanent redirect from http to https
file "#{local_config}/redirect.conf" do
  owner "root"
  group "root"
  mode "0644"
  content "Redirect permanent / https://api.okcra.org/\n"
  action :create
end