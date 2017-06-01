require_relative 'base'
require 'paint'

module RordanGramsay
  module Lint
    # Checks initial lines of files for comments containing specific content:
    #   - Copyright
    #   - License
    #   - Date
    #   - Author email
    class CookbookCommentsChecker < Base
      # Model for abstracting lint checks for each applicable file
      class CookbookFile
        attr_reader :file_name

        def initialize(file_name)
          @file_name = file_name
          # Limit read to first 30 lines of file
          @lines = File.foreach(file_name).first(30)
        end

        # Detects if authorship line is included
        def author?
          @author ||= @lines.any? do |line|
            break true if line =~ /maintainer/i # "Maintainer(s): "
            break true if line =~ /author/i # "Author(s): "
            break true if line =~ /\w@\w/i # email address
            break true if line =~ /(?:^| )by:? /i # "By John Doe"

            false
          end
        end

        # Detects if copyright line is included
        def copyright?
          @copyright ||= @lines.any? do |line|
            break true if line =~ /(?:^| )\(c\)(?:$| )/i # copyright symbol as "(c)"
            break true if line.includes? '©' # Actual copyright symbol
            break true if line =~ /copyright/i
            break true if line =~ /&copy;/i # HTML entity is still indicative of copyright

            false
          end
        end

        # Detects if there is a date (e.g., copyright date or date of authorship) included
        def date?
          @date ||= @lines.any? do |line|
            break true if line =~ /(?:mon(?:day)?|tue(?:s(?:day)?)?|wed(?:nes(?:day)?)?|thu(?:rs(?:day)?)?|fri(?:day)?|sat(?:urday)?|sun(?:day)?)/i
            break true if line =~ %r{(?:/|-|\(| |^)20[012][0-9](?:/|-|\)| |$)}i # some year between 2000 and 2029
            # Similar to ISO date format (e.g., 2017-03-14, 2010/11/19, 2001/9/3)
            break true if line =~ %r{(?<year>(?:20|19)[0-9][0-9])[/-](?<month>0?[1-9]|1[0-2])[/-](?<day>0?[1-9]|[1,2][0-9]|3[01])}i

            false
          end
        end

        # Detects if references to a license are included (even if "all rights reserved")
        def license?
          @license ||= @lines.any? do |line|
            break true if line =~ /licen[sc]e/i # "License" or "Licence"
            break true if line =~ /all rights(?: reserved)?/i # "All rights reserved"

            # Popular licenses
            break true if line =~ /(?:^|\W)\(?MIT\)?(?:$|\W)/ # "MIT" or "(MIT)"
            break true if line =~ /(?:^|\W)Apache(?:$|\W)/i # "Apache"
            break true if line =~ /(?:^|\W)Creative Commons(?:$|\W)/i
            break true if line =~ /(?:^|\W)GNU Public Licen[sc]e(?:$|\W)/i # "GNU Public License"
            break true if line =~ /(?:^|\W)\(?[AL]?GPL\)?(?:$|\W)/ # GPL, AGPL, LGPL licenses

            false
          end
        end

        # Detects if the first 5 lines of the file are all comment lines
        def leading_comment_lines?
          @leading_comment_lines ||= @lines.first(5).all? { |line| line =~ /^\s*#/i }
          @leading_comment_lines ||= @lines.first(5).any? { |line| line =~ /^\s*=begin(?:$|\W)/i }
        end
      end

      def initialize
        @files = files.map { |f| CookbookFile.new(f) }
        @done = false
        @error_count = 0
      end

      def call
        @error_count = 0
        @files.each do |file|
          errors = []
          # errors << :author unless file.author?
          # errors << :license unless file.license?
          # errors << :copyright unless file.copyright?
          # errors << :date unless file.date?
          errors << :comments_at_top_of_file unless file.leading_comment_lines?

          # Compile the error message
          if errors.empty?
            puts format_success_message(file)
          else
            @error_count += 1
            puts format_error_message(file, errors)
          end
        end

        if files.count > 0
          puts Paint % ["\n  Files to fix: %{files_count}", :white, :bold, files_count: Paint[@error_count.to_s, (@error_count / files.count) > 0.40 ? :red : :yellow, :bold]] if @error_count > 0
        end

        @done = true
      end

      def error_count
        raise 'Accessing results before the task has executed' unless @done
        @error_count
      end

      def files
        Dir.glob("#{base_dir}/{attributes,recipes,libraries}/**/*.rb")
      end

      private

      def format_error_message(file, errors)
        Paint % ['  %{filename} : %{result} due to missing %{errors}', :white, filename: Paint[nice_filename(file.file_name), :white, :bold], result: Paint['Failed', :red, :bold], errors: errors.map { |e| Paint[e.to_s, :red] }.join(Paint[', ', :white])]
      end

      def format_success_message(file)
        Paint % ['  %{filename} : %{result}', :white, filename: Paint[nice_filename(file.file_name), :white, :bold], result: Paint['Passed', :green, :bold]]
      end
    end
  end
end
