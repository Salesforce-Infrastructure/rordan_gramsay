require 'rake'
require_relative '../lint/kitchen'

namespace :kitchen do
  task lint: ['lint:kitchen']
end
