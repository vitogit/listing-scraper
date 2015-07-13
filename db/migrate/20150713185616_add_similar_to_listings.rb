class AddSimilarToListings < ActiveRecord::Migration
  def change
    add_column :listings, :similar, :text
  end
end
