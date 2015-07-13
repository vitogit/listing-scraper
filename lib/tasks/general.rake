namespace :general do
  desc "change all listing to gallito"
  task all_from_gallito: :environment do
    Listing.all.each do |e|
      e.from = "gallito"
      e.save
    end 
  end
end
