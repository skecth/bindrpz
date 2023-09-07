class AddParameterToAttribute < ActiveRecord::Migration[7.0]
  def change
    add_column :categories, :content,:string
  end
end
