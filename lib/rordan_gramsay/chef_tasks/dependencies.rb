require 'paint'
require_relative '../dependencies'

# rubocop:disable Lint/UnneededCopDisableDirective

file 'Berksfile.lock' do
  `berks install`
end

task dependency: ['dependency:check']

namespace :dependency do
  desc 'Check if version pinning has been done correctly'
  task :check do
    $stdout.puts(Paint['Inspecting version constraints for errors', :yellow, :bold])
    obj = RordanGramsay::Dependencies::Pinning.new
    obj.check
    abort if obj.failure?
  end

  desc 'Remove pinned dependencies from metadata.rb'
  task :clean do
    $stdout.puts(Paint['Removing dependency entries from metadata.rb', :yellow, :bold])
    obj = RordanGramsay::Dependencies::Pinning.new
    obj.clean
    abort if obj.failure?
  end

  desc '[EXPERIMENTAL] Migrate cookbook dependencies from metadata.rb to Berksfile (for use with dependency:pin task)'
  task :migrate do
    $stdout.puts(Paint['Attempting to migrate dependencies from metadata.rb to Berksfile', :yellow, :bold])
    obj = RordanGramsay::Dependencies::Pinning.new
    obj.migrate
    abort if obj.failure?
    $stdout.puts(Paint['  This may or may not have worked. Please audit the dependencies in Berksfile', :yellow, :bold])
    $stdout.puts(Paint % ['  to ensure they look correct, then run %{cmd}', :yellow, :bold, cmd: Paint['rake dependency:update', :white, :bold]])
  end

  desc 'Update dependency graph'
  task :update do
    $stdout.puts(Paint['Updating Berksfile.lock', :yellow, :bold])
    `berks update`

    $stdout.puts(Paint['Pinning dependencies from Berksfile to metadata.rb', :yellow, :bold])
    obj = RordanGramsay::Dependencies::Pinning.new
    obj.call
    abort if obj.failure?
  end

  desc 'Pin dependencies'
  task :pin do
    $stdout.puts(Paint['Pinning dependencies from Berksfile to metadata.rb', :yellow, :bold])
    obj = RordanGramsay::Dependencies::Pinning.new
    obj.call
    abort if obj.failure?
  end
end

# rubocop:enable Lint/UnneededCopDisableDirective
