require_relative '../exceptions'

module RordanGramsay
  module Lint
    # A base class, implementing a unified interface for linting code with various rules
    class Base
      attr_writer :base_dir

      def initialize
        raise MethodNotImplemented, '#initialize'
      end

      def call
        raise MethodNotImplemented, '#call'
      end

      # list of applicable files for this linter
      def files
        raise MethodNotImplemented, '#files'
      end

      def base_dir
        @base_dir ||= Dir.pwd
      end

      def nice_filename(file)
        file.sub(base_dir, '').sub(%r{^\/}i, '')
      end
    end
  end
end
