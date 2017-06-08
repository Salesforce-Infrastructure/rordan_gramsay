require_relative 'file'

module RordanGramsay
  module Foodcritic
    # :nodoc:
    class FileList
      include Enumerable

      def initialize
        # Hash is keyed by the filename, for more efficient access
        @files = Hash.new { |hash, key| hash[key] = Foodcritic::File.new(key) }
      end

      def each
        @files.each do |_, f|
          yield f
        end
      end

      def failures?
        @files.any? { |(_, f)| f.failed? }
      end

      def <<(value)
        value = Foodcritic::File.new(value) unless value.is_a?(Foodcritic::File)
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
