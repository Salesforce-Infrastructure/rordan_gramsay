require 'rake'

namespace :test do
  task all: ['test:quick', 'test:slow']

  task slow: ['kitchen:test']

  task quick: ['dependency:check', 'lint:all']
end
desc 'Runs all linting and integration tests'
task test: ['test:all']

require_relative 'lint'
require_relative 'kitchen'
require_relative 'dependencies'
