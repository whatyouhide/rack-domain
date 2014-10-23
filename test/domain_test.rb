# enconding: UTF-8

require_relative 'test_helper'

LOBSTER = lambda { |env| [200, {}, ['Lobstericious']] }
NOT_FOUNDER = lambda { |env| [404, {}, ['Error']] }

class DomainTest < Minitest::Test
  include Rack::Test::Methods

  BASE_URL = 'http://example.com'
  BASE_URL_WITH_SUBDOMAIN = 'http://api.example.com'

  def test_with_a_single_specific_domain
    set_app_to do
      use Rack::Domain, 'api.example.com', run: LOBSTER
      run NOT_FOUNDER
    end

    assert_dispatches_to_the_right_app
  end

  def test_with_an_array_of_domains
    set_app_to do
      use Rack::Domain, %w(api.a.b api.example.com), run: LOBSTER
      run NOT_FOUNDER
    end

    assert_dispatches_to_the_right_app
  end

  def test_with_single_regexps
    [/^api\./, /.+/, /example/, /\.com$/].each do |regexp|
      set_app_to do
        use Rack::Domain, regexp, run: LOBSTER
        run NOT_FOUNDER
      end

      assert_dispatches_to_the_right_app
    end
  end

  def test_with_an_array_of_regexps
    set_app_to do
      use Rack::Domain, [/api/, /test/], run: LOBSTER
      run NOT_FOUNDER
    end

    assert_dispatches_to_the_right_app
  end

  def test_matching_with_a_mixed_array
    set_app_to do
      use Rack::Domain, [/api/, 'api.example.com'], run: LOBSTER
      run NOT_FOUNDER
    end
  end

  def test_with_a_block
    ['api.example.com', /example/, /\.com$/].each do |filter|
      set_app_to do
        use(Rack::Domain, filter) { run LOBSTER }
        run NOT_FOUNDER
      end

      assert_dispatches_to_the_right_app
    end
  end

  def test_argument_errors
    # Both a block and a :run option.
    assert_app_raises ArgumentError do
      use(Rack::Domain, 'api', run: LOBSTER) { lob }
      run LOBSTER
    end

    # No filter specified.
    assert_app_raises ArgumentError do
      use(Rack::Domain, {}) { run LOBSTER }
      run LOBSTER
    end

    # No arguments passed.
    assert_app_raises ArgumentError do
      use(Rack::Domain)
      run LOBSTER
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
