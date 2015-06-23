class AddExternalIdToListings < ActiveRecord::Migration
  def change
    add_column :listings, :external_id, :string
  end
end
