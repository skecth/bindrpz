class CreateZones < ActiveRecord::Migration[7.0]
  def change
    create_table :zones do |t|
      t.string :name
      t.text :description
      t.string :zone_path
      t.timestamps
    end
  end
end
