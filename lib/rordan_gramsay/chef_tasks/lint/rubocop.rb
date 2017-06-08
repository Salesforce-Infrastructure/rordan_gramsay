require 'rake'
require 'paint'

require_relative '../../lint/rubocop'

namespace :lint do
  # Checks cookbook files against Rubocop style guide
  task :rubocop do
    puts Paint['Inspecting all files with RuboCop', :yellow, :bold]

    task_obj = RordanGramsay::Lint::Rubocop.new

    task_obj.call

    rules = task_obj.rules
    unless rules.empty?
      puts ''
      rules.each do |rule|
        code = Paint[rule.code, :yellow]
        description = Paint[rule.name, :white]
        puts "#{code}: #{description}"
      end
      puts ''
    end

    if task_obj.failed?
      msg = Paint % ['Files to fix: %{count}', :white, :bold, count: task_obj.file_list.count(&:failed?)]
      abort msg
    end
  end
end
