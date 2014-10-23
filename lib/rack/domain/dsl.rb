require 'rack/domain'

# This class is monkeypatched with the `#domain` method.
class Rack::Builder
  # Behaves just like `use Rack::Domain`, but with a simpler and clearer syntax.
  # @param [String, Regexp] filter The filter used to match the domain.
  # @param [#call, nil] app_to_run The app to run if the domain matches, or nil
  #   if a `Rack::Builder`-like block is passed.
  # @raise [ArgumentError] if no app to run or block were passed, or if both
  #   were passed.
  def domain(filter, app_to_run = nil, &block)
    use(Rack::Domain, filter, app_to_run, &block)
  end
end
