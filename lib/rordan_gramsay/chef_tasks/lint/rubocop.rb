require 'rake'
require 'paint'

namespace :lint do
  # Checks cookbook files against Rubocop style guide
  task :rubocop do
    begin
      require 'cookstyle'
      require 'rubocop/rake_task'
    rescue LoadError
      abort 'The rake task for lint:rubocop requires Cookstyle to be installed.'
    end

    puts Paint['Inspecting all files with RuboCop', :yellow, :bold]
    RuboCop::RakeTask.new do |task|
      task.options = %w(-D -fp)
    end
  end
end
