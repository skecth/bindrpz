require "application_system_test_case"

class FeedZonesTest < ApplicationSystemTestCase
  setup do
    @feed_zone = feed_zones(:one)
  end

  test "visiting the index" do
    visit feed_zones_url
    assert_selector "h1", text: "Feed zones"
  end

  test "should create feed zone" do
    visit feed_zones_url
    click_on "New feed zone"

    fill_in "Action", with: @feed_zone.action
    fill_in "Destination", with: @feed_zone.destination
    click_on "Create Feed zone"

    assert_text "Feed zone was successfully created"
    click_on "Back"
  end

  test "should update Feed zone" do
    visit feed_zone_url(@feed_zone)
    click_on "Edit this feed zone", match: :first

    fill_in "Action", with: @feed_zone.action
    fill_in "Destination", with: @feed_zone.destination
    click_on "Update Feed zone"

    assert_text "Feed zone was successfully updated"
    click_on "Back"
  end

  test "should destroy Feed zone" do
    visit feed_zone_url(@feed_zone)
    click_on "Destroy this feed zone", match: :first

    assert_text "Feed zone was successfully destroyed"
  end
end
