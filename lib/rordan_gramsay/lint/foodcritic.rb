require_relative '../../rordan_gramsay'
RordanGramsay.silence_warnings do
  require 'foodcritic'
end

require_relative 'base'
require_relative '../foodcritic/file_list'
require_relative '../foodcritic/rule'

module RordanGramsay
  module Lint
    # :nodoc:
    class Foodcritic < Base
      attr_reader :results, :file_list, :opts

      def initialize(opts = {})
        @opts = default_opts.merge(opts)
        @file_list = RordanGramsay::Foodcritic::FileList.new
        @linter = nil

        RordanGramsay.silence_warnings do
          @linter = ::FoodCritic::Linter.new
          results = @linter.check(@opts.dup)

          paths = @linter.send(:specified_paths!, @opts.dup)
          @linter.send(:files_to_process, paths).each do |f|
            @file_list << f[:filename]
          end

          results.warnings.each do |warn|
            rules = @file_list[warn.match[:filename]].rules
            rules[warn.match[:line].to_i] << RordanGramsay::Foodcritic::Rule.new(warn.rule, warn.failed?)
          end
        end
      end

      def files
        @file_list.filenames
      end

      # Outputs the results of Foodcritic linting by filename
      #
      #   <space x2><filename> : <result>
      #   <space x4><line num>: <rule codes>
      #
      def call
        @file_list.each do |file|
          result = if file.rules.empty?
                     Paint['Pass', :green, :bold]
                   elsif file.failed?
                     Paint['Fail', :red, :bold]
                   else
                     # Passes with warnings
                     Paint['Pass', :yellow, :bold]
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
        rules = RordanGramsay::Foodcritic::RuleList.new
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
          cookbook_paths: [Dir.pwd],
          exclude_paths: %w(test/**/* spec/**/* features/**/*),
          fail_tags: ['any'],
          tags: []
        }
      end
    end
  end
end
