require 'rake'
require 'paint'
require_relative '../../lint/test_checker'

namespace :lint do
  # Checks cookbook for tests
  task :tests do
    puts Paint['Looking for Inspec tests', :yellow, :bold]

    task_obj = RordanGramsay::Lint::TestChecker.new
    task_obj.call

    abort('rake aborted!') if task_obj.error_count > 0
  end
end
