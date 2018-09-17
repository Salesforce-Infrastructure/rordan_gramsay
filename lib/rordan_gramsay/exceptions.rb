module RordanGramsay
  class MethodNotImplemented < StandardError; end

  # :nodoc:
  class FileMissing < StandardError
    attr_reader :name

    def initialize(name)
      @name = name
    end

    def to_s
      "File Missing: #{@name}"
    end

    def to_console
      require 'paint'

      Paint % ['  Missing: %{filename}', filename: Paint[e.name, :red, :bold]]
    end
  end
end
