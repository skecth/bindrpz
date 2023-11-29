class AddNumberOfDomainToFeed < ActiveRecord::Migration[7.0]
  def change
    add_column :feeds, :number_of_domain, :integer, default: 0
  end
end
