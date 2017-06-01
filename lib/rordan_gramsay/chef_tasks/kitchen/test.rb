require 'rake'
require 'paint'
require_relative 'verify'

namespace :kitchen do
  # Runs integration tests on the cookbook
  task test: ['kitchen:verify']
end
