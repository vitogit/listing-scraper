class AddDeletedToListings < ActiveRecord::Migration
  def change
    add_column :listings, :deleted, :bool, default:false
  end
end
