require 'rake'
require 'paint'

require_relative '../../lint/kitchen_checker'

namespace :lint do
  # Checks cookbook's Test Kitchen configuration
  task :kitchen do
    puts Paint['Checking Test Kitchen configuration', :yellow, :bold]

    task_obj = RordanGramsay::Lint::KitchenChecker.new
    task_obj.call

    abort('rake aborted!') if task_obj.error_count.nonzero?
  end
end
