Chef::Log.debug("calling redirect recipe")

file "/tmp/something.txt" do
  owner "root"
  group "root"
  mode "0660"
  content "Redirect permanent / https://api.okcra.org/"
  action :create
end
