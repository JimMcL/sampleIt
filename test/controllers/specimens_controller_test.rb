require 'test_helper'

class SpecimensControllerTest < ActionDispatch::IntegrationTest

  test "csv" do
    get '/specimens.csv'
    assert_response :success

    get '/specimens.csv?id=[1,2,3,4,5]'
    assert_response :success
  end

end
