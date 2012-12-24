# for development
package 'vim'
package 'git'
package 'screen'

dpkg_package "elasticsearch" do
    case node[:platform]
    when "debian","ubuntu"
            package_name "elasticsearch"
            source "/vagrant /elasticsearch-0.20.1.deb"
    end
    action :install
end
