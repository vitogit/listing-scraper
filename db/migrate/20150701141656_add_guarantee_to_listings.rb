class AddGuaranteeToListings < ActiveRecord::Migration
  def change
    add_column :listings, :guarantee, :string
  end
end
