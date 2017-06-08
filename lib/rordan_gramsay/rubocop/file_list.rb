require_relative 'file'

module RordanGramsay
  module Rubocop
    # :nodoc:
    class FileList
      include Enumerable

      def initialize
        # Hash is keyed by the filename, for more efficient access
        @files = Hash.new { |hash, key| hash[key] = Rubocop::File.new(key) }
      end

      def each
        @files.each do |_, f|
          yield f
        end
      end

      def empty?
        count.zero?
      end

      def failures?
        @files.any? { |(_, f)| f.failed? }
      end

      def <<(value)
        value = Rubocop::File.new(value) unless value.is_a?(Rubocop::File)
        @files[value.name] = value
      end

      def [](key)
        @files[key]
      end

      def filenames
        @files.keys
      end
    end
  end
end
