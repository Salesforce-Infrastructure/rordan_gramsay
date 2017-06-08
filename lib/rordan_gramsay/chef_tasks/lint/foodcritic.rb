require 'rake'
require_relative '../../lint/foodcritic'

namespace :lint do
  # Checks cookbook files against Foodcritic style guide
  task :foodcritic do
    puts Paint['Inspecting files with Foodcritic', :yellow, :bold]

    task_obj = RordanGramsay::Lint::Foodcritic.new(
      fail_tags: ['any'],
      tags: %w(~FC001 ~FC003 ~FC019 ~FC023 ~FC064 ~FC065 ~FC066)
    )

    task_obj.call

    abort('Files to fix: %d'.format(task_obj.files.count(&:failed?))) if task_obj.failed?
  end
end
