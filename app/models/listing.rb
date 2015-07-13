class Listing < ActiveRecord::Base
  has_many :pictures, dependent: :destroy
  accepts_nested_attributes_for :pictures
  serialize :similar

  def similars
    Listing.find(similar) if similar.present?
  end

  def id_title_price
    id.to_s + " - " + title.to_s + " - " + price.to_s
  end

end
