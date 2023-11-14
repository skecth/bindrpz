require "application_system_test_case"

class CustomBlacklistsTest < ApplicationSystemTestCase
  setup do
    @custom_blacklist = custom_blacklists(:one)
  end

  test "visiting the index" do
    visit custom_blacklists_url
    assert_selector "h1", text: "Custom blacklists"
  end

  test "should create custom blacklist" do
    visit custom_blacklists_url
    click_on "New custom blacklist"

    fill_in "Action", with: @custom_blacklist.action
    fill_in "Blacklist type", with: @custom_blacklist.blacklist_type
    fill_in "Category", with: @custom_blacklist.category
    fill_in "Destination", with: @custom_blacklist.destination
    fill_in "Domain", with: @custom_blacklist.domain
    fill_in "File", with: @custom_blacklist.file
    fill_in "Kind", with: @custom_blacklist.kind
    click_on "Create Custom blacklist"

    assert_text "Custom blacklist was successfully created"
    click_on "Back"
  end

  test "should update Custom blacklist" do
    visit custom_blacklist_url(@custom_blacklist)
    click_on "Edit this custom blacklist", match: :first

    fill_in "Action", with: @custom_blacklist.action
    fill_in "Blacklist type", with: @custom_blacklist.blacklist_type
    fill_in "Category", with: @custom_blacklist.category
    fill_in "Destination", with: @custom_blacklist.destination
    fill_in "Domain", with: @custom_blacklist.domain
    fill_in "File", with: @custom_blacklist.file
    fill_in "Kind", with: @custom_blacklist.kind
    click_on "Update Custom blacklist"

    assert_text "Custom blacklist was successfully updated"
    click_on "Back"
  end

  test "should destroy Custom blacklist" do
    visit custom_blacklist_url(@custom_blacklist)
    click_on "Destroy this custom blacklist", match: :first

    assert_text "Custom blacklist was successfully destroyed"
  end
end
