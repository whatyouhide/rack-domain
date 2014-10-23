# enconding: UTF-8

require 'rack/domain/version'

# This Rack middleware allows to intercept requests and route them to different
# apps based on the domain (full, with subdomains and the TLD).
class Rack::Domain
  # Create a new instance of this middleware.
  # **Note** that this method is the method called by `Rack::Builder#use`.
  #
  # @param [#call] next_app The next app on the stack, filled automatically by
  #   Rack when building the middlware chain.
  #
  # @param [String, Regexp, Array<String, Regexp>] filter The filter used to,
  #   well, filter the domain. If `filter` is a `String`, it will be matched as the
  #   entire domain; if it's a regexp, it will be matched as a regexp. If it's
  #   an array of strings and regexps, it will match if any of the elements of
  #   the array matches the domain as specified above.
  #
  # @param [Hash] opts An hash of options.
  # @option opts [#call, nil] :run The Rack app to run if the domain matches the
  #   filter. If you don't want to pass a ready application, you can pass a
  #   block with `Rack::Builder` syntax which will create a Rack app on-the-fly.
  #
  # @raise [ArgumentError] if both a building block and an app to run were
  #   passed to this function.
  def initialize(next_app, filter, opts = {}, &block)
    if opts[:run] && block_given?
      fail ArgumentError, 'Pass either an app to run or a block, not both'
    end

    @next_app = next_app
    @filter = filter
    @app_to_run = opts[:run]
    @dsl_block = block
  end

  # The `call` method as per the Rack middleware specification.
  # @param [Hash] env The environment passed around in the middlware chain.
  def call(env)
    @domain = Rack::Request.new(env).host
    app = domain_matches? ? app_or_dsl_block : @next_app
    app.call(env)
  end

  private

  # Return the app that was specified to be run if the domain matches or, if the
  # app was specified on-the-fly with a builder block, return a new app created
  # with that block (and `Rack::Builder`).
  # @return [#call]
  def app_or_dsl_block
    @app_to_run || Rack::Builder.new(&@dsl_block)
  end

  # Return `true` if the domain of the current request matches the given
  # `@filter`, `false` otherwise.
  # @raises [ArgumentError] if the filter or array of filters aren't regexps or
  #   strings.
  # @return [Boolean]
  def domain_matches?
    # Force the filter to be an array.
    @filter = [@filter] unless @filter.is_a?(Array)

    # Check if any of the elements of the `@filter` array matches the domain.
    # The matching test is done based on the element's type.
    @filter.any? do |flt|
      if flt.is_a?(Regexp)
        flt =~ @domain
      elsif flt.is_a?(String)
        flt == @domain
      else
        fail ArgumentError, 'The filters must be strings or regexps'
      end
    end
  end
end
