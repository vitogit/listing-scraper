class AddCurrencyToListings < ActiveRecord::Migration
  def change
    add_column :listings, :currency, :string
  end
end
