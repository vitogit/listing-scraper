class AddRankingToListings < ActiveRecord::Migration
  def change
    add_column :listings, :ranking, :integer
  end
end
