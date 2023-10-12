class CreateFeeds < ActiveRecord::Migration[7.0]
  def change
    create_table :feeds do |t|
      t.string :host
      t.string :domain

      t.timestamps
    end
  end
end
