# encoding: UTF-8

require 'rack/domain'

# This class is monkeypatched with the `#domain` method.
class Rack::Builder
  # Behaves just like `use Rack::Domain`, but with a simpler and clearer syntax.
  #
  # @param [String, Regexp] filter The filter used to match the domain.
  # @param [Hash] opts An hash of options.
  # @option opts [#call, nil] :run The app to run if the domain matches.
  #
  # @raise [ArgumentError] if no app to run or block were passed, or if both
  #   were passed.
  def domain(filter, opts = {}, &block)
    use(Rack::Domain, filter, opts, &block)
  end
end
