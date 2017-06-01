require 'rake'

# Meta-task for all linting tasks
require_relative 'kitchen/create'
require_relative 'kitchen/converge'
require_relative 'kitchen/verify'
require_relative 'kitchen/destroy'
require_relative 'kitchen/test'
require_relative 'kitchen/lint'

desc 'Runs integration tests using Test Kitchen'
task kitchen: ['kitchen:test']
