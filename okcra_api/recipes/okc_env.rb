# write file to import environment varibles into apache
node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'php'
    Chef::Log.debug("Skipping deploy::php application #{application} as it is not an PHP app")
    next
  end

  # write out okc_env.conf
  Chef::Log.debug("deploying okc_env for application #{application}")
  Chef::Log.debug("deploy json: #{deploy.to_s}")
end
