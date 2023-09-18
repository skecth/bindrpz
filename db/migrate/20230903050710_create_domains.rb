class CreateDomains < ActiveRecord::Migration[7.0]
  def change
    create_table :domains do |t|
      t.string :URL,unique: true
      t.string :list_domain
      t.string :source
      t.string :category
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
