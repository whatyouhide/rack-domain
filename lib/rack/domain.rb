require 'rack/domain/version'

# This Rack middleware allows to intercept requests and route them to different
# apps based on the domain (full, with subdomains and the TLD).
class Rack::Domain
  # Create a new instance of this middleware.
  # **Note** that this method is the method called by `Rack::Builder#use`.
  #
  # @param [#call] next_app The next app on the stack, filled automatically by
  #   Rack when building the middlware chain.
  # @param [String, Regexp] filter The filter used to, well, filter the domain.
  #   If `filter` is a `String`, it will be matched *at the beginning* of the
  #   domain name; this is done so that it's easy to match subdomains and
  #   domains without TLDs.
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
  # @return [Boolean]
  def domain_matches?
    case @filter
    when Regexp
      @filter =~ @domain
    when String
      @domain.start_with?(@filter)
    else
      fail 'The filter must be a Regexp or a String'
    end
  end
end
