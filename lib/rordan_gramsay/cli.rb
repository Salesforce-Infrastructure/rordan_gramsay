require 'optparse'
require 'ostruct'

require_relative 'version'

module RordanGramsay
  # :nodoc:
  class CLI
    attr_reader :opt

    def initialize(args)
      @action_status = :not_started
      @opt = OpenStruct.new
      @opt.force = false
      @opt.debug = false
      @args = args
      @parser = setup_parser
      @parser.parse(@args)
      @action = @args.shift unless @args.empty?
      @subject = @args.shift unless @args.empty?
    end

    def call
      return unless @action_status == :not_started

      case @action
      when 'init'
        action_init!
      else
        $stderr.puts "Unknown action: #{@action.inspect}"
        $stderr.puts @parser
      end
      @action_status = :complete
    end

    private

    def action_init!
      case @subject
      when /^rakefile$/i
        init_rakefile!
      when /(?:chef[_-])?(?:master|server)[_-]?rakefile$/i
        init_master_rakefile!
      else
        $stderr.puts "Unknown subject: #{@subject.inspect}"
        $stderr.puts @parser
      end
    end

    def cookbook_rakefile_contents
      <<-EOF
require '#{GEM_NAME}/chef_tasks/kitchen'
require '#{GEM_NAME}/chef_tasks/lint'
require '#{GEM_NAME}/chef_tasks/test'

task default: ['lint']
# Further rake tasks go here
      EOF
    end

    def init_rakefile!
      if File.exist? 'Rakefile'
        puts 'Rakefile already exists.'
        return unless @opt.force
        puts 'Overwriting...'
      end

      write_to_rakefile cookbook_rakefile_contents

      puts 'Created Rakefile in current directory for handling the cookbook development lifecycle'
    end

    def master_rakefile_contents
      <<-EOF
require '#{GEM_NAME}/chef_tasks/master_repo'
      EOF
    end

    def init_master_rakefile!
      if File.exist? 'Rakefile'
        puts 'Rakefile already exists.'
        return unless @opt.force
        puts 'Overwriting...'
      end

      write_to_rakefile master_rakefile_contents

      puts 'Created Rakefile in current directory for handling multiple, nested cookbooks'
    end

    def write_to_rakefile(content)
      File.write('Rakefile', content)
    end

    def setup_parser
      OptionParser.new do |o|
        o.banner = "Usage: #{EXECUTABLE} [options] [action] [subject]"

        o.separator ''
        o.separator 'Possible actions: {init}'

        o.separator ''
        o.separator 'Possible subjects: {Rakefile,MasterRakefile}'

        o.separator ''
        o.separator 'Common options:'

        o.on('--force', 'Disregard safeguards and clobber things') do
          @opt.force = true
        end

        o.on('-d', '--debug', 'Debugging output') do
          @opt.debug = true
        end

        o.on_tail('--version', 'Show version') do
          puts "#{EXECUTABLE} v#{VERSION}"
          @action_status = :complete
        end

        o.on_tail('-h', '--help', 'Show this message') do
          puts o
          @action_status = :complete
        end
      end
    end
  end
end
