class AddSourceToDomain < ActiveRecord::Migration[7.0]
  def change
    add_reference :domains, :source, null: false, foreign_key: true
  end
end
