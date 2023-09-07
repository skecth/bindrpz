class CreateCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :categories do |t|
      t.string :nama
      t.string :url
      t.string :github
      t.string :link

      t.timestamps
    end
  end
end
