# This is a private gem so we will not actually be publishing it to rubygems.org
ENV['gem_push'] = 'no'

require 'bundler/gem_tasks'

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
  # no rspec available
end

task :_guard_against_focus do
  tpl_focus = '`focus` tag should not be committed. (%s)'
  tpl_fdesc = '`focus` tag controls (`fdescribe`, `fcontext`, `fits`) should not be committed. (%s)'
  errors = []

  Dir.glob('spec/**/*_spec.rb') do |file|
    File.foreach(file) do |content|
      focus_tag = [
        /(?:\W|^)(?:it|describe|context).+,\s*focus:\s+\w+.*\s+(?:do|{)/i,
        /(?:\W|^)(?:it|describe|context).+,\s*:focus\s+=>\s+\w+.*\s+(?:do|{)/i,
        /(?:\W|^)(?:it|describe|context).+,\s*'focus'\s+=>\s+\w+.*\s+(?:do|{)/i,
        /(?:\W|^)(?:it|describe|context).+,\s*"focus"\s+=>\s+\w+.*\s+(?:do|{)/i
      ].any? { |regexp| content =~ regexp }

      focus_control = [
        /(?:\W|^)f(?:it|describe|context).+\s+(?:do|{)/i
      ].any? { |regexp| content =~ regexp }

      errors << tpl_focus % file.inspect if focus_tag
      errors << tpl_fdesc % file.inspect if focus_control
    end
  end

  abort "PRECONDITION FAILURE:\n\t- #{errors.join("\n\t- ")}" unless errors.empty?
end

task ci: %w(_guard_against_focus spec)

task default: %w(spec)
