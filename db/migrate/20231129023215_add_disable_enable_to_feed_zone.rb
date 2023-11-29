class AddDisableEnableToFeedZone < ActiveRecord::Migration[7.0]
  def change
    add_column :feed_zones, :enable_disable_status, :boolean, default: true
  end
end
