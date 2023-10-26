class CreateDomains < ActiveRecord::Migration[7.0]
  def change
    create_table :domains do |t|
      t.string :URL,unique: true
      t.text :list_domain
      t.string :source
      t.string :category
      t.string :action
      t.integer :status, default: 0
      t.integer :line_count

      t.timestamps
    end
  end
end
