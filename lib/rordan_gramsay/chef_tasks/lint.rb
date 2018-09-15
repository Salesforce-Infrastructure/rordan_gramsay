require 'rake'

# Meta-task for all linting tasks
namespace :lint do
  task all: %w[lint:rubocop lint:foodcritic lint:comments lint:tests lint:kitchen]
end
desc 'Lints cookbook using all tools'
task lint: ['lint:all']

require_relative 'lint/rubocop'
require_relative 'lint/foodcritic'
require_relative 'lint/comments'
require_relative 'lint/tests'
require_relative 'lint/kitchen'
