require 'rake'
require 'paint'
require_relative '../../lint/cookbook_comments_checker'

namespace :lint do
  # Checks cookbook files for required comment lines
  task :comments do
    puts Paint['Inspecting all files for comments', :yellow, :bold]

    task_obj = RordanGramsay::Lint::CookbookCommentsChecker.new
    task_obj.call

    abort if task_obj.error_count.nonzero?
  end
end
