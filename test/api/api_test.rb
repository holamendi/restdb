require "test_helper"

class ApiTest < Minitest::Test
  include Rack::Test::Methods

  def app
    App
  end

  def test_root
    get "/"

    assert last_response.ok?
  end

  def test_resource_index_succeeds
    get "/api/users"

    assert last_response.ok?
    assert last_response_json.any?
  end

  def test_resource_index_with_a_valid_filter_succeeds
    get "/api/users?name=Tom Olson"

    assert last_response.ok?
    assert "Tom Olson", last_response_json.first["name"]

    get "/api/users?name=Tom"

    assert last_response.ok?
    assert last_response_json.empty?
  end

  def test_resource_index_with_an_invalid_filter_fails
    get "/api/users?non_existing_column=nope"

    assert_equal 400, last_response.status
  end

  def test_resource_index_fails
    get "/api/invalid"

    assert_equal 404, last_response.status
  end

  def test_resource_show_succeeds
    get "/api/users/1"

    assert last_response.ok?
    assert_equal 1, last_response_json["id"]
  end

  def test_resource_show_fails
    get "/api/users/999"

    assert_equal 404, last_response.status
  end

  private

  def last_response_json
    JSON.parse(last_response.body)
  end
end
