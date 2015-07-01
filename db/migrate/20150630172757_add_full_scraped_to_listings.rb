class AddFullScrapedToListings < ActiveRecord::Migration
  def change
    add_column :listings, :full_scraped, :boolean
  end
end
