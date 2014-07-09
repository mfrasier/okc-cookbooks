# write file to import environment varibles into apache
node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'php'
    Chef::Log.debug("Skipping deploy::php application #{application} as it is not an PHP app")
    next
  end

  # write out okc_env.conf
  Chef::Log.info("deploying okc_env for application #{application}")
  #Chef::Log.info("deploy json: #{deploy.to_s}")

  template "#{deploy[:deploy_to]}/shared/config/okc_env.conf" do
  	source 'okc_env.conf.erb'
    mode '0640'
    owner deploy[:user]
    group deploy[:group]
    variables (
      :deploy => deploy,
      :okc => node[:okc],
      :stack_name => node[:opsworks][:stack][:name]
    )
    only_if do
      File.exists?("#{deploy[:deploy_to]}/shared/config")
    end
  end
end
