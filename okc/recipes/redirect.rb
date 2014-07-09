Chef::Log.info("I am a message from the #{recipe_name} recipe in the #{cookbook_name} cookbook.")

file "/tmp/something.txt" do
  owner "root"
  group "root"
  mode "0644"
  content "Redirect permanent / https://api.okcra.org/\n"
  action :create
end
