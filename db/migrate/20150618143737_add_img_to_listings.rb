class AddImgToListings < ActiveRecord::Migration
  def change
    add_column :listings, :img, :string
  end
end
