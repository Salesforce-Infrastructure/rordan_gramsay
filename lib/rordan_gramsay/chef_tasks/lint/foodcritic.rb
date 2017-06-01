require 'rake'

namespace :lint do
  # Checks cookbook files against Foodcritic style guide
  task :foodcritic do
    begin
      require 'foodcritic'
    rescue LoadError
      abort 'The rake task for lint:foodcritic requires Foodcritic to be installed.'
    end

    puts Paint['Inspecting all files with Foodcritic', :yellow, :bold]
    FoodCritic::Rake::LintTask.new do |task|
      task.options = {
        tags: %w(~FC001 ~FC003 ~FC019 ~FC023 ~FC064 ~FC065 ~FC066),
        fail_tags: ['any']
      }
    end
  end
end
