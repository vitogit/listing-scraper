class CreateListings < ActiveRecord::Migration
  def change
    create_table :listings do |t|
      t.string :title
      t.integer :price
      t.integer :gc
      t.string :address
      t.integer :phone
      t.string :link

      t.timestamps null: false
    end
  end
end
