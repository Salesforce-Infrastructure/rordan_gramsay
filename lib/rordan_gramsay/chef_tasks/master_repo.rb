require 'logger'
require 'pty'

require_relative '../version'

def run_command(cmd, log)
  system("#{RordanGramsay::EXECUTABLE} init rakefile") unless File.exist? 'Rakefile'

  # rubocop:disable Lint/HandleExceptions
  log.info "Running `#{cmd}`"

  # Requires use of PTY so we can get incremental results instead of
  # pausing until subprocess exits, which then spits out all results
  PTY.spawn(cmd) do |stdout, _stdin, _pid|
    begin
      stdout.each { |line| log.info line }
    rescue Errno::EIO
      # Finished giving output or otherwise a broken pipe
    end
  end

  log.info 'Cleaning up...'
end

def each_cookbook(_throttle = 3, outfile = STDOUT, &_block)
  out = Logger.new(outfile)
  out.formatter = proc { |_, _, _, msg| "#{(msg || '').chomp}\n" }
  out.level = :info
  pwd = Dir.pwd

  Dir["#{pwd}/cookbooks/*"].each do |cookbook_dir|
    next unless File.directory? cookbook_dir

    Dir.chdir(cookbook_dir) do |_|
      # 'cookbooks/some_cookbook' instead of '~/derp/cookbooks/some_cookbook'
      relative_dir = cookbook_dir.sub(pwd, '').sub(%r{^/}, '')
      yield out, relative_dir
    end
  end
end

namespace :kitchen do
  task :test do
    each_cookbook do |log, dir|
      log.info "Directory: #{dir.inspect}"
      run_command 'rake kitchen:test', log
    end
  end

  namespace :danger do
    task :create do
      each_cookbook do |log, dir|
        log.info "Directory: #{dir.inspect}"
        run_command 'rake kitchen:create', log
      end
    end

    task :converge do
      each_cookbook do |log, dir|
        log.info "Directory: #{dir.inspect}"
        run_command 'rake kitchen:converge', log
      end
    end

    task :verify do
      each_cookbook do |log, dir|
        log.info "Directory: #{dir.inspect}"
        run_command 'rake kitchen:verify', log
      end
    end
  end

  task :destroy do
    each_cookbook do |log, dir|
      log.info "Directory: #{dir.inspect}"
      run_command 'rake kitchen:destroy', log
    end
  end
end
task kitchen: ['kitchen:test']

namespace :lint do
  task :all do
    each_cookbook do |log, dir|
      log.info "Directory: #{dir.inspect}"
      run_command 'rake lint:all', log
    end
  end

  task :rubocop do
    each_cookbook do |log, dir|
      log.info "Directory: #{dir.inspect}"
      run_command 'rake lint:rubocop', log
    end
  end

  task :foodcritic do
    each_cookbook do |log, dir|
      log.info "Directory: #{dir.inspect}"
      run_command 'rake lint:foodcritic', log
    end
  end

  task :comments do
    each_cookbook do |log, dir|
      log.info "Directory: #{dir.inspect}"
      run_command 'rake lint:comments', log
    end
  end

  task :tests do
    each_cookbook do |log, dir|
      log.info "Directory: #{dir.inspect}"
      run_command 'rake lint:tests', log
    end
  end

  task :kitchen do
    each_cookbook do |log, dir|
      log.info "Directory: #{dir.inspect}"
      run_command 'rake lint:kitchen', log
    end
  end
end
desc 'Runs linting, style checks, and overall formatting checks for each cookbook'
task lint: ['lint:all']

namespace :test do
  task :all do
    each_cookbook do |log, dir|
      log.info "Directory: #{dir.inspect}"
      run_command 'rake test:all', log
    end
  end

  task slow: ['kitchen:test']
  task quick: ['lint:all']
end
desc 'Runs all linting and tests on all cookbooks'
task test: ['test:all']

task default: ['test:all']
