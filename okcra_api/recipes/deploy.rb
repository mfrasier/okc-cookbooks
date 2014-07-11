Chef::Log.info("I am a message from the #{recipe_name} recipe in the #{cookbook_name} cookbook.")

include_recipe 'apache2'

# write apache config files
# /etc/httpd/sites-available/#{application}.conf Include directives:
#  Include /etc/httpd/sites-available/okcra_api.conf.d/rewrite[-ssl]*
#  Include /etc/httpd/sites-available/okcra_api.conf.d/local[-ssl]*
node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'php'
    Chef::Log.debug("Skipping #{cookbook_name}::#{recipe_name} application #{application} as it is not a PHP app")
    next
  end

  # directory to drop config files into
  # ensure names are local[-ssl]* or rewrite[-ssl]*
  vhost_config_dir = "#{node[:apache][:dir]}/sites-available/#{application}.conf.d"

  directory vhost_config_dir do
  	owner 'root'
    group 'root'
    mode  '0644'
    action :create
  end

  template "#{vhost_config_dir}/local_okc_env.conf" do
  	source 'okc_env.conf.erb'
    mode '0640'
    owner deploy[:user]
    group deploy[:group]
    variables ({
      :application => application,
      :deploy => deploy
    })
    only_if do
      File.exists?("#{deploy[:deploy_to]}/shared/config")
    end
  end
  
  # permanent redirect from http to https
  template "#{vhost_config_dir}/local_redirect2https.conf" do
  	source 'redirect.conf.erb'
    owner 'root'
    group 'root'
    mode  '0644'
    variables ({
      :application => application,
    	:deploy => deploy
    })
    action :create
    notifies :restart, "service[apache2]"
  end

  # rewrite (.*) to /index.php$1
  template "#{vhost_config_dir}/rewrite-ssl.conf" do
  	source 'rewrite.conf.erb'
    owner 'root'
    group 'root'
    mode  '0644'
    action :create
    notifies :restart, "service[apache2]"
  end

  # enable php5 mcrypt module for laravel
  execute "php5enmod mcrypt" do
   	command "php5enmod mcrypt"
   	#creates "/etc/php5/apache2/conf.d/20-mcrypt,ini on ubutnu"
   	action :run
   end

  # create deploy_dir/app/storge/logs/laravel.log
  directory "#{deploy['deploy_to']}/app/storage/logs" do
  	owner [:apache][:user]
  	group [:apache][:group]
  	mode "0755"
  	action :create
  end

  file "#{deploy['deploy_to']}/app/storage/logs/laravel.log" do
  	owner [:apache][:user]
  	group [:apache][:group]
  	mode "0755"
  	action :create
  end

end