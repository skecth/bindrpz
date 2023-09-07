class CreateRules < ActiveRecord::Migration[7.0]
  def change
    create_table :rules do |t|
      t.string :path
      t.string :content
      t.string :text_rule

      t.timestamps
    end
  end
end
