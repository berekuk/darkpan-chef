execute "apt-get-update" do
  command "apt-get update"
  ignore_failure true
end

include_recipe "perl"

# for development
package 'vim'
package 'git'
package 'screen'

# elasticsearch
package 'openjdk-6-jre'
remote_file "/tmp/elasticsearch.deb" do
  source "http://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-0.20.1.deb"
  mode 0644
end
dpkg_package "elasticsearch" do
  source "/tmp/elasticsearch.deb"
  action :install
end
service "elasticsearch" do
    action :nothing
end
file "/etc/default/elasticsearch" do
    mode 0644
    content "JAVA_HOME=/usr/lib/jvm/java-6-openjdk-amd64\n"
    notifies :restart, "service[elasticsearch]"
end

directory '/opt/log'

# darkpan
package 'make'
package 'unzip'
cpan_module 'OrePAN'
directory '/opt/orepan'

# cpan-api
git "/opt/cpan-api" do
  repository "https://github.com/CPAN-API/cpan-api.git"
  reference "master"
  action :sync
end
template "/opt/cpan-api/metacpan_server_local.conf" do
  source "metacpan_server_local.conf.erb"
  owner "root"
  group "root"
  mode 0644
end
package 'libexpat1-dev'
execute "cpan-api-deps" do
  cwd "/opt/cpan-api"
  command "cpanm --notest --installdeps . && bin/metacpan mapping --delete && touch /opt/cpan-api.installed"
  creates "/opt/cpan-api.installed"
end
include_recipe 'ubic'
cpan_module 'Ubic::Service::Plack'
cpan_module 'Starman'
ubic_service 'cpan-api' do
  action [:install, :start]
end

# metacpan-web
git "/opt/metacpan-web" do
  repository "https://github.com/CPAN-API/metacpan-web.git"
  reference "master"
  action :sync
end
package 'libxml2-dev'
execute "metacpan-web-deps" do
  cwd "/opt/metacpan-web"
  command "cpanm --notest --installdeps ."
end
template "/opt/metacpan-web/metacpan_web_local.conf" do
  source "metacpan_web_local.conf.erb"
  owner "root"
  group "root"
  mode 0644
end
ubic_service 'metacpan-web' do
  action [:install, :start]
end

# nginx
package 'nginx'
service 'nginx'
template "/etc/nginx/sites-enabled/darkpan" do
  source "nginx.conf.erb"
  owner "root"
  group "root"
  mode 0644
  variables({
    :port => 80,
    :server => node.server
  })
  notifies :restart, "service[nginx]"
end
