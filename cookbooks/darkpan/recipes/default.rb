execute "apt-get-update" do
  command "apt-get update"
  ignore_failure true
end

include_recipe "perl"
include_recipe 'ubic'

# for development
package 'vim'
package 'git'
package 'screen'

# elasticsearch
package 'openjdk-6-jre'
remote_file "/tmp/elasticsearch.deb" do
  source "http://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-0.20.1.deb"
  mode 0644
  action :create_if_missing
end
dpkg_package "elasticsearch" do
  source "/tmp/elasticsearch.deb"
  action :install
end
file "/etc/default/elasticsearch" do
    mode 0644
    content "JAVA_HOME=/usr/lib/jvm/java-6-openjdk-amd64\n"
end
service "elasticsearch" do
    action :start
end

directory '/opt/log'

# orepan
package 'make'
package 'unzip'
cpan_module 'OrePAN'
directory '/opt/orepan'

# pinto
cpan_module 'Task::Pinto'
directory '/opt/pinto'
execute "pinto-init" do
  cwd "/opt/pinto"
  command "pinto init --root . --stack darkpan && touch /opt/pinto.init"
  creates "/opt/pinto.init"
end
ubic_service 'pintod' do
  action [:install, :start]
end

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
cpan_module 'Ubic::Service::Plack'
cpan_module 'Starman'
ubic_service 'cpan-api' do
  action [:install, :start]
end
cron "cpan-api-index-pinto" do
    command "flock -n /opt/metacpan.index.lock -c '(/opt/cpan-api/bin/metacpan release /opt/pinto/darkpan/authors/id/ --cpan /opt/pinto/darkpan/authors/id/ --skip && /opt/cpan-api/bin/metacpan latest /opt/pinto/darkpan/ --cpan /opt/pinto/darkpan/) >>/opt/log/metacpan-index.log 2>>/opt/log/metacpan-index.err.log'"
end

# metacpan-web
package 'libcurl4-openssl-dev' # curl-config
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
file '/etc/nginx/sites-enabled/default' do
  action :delete
end
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
