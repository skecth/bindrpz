class CreateFeedZones < ActiveRecord::Migration[7.0]
  def change
    create_table :feed_zones do |t|
      t.belongs_to :feed, null: true, foreign_key: true
      t.belongs_to :zone, null: false, foreign_key: true
      t.string :selected_action
      t.string :destination
      t.string :file_path
      t.string :zone_name
      t.timestamps
    end
  end
end
