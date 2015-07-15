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
    puts "Enviando email..."
    NotificationMailer.new_listing_email.deliver!
    puts "Fin."

  end
end
