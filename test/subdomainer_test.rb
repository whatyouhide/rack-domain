require_relative 'test_helper'

NOT_FOUNDER = lambda { |env| [404, {}, ['Error']] }

class DomainTest < Minitest::Test
  include Rack::Test::Methods

  BASE_URL = 'http://api.example.com'

  def test_with_a_string
    %w(api api.example api.example.com).each do |str|
      set_app_to do
        use Rack::Domain, str, Rack::Lobster.new
        run NOT_FOUNDER
      end

      assert_dispatches_to_the_right_app
    end
  end

  def test_with_regexps
    [/^api\./, /.+/, /example/, /\.com$/].each do |regexp|
      set_app_to do
        use Rack::Domain, regexp, Rack::Lobster.new
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
      domain 'api', Rack::Lobster.new
      run NOT_FOUNDER
    end
    assert_dispatches_to_the_right_app

    set_app_to do
      domain /^api\./, Rack::Lobster.new
      run NOT_FOUNDER
    end
    assert_dispatches_to_the_right_app
  end

  private

  def set_app_to(app_or_config_ru = nil, &block)
    define_singleton_method(:app) do
      app_or_config_ru || Rack::Builder.new(&block)
    end
  end

  def assert_dispatches_to_the_right_app
    get '/'
    assert last_response.not_found?,
      'The app was intercepted when it should not have been'

    get BASE_URL
    assert last_response.ok?,
      'The app was not intercepted when it should have been'
    assert last_response.body.include?('Lobstericious'),
      'The run app was not Rack::Lobster'
  end
end
