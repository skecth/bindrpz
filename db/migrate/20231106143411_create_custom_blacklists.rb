class CreateCustomBlacklists < ActiveRecord::Migration[7.0]
  def change
    create_table :custom_blacklists do |t|
      t.string :file
      t.string :category
      t.integer :blacklist_type
      t.integer :action
      t.string :destination
      t.string :domain
      t.integer :kind

      t.timestamps
    end
  end
end
