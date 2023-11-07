require "test_helper"

class CustomBlacklistsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @custom_blacklist = custom_blacklists(:one)
  end

  test "should get index" do
    get custom_blacklists_url
    assert_response :success
  end

  test "should get new" do
    get new_custom_blacklist_url
    assert_response :success
  end

  test "should create custom_blacklist" do
    assert_difference("CustomBlacklist.count") do
      post custom_blacklists_url, params: { custom_blacklist: { action: @custom_blacklist.action, blacklist_type: @custom_blacklist.blacklist_type, category: @custom_blacklist.category, destination: @custom_blacklist.destination, domain: @custom_blacklist.domain, file: @custom_blacklist.file, kind: @custom_blacklist.kind } }
    end

    assert_redirected_to custom_blacklist_url(CustomBlacklist.last)
  end

  test "should show custom_blacklist" do
    get custom_blacklist_url(@custom_blacklist)
    assert_response :success
  end

  test "should get edit" do
    get edit_custom_blacklist_url(@custom_blacklist)
    assert_response :success
  end

  test "should update custom_blacklist" do
    patch custom_blacklist_url(@custom_blacklist), params: { custom_blacklist: { action: @custom_blacklist.action, blacklist_type: @custom_blacklist.blacklist_type, category: @custom_blacklist.category, destination: @custom_blacklist.destination, domain: @custom_blacklist.domain, file: @custom_blacklist.file, kind: @custom_blacklist.kind } }
    assert_redirected_to custom_blacklist_url(@custom_blacklist)
  end

  test "should destroy custom_blacklist" do
    assert_difference("CustomBlacklist.count", -1) do
      delete custom_blacklist_url(@custom_blacklist)
    end

    assert_redirected_to custom_blacklists_url
  end
end
