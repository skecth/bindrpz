class AddCustomBlacklistToZone < ActiveRecord::Migration[7.0]
  def change
    add_reference :custom_blacklists, :zone, null: false, foreign_key: true
    add_reference :custom_blacklists, :category, null: false, foreign_key: true
  end
end
