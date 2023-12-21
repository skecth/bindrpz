class AddUserToZone < ActiveRecord::Migration[7.0]
  def change
    add_reference :zones, :user, null: false, foreign_key: true
  end
end
