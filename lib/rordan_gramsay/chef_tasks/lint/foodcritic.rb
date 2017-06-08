require 'rake'
require 'paint'
require_relative '../../lint/foodcritic'

namespace :lint do
  # Checks cookbook files against Foodcritic style guide
  task :foodcritic do
    puts Paint['Inspecting files with Foodcritic', :yellow, :bold]

    task_obj = RordanGramsay::Lint::Foodcritic.new(
      fail_tags: ['any'],
      tags: %w(~FC001 ~FC003 ~FC019 ~FC023 ~FC064 ~FC065 ~FC066 ~license)
    )

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
