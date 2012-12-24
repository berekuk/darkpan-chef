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
package 'openjdk-7-jre'
dpkg_package "elasticsearch" do
    case node[:platform]
    when "debian","ubuntu"
            package_name "elasticsearch"
            source "/vagrant/deb/elasticsearch-0.20.1.deb"
    end
    action :install
end

# darkpan
package 'make'
package 'unzip'
cpan_module 'OrePAN'
directory '/opt/orepan'

# debugging - inject Ubic to orepan
execute "inject-ubic" do
  command "orepan.pl --destination=/opt/orepan --pause=MMCLERIC /vagrant/tmp/Ubic-1.48.tar.gz && orepan_index.pl --repository=/opt/orepan"
end

git "/opt/cpan-api" do
  repository "https://github.com/CPAN-API/cpan-api.git"
  reference "master"
  action :sync
end
package 'libexpat1-dev'
execute "cpan-api-deps" do
  cwd "/opt/cpan-api"
  command "cpanm --notest --installdeps ."
end
template "/opt/cpan-api/metacpan_server_local.conf" do
  source "metacpan_server_local.conf.erb"
  owner "root"
  group "root"
  mode 0644
end

include_recipe 'ubic'
cpan_module 'Ubic::Service::Plack'
cpan_module 'Starman'
ubic_service 'cpan-api' do
  action [:install, :start]
end
