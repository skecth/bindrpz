class CreateFeeds < ActiveRecord::Migration[7.0]
  def change
    create_table :feeds do |t|
      t.integer :blacklist_type
      t.string :source
      t.string :url
      t.string :feed_name
      t.string :feed_path
      t.timestamps
    end
  end
end
