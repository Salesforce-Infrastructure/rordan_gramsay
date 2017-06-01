require 'rake'
require 'paint'

namespace :kitchen do
  # Destroys VMs created with Test Kitchen
  task :destroy do
    begin
      require 'kitchen'
    rescue LoadError
      abort "Must have the 'kitchen' gem installed"
    end

    puts Paint['Destroying VMs', :yellow, :bold]
    Kitchen.logger = Kitchen.default_file_logger
    Kitchen::Config.new.instances.each(&:destroy)
  end
end
