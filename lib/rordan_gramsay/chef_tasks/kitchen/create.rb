require 'rake'
require 'paint'

namespace :kitchen do
  # Creates VMs for use with Test Kitchen
  task :create do
    begin
      require 'kitchen'
    rescue LoadError
      abort "Must have the 'kitchen' gem installed"
    end

    puts Paint['Creating VMs', :yellow, :bold]
    Kitchen.logger = Kitchen.default_file_logger
    Kitchen::Config.new.instances.each(&:destroy)
    Kitchen::Config.new.instances.each(&:create)
  end
end
