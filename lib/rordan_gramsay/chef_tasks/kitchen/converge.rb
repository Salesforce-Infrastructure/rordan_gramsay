require 'rake'
require 'paint'

namespace :kitchen do
  # Tests converging the cookbook
  task :converge do
    begin
      require 'kitchen'
    rescue LoadError
      abort "Must have the 'kitchen' gem installed"
    end

    puts Paint['Converging cookbook', :yellow, :bold]
    Kitchen.logger = Kitchen.default_file_logger
    Kitchen::Config.new.instances.each(&:destroy)
    Kitchen::Config.new.instances.each(&:converge)
    Kitchen::Config.new.instances.each(&:destroy)
  end
end
