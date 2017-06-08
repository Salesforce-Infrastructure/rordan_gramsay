require_relative 'rordan_gramsay/version'

# :nodoc:
module RordanGramsay
  def self.silence_warnings
    original_verbosity = $VERBOSE
    $VERBOSE = nil
    yield
    $VERBOSE = original_verbosity
  end
end
