require "test_helper"

class FeedZonesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @feed_zone = feed_zones(:one)
  end

  test "should get index" do
    get feed_zones_url
    assert_response :success
  end

  test "should get new" do
    get new_feed_zone_url
    assert_response :success
  end

  test "should create feed_zone" do
    assert_difference("FeedZone.count") do
      post feed_zones_url, params: { feed_zone: { action: @feed_zone.action, destination: @feed_zone.destination } }
    end

    assert_redirected_to feed_zone_url(FeedZone.last)
  end

  test "should show feed_zone" do
    get feed_zone_url(@feed_zone)
    assert_response :success
  end

  test "should get edit" do
    get edit_feed_zone_url(@feed_zone)
    assert_response :success
  end

  test "should update feed_zone" do
    patch feed_zone_url(@feed_zone), params: { feed_zone: { action: @feed_zone.action, destination: @feed_zone.destination } }
    assert_redirected_to feed_zone_url(@feed_zone)
  end

  test "should destroy feed_zone" do
    assert_difference("FeedZone.count", -1) do
      delete feed_zone_url(@feed_zone)
    end

    assert_redirected_to feed_zones_url
  end
end
