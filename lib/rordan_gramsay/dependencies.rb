require 'English'
require 'berkshelf'
require 'chef/cookbook/metadata'
require_relative 'exceptions'

module RordanGramsay
  module Dependencies
    # Only exists to make skipping through a loop easier
    class NextIteration < StandardError; end

    # Mixin for having a programmatic accessor for certain cookbook files
    module FileAccessor
      private

      def metadata
        @metadata ||= begin
          raise FileMissing, 'metadata.rb' unless ::File.exist?('metadata.rb')

          ::Chef::Cookbook::Metadata.new.tap { |o| o.from_file('metadata.rb') }
        end
      end

      def berksfile
        @berksfile ||= begin
          raise FileMissing, 'Berksfile' unless ::File.exist?('Berksfile')

          ::Berkshelf::Berksfile.from_file('Berksfile')
        end
      end

      def berksfile_lock
        @berksfile_lock ||= begin
          raise FileMissing, 'Berksfile.lock' unless ::File.exist?('Berksfile.lock')

          ::Berkshelf::Lockfile.from_berksfile(berksfile)
        end
      rescue FileMissing
        $stdout.puts('berks install')
        out = `berks install`
        retry if $CHILD_STATUS.success?
        raise out
      end
    end

    # :nodoc:
    class Pinning
      extend Forwardable
      include FileAccessor

      def initialize
        @obj = if metadata.name =~ /^(?:role|wrapper)_/i
                 WrapperPinning.new
               else
                 CookbookPinning.new
               end
      end

      def_delegators :@obj, :call, :check, :clean, :migrate, :dependencies, :failure?
    end

    # Most cookbooks should use this, unless you desire a layout
    # where the cookbook represents a versioned runlist and
    # default attributes in its entirety. This would then be known
    # as a role- or a wrapper-cookbook and instead use the
    # `WrapperPinning` class.
    class CookbookPinning
      include FileAccessor

      def initialize
        @is_fail = false
      end

      def failure?
        @is_fail
      end

      def call
        File.open('metadata.new.rb', 'w') do |fd|
          File.readlines(metadata.source_file).each do |line|
            next if line =~ /\bdepends\b/i
            fd.puts(line)
          end

          dependencies.each do |(cookbook, constraint)|
            old = metadata.dependencies[cookbook]
            if old
              report_change(cookbook, old, constraint)
            else
              report_change(cookbook, '<missing>', constraint)
            end

            fd.puts(%(depends '#{cookbook}', '#{constraint}'))
          end
        end

        File.rename('metadata.new.rb', metadata.source_file)
        @metadata = nil # Because we just modified it, clear cache
      end

      def clean
        File.open('metadata.new.rb', 'w') do |fd|
          File.readlines(metadata.source_file).each do |line|
            next if line =~ /\bdepends\b/i
            fd.puts(line)
          end
        end

        File.rename('metadata.new.rb', metadata.source_file)
        @metadata = nil # Because we just modified it, clear cache
      end

      def check
        berksfile
        metadata.dependencies.each do |(cookbook, constraint)|
          next if constraint =~ /^\s*~>\s*[1-9][0-9]*\.\d+\s*$/
          next if constraint =~ /^\s*~>\s*0\.\d+\.\d+\s*$/

          correct = corrected_constraint(cookbook, constraint)
          msg = Paint % ['  %{cookbook} : %{actual} (expected: %{constraint})', cookbook: Paint[cookbook, :white, :bold], constraint: Paint[correct, :yellow], actual: Paint[constraint, :red, :bold]]

          log_error(msg)
        end
      rescue FileMissing => e
        log_error(e.to_console)
      end

      def migrate
        # Clear the Berksfile dependencies
        File.open('Berksfile_new', 'w') do |fd|
          File.readlines(berksfile.source_file).each do |line|
            next if line =~ /\bcookbook\b/i
            next if line.strip == 'metadata'
            fd.puts(line)
          end

          metadata.dependencies.each do |(cookbook, constraint)|
            correct = corrected_constraint(cookbook, constraint)

            report_change(cookbook, constraint, correct)

            fd.puts "cookbook '#{cookbook}', '#{correct}'"
          end

          fd.puts ''
          fd.puts 'metadata'
        end

        # Because we just modified it, clear cache
        File.rename('Berksfile_new', berksfile.source_file)
        @berksfile = nil
        File.unlink(berksfile_lock.source_file)
        @berksfile_lock = nil

        clean
        call
      end

      def dependencies
        @dependencies ||= begin
          berksfile.dependencies.each_with_object({}) do |item, deps|
            next if item.name == metadata.name

            constraint = item.version_constraint.to_s
            correct = corrected_constraint(item.name, constraint)

            deps[item.name] = correct
          end
        end
      end

      private

      def version_from_constraint(constraint)
        constraint.strip.gsub(/[^0-9.]+/, '')
      end

      def corrected_constraint(cookbook, constraint)
        # Correct constraints `~> 0.1.0` or `~> 4.9`
        return constraint if constraint =~ /^\s*~>\s*[1-9][0-9]*\.\d+\s*$/
        return constraint if constraint =~ /^\s*~>0\.\d+\.\d+\s*$/

        version = version_from_constraint(constraint).split('.')
        major = version.shift || '0'
        minor = version.shift || '0'
        patch = version.shift || '0'

        if major == '0' && minor == '0' && patch == '0'
          # Pull in the latest version from berksfile_lock and "correct"
          # that version as if it is a constraint. This is so we can apply
          # some sort of reasonable version constraint on `0.0.0` dependencies
          version = berksfile_lock.graph.find(cookbook).version

          corrected_constraint(cookbook, "~> #{version}")
        elsif major == '0'
          "~> #{major}.#{minor}.#{patch}"
        else
          "~> #{major}.#{minor}"
        end
      end

      def report_change(cookbook, previous, now)
        return if previous == now
        $stderr.puts(Paint % ['  %{cookbook} : %{previous} -> %{now}', cookbook: Paint[cookbook, :white, :bold], now: Paint[now, :green], previous: Paint[previous, :yellow]])
      end

      def log_error(msg, opts = {})
        @is_fail = true
        $stderr.puts(msg)
        raise NextIteration if opts[:next]
      end
    end

    # Pinning specifics for role- and wrapper-cookbooks
    class WrapperPinning < CookbookPinning
      def check
        @is_fail = false
        deps = metadata.dependencies.each_with_object({}) do |(cookbook, constraint), dep|
          dep[cookbook] = constraint
        end

        berksfile_lock.graph.each do |item|
          next if item.name == metadata.name

          unless deps.key? item.name
            log_error(Paint % ['  %{cookbook} : %{status}', cookbook: Paint[item.name, :white, :bold], status: Paint['missing', :red, :bold]])
            next
          end
          constraint = deps[item.name]
          expected = "= #{item.version}"

          if constraint != expected
            status = Paint % ['expected %{expected}, actual %{actual}', expected: Paint[expected, :yellow], actual: Paint[constraint, :bold, :red]]
            log_error(Paint % ['  %{cookbook} : %{status}', cookbook: Paint[item.name, :white, :bold], status: status])
            next
          end
        end
      rescue FileMissing => e
        log_error(e.to_console)
      end

      def dependencies
        @dependencies ||= begin
          berksfile_lock.graph.each_with_object({}) do |graph_item, deps|
            next if graph_item.name == metadata.name

            deps[graph_item.name] = "= #{graph_item.version}"
          end
        end
      end
    end
  end
end
