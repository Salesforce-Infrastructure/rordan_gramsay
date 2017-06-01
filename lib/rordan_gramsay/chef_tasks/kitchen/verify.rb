require 'rake'
require 'paint'

namespace :kitchen do
  # Runs integration tests on the cookbook
  task :verify do
    begin
      require 'kitchen'
    rescue LoadError
      abort "Must have the 'kitchen' gem installed"
    end

    puts Paint['Verifying that converging the cookbook had the intended effect', :yellow, :bold]
    Kitchen.logger = Kitchen.default_file_logger
    Kitchen::Config.new.instances.each(&:destroy)
    Kitchen::Config.new.instances.each(&:verify)
    Kitchen::Config.new.instances.each(&:destroy)
  end
end
