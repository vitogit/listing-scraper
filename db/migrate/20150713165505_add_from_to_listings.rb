class AddFromToListings < ActiveRecord::Migration
  def change
    add_column :listings, :from, :string
  end
end
