class AddCommentToListings < ActiveRecord::Migration
  def change
    add_column :listings, :comment, :string
  end
end
