require_relative 'test_helper'

NOT_FOUNDER = lambda { |env| [404, {}, ['Error']] }
LOBSTER = Rack::Builder.new do
  map('/lobster') { run Rack::Lobster.new }
  map('/') { run NOT_FOUNDER }
end

class DomainTest < Minitest::Test
  include Rack::Test::Methods

  BASE_URL = 'http://example.com'
  BASE_URL_WITH_SUBDOMAIN = 'http://api.example.com'

  def test_with_a_string
    %w(api api.example api.example.com).each do |str|
      set_app_to do
        use Rack::Domain, str, run: Rack::Lobster.new
        run NOT_FOUNDER
      end

      assert_dispatches_to_the_right_app
    end
  end

  def test_with_regexps
    [/^api\./, /.+/, /example/, /\.com$/].each do |regexp|
      set_app_to do
        use Rack::Domain, regexp, run: Rack::Lobster.new
        run NOT_FOUNDER
      end

      assert_dispatches_to_the_right_app
    end
  end

  def test_with_a_block
    ['api', 'api.exam', /example/, /\.com$/].each do |filter|
      set_app_to do
        use Rack::Domain, filter do
          run Rack::Lobster.new
        end

        run NOT_FOUNDER
      end

      assert_dispatches_to_the_right_app
    end
  end

  def test_rack_builder_dsl_extension
    require 'rack/domain/dsl'

    set_app_to do
      domain 'api', run: Rack::Lobster.new
      run NOT_FOUNDER
    end
    assert_dispatches_to_the_right_app

    set_app_to do
      domain /^api\./, run: Rack::Lobster.new
      run NOT_FOUNDER
    end
    assert_dispatches_to_the_right_app
  end

  def test_argument_errors
    assert_app_raises ArgumentError do
      lob = Rack::Lobster.new
      use(Rack::Domain, 'api', { run: Rack::Lobster.new }) { lob }
      run lob
    end
  end

  private

  def set_app_to(app = nil, &block)
    define_singleton_method(:app) do
      app || Rack::Builder.new(&block)
    end
  end

  def assert_app_raises(error, &block)
    assert_raises error do
      set_app_to(&block)
      get '/'
    end
  end

  def assert_dispatches_to_the_right_app
    get BASE_URL
    assert last_response.not_found?,
      'The app was intercepted when it should not have been'

    get BASE_URL_WITH_SUBDOMAIN
    assert_lobster_responded
  end

  def assert_lobster_responded
    assert last_response.ok?,
      "The response was #{last_response.status} instead of 200 OK"
    assert last_response.body.include?('Lobstericious'),
      'The run app was not Rack::Lobster'
  end

end
