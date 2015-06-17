json.array!(@listings) do |listing|
  json.extract! listing, :id, :title, :price, :gc, :address, :phone, :link
  json.url listing_url(listing, format: :json)
end
