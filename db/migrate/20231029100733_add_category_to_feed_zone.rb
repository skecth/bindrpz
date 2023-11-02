class AddCategoryToFeedZone < ActiveRecord::Migration[7.0]
  def change
    add_reference :feed_zones, :category, null: true, foreign_key: true
  end
end
