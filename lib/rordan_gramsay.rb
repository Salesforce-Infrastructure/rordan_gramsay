require_relative 'rordan_gramsay/version'

# :nodoc:
module RordanGramsay
  def self.silence_warnings
    original_verbosity = $VERBOSE
    $VERBOSE = nil
    yield
    $VERBOSE = original_verbosity
  end

  def self.stream_command(cmd)
    require 'pty'
    PTY.spawn(cmd) do |stdout, _stdin, _pid|
      begin
        stdout.each { |line| $stdout.puts(line) }
      rescue Errno::EIO
        nil # noop
      end
    end
  rescue PTY::ChildExited
    nil # noop
  end
end
