# vi: ft=ruby

plugins = ['vagrant-hostmanager']
plugins.each do |plugin|
        if !Vagrant.has_plugin?(plugin)
            puts "Plugin #{plugin} is missing. Please install!"
            exit 1
        end
end
