require "test_helper"

class RpzdataControllerTest < ActionDispatch::IntegrationTest
  test "should get domain:string" do
    get rpzdata_domain:string_url
    assert_response :success
  end

  test "should get category:string" do
    get rpzdata_category:string_url
    assert_response :success
  end

  test "should get action:string" do
    get rpzdata_action:string_url
    assert_response :success
  end
end
