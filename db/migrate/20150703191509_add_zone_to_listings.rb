class AddZoneToListings < ActiveRecord::Migration
  def change
    add_column :listings, :zone, :string
  end
end
