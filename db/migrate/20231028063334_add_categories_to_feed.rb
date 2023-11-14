class AddCategoriesToFeed < ActiveRecord::Migration[7.0]
  def change
    add_reference :feeds, :category, null: false, foreign_key: true
  end
end
