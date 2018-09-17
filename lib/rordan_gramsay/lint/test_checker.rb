require 'paint'
require_relative 'base'

module RordanGramsay
  module Lint
    # Confirms the state of the cookbook's Inspec tests
    #
    # This does not do any testing of nested inspec profiles themselves,
    # only the tests that are defined within. Checks inspec tests in the
    # `controls/` directory if it detects the directory is for an inspec
    # profile, otherwise it checks for files
    class TestChecker < Base
      # Model for each file used by TestChecker
      class TestFile
        attr_reader :file_name

        def initialize(file_name)
          @file_name = file_name

          @lines = File.read(file_name).lines
        end

        def encoding?
          # NOTE: Only allow utf-8 encoding at this time
          @encoding ||= @lines.any? { |line| line =~ /^.*#\s*encoding:\s+(?:utf-8)\s*$/ }
        end

        def tests?
          @tests ||= @lines.any? { |line| line =~ /^.*(?<!#).*describe[\s\(].*$/ }
        end

        def controls?
          @controls ||= @lines.any? { |line| line =~ /^.*(?<!#).*control[\s\(].*$/ }
        end
      end

      def initialize
        @files = files.map { |file| TestFile.new(file) }
        @done = false
        @error_count = 0
      end

      def call
        @error_count = 0

        @files.each do |file|
          errors = []
          # errors << :missing_encoding_line unless file.encoding?
          errors << :missing_tests unless file.tests?

          # compile the error message
          if errors.empty?
            puts format_success_message(file)
          else
            @error_count += 1
            puts format_error_message(file, errors)
          end
        end

        if files.count.nonzero?
          puts Paint % ["\n  Files to fix: %{files_count}", :white, :bold, files_count: Paint[@error_count.to_s, (@error_count / files.count) > 0.40 ? :red : :yellow, :bold]] if @error_count.nonzero?
        end

        @done = true
      end

      def error_count
        raise 'Accessing results before the task has executed' unless @done
        @error_count
      end

      def files
        Dir.glob("#{base_dir}/test/*/*").map do |dir|
          if File.exist?(File.join(dir, 'inspec.yml'))
            Dir.glob("#{dir}/controls/*.rb")
          else
            Dir.glob("#{dir}/**/*_test.rb")
          end
        end.flatten
      end

      private

      def format_error_message(file, errors)
        Paint % ['  %{filename} : %{result} due to %{errors}', :white, filename: Paint[nice_filename(file.file_name), :white, :bold], result: Paint['Failed', :red, :bold], errors: errors.map { |e| Paint[e.to_s, :red] }.join(Paint[', ', :white])]
      end

      def format_success_message(file)
        Paint % ['  %{filename} : %{result}', :white, filename: Paint[nice_filename(file.file_name), :white, :bold], result: Paint['Passed', :green, :bold]]
      end
    end
  end
end
