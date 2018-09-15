require_relative 'base'

module RordanGramsay
  module Lint
    # Tests the cookbook's Test Kitchen profile
    class KitchenChecker < Base
      # Model for each file used by KitchenChecker
      class KitchenFile
        attr_reader :file_name

        def initialize(file_name)
          @file_name = file_name

          @lines = File.read(file_name).lines
        end

        # Only use Inspec as the integration test suite
        def inspec?
          @inspec ||= @lines.any? do |line|
            break true if line =~ /^.*(?<!#).*inspec\s*$/i

            false
          end
        end

        # Just in case default for the box is not set to headless,
        # all Windows VMs should have "gui: false" by default
        def no_windows_gui?
          @no_windows_gui ||= begin
            if @lines.any? { |line| line =~ /winrm/i }
              @lines.any? { |line| line =~ /^.*(?<!#).*\s+gui:\s+(?:false|no?|off)\s*$/i }
            else
              true
            end
          end
        end
      end

      def initialize
        @files = files.map { |file| KitchenFile.new(file) }
        @done = false
        @error_count = 0
      end

      def call
        @error_count = 0

        @files.each do |file|
          errors = []
          # errors << :windows_vm_not_headless unless file.no_windows_gui?
          errors << :missing_inspec_verifier unless file.inspec?

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
        Dir.glob("#{base_dir}/.kitchen.yml")
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
