namespace :general do
  desc "change all listing to gallito"
  task all_from_gallito: :environment do
    Listing.all.each do |e|
      e.from = "gallito"
      e.save
    end
  end

  desc "send notification email"
  task send_notification_email: :environment do
    old_count = Listing.count
    Listing.scrape_gallito
    new_listing_count = Listing.count - old_count
    if new_listing_count > 0
      puts "Enviando email..."
      NotificationMailer.new_listing_email(new_listing_count).deliver!
      puts "Fin."
    end
  end
end
