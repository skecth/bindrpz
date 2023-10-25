class AddCategoryToDomain < ActiveRecord::Migration[7.0]
  def change
    add_reference :domains, :category, null: true, foreign_key: true
  end
end
