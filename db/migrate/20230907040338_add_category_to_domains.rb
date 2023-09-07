class AddCategoryToDomains < ActiveRecord::Migration[7.0]
  def change
    add_reference :domains, :category, null: false, foreign_key: true
  end
end
