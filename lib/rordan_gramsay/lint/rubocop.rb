require 'json'

require_relative 'base'
require_relative '../rubocop/file_list'
require_relative '../rubocop/rule'

module RordanGramsay
  module Lint
    # :nodoc:
    class Rubocop < Base
      attr_reader :results, :file_list

      def initialize(opts = {})
        @opts = default_opts.merge(opts)
        @file_list = RordanGramsay::Rubocop::FileList.new
        @linter = nil

        json = JSON.parse(`rubocop --require cookstyle --format json`)

        json['files'].each do |file_json|
          file = @file_list[::File.expand_path(file_json['path'])]

          file_json['offenses'].each do |offense_json|
            offense = Struct.new(:code, :name).new(offense_json['cop_name'], offense_json['message'])
            # Don't stick with syntax error specifics here. We're supposed to log general rule descriptions
            offense.name = 'Ruby syntax error' if offense.code == 'Syntax'
            has_failed = fail_severity?(offense_json['severity'])
            line_number = begin
                            offense_json.fetch('location').fetch('line')
                          rescue KeyError
                            1
                          end

            file.rules[line_number] << RordanGramsay::Rubocop::Rule.new(offense, has_failed)
          end
        end
      end

      def files
        @file_list.filenames
      end

      # Outputs the results of RuboCop linting by filename
      #
      #   <space x2><filename> : <result>
      #   <space x4><line num>: <rule codes>
      #
      def call
        @file_list.each do |file|
          result = if file.rules.empty?
                     Paint['Passed', :green, :bold]
                   elsif file.failed?
                     Paint['Failed', :red, :bold]
                   else
                     # Passes with warnings
                     Paint['Passed', :yellow, :bold]
                   end

          $stdout.puts Paint % ['  %{filename} : %{result}', filename: Paint[nice_filename(file.name), :white, :bold], result: result]

          # Print warnings/failures
          file.rules.each do |line, ruleset|
            line_msg = Paint[line, :white]
            rule_msg = ruleset.map { |r| Paint[r.code, :yellow] }.join(', ')
            msg = Paint % ['    Line %{line} violates %{ruleset}', line: line_msg, ruleset: rule_msg]

            $stdout.puts msg
          end
        end
      end

      def failed?
        @file_list.failures?
      end

      def rules
        rules = RordanGramsay::Rubocop::RuleList.new
        @file_list.each do |file|
          file.rules.each do |(_, ruleset)|
            ruleset.each do |rule|
              rules << rule
            end
          end
        end

        rules
      end

      private

      def default_opts
        {
          fail_severity: 'error'
        }
      end

      def fail_severity?(severity)
        severity_map = {
          fatal: 0,
          error: 1,
          warning: 2,
          convention: 3,
          refactor: 4
        }

        minimum_lvl = severity_map.fetch(@opts['fail_severity']) { 99 }
        severity_lvl = severity_map.fetch(severity) { 99 }

        minimum_lvl <= severity_lvl
      end
    end
  end
end
