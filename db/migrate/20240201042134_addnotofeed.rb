class Addnotofeed < ActiveRecord::Migration[7.0]
  def change
    add_column :feeds, :feed_no, :integer, default: 1
  end
end
