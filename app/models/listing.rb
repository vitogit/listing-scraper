class Listing < ActiveRecord::Base
  has_many :pictures, dependent: :destroy
  accepts_nested_attributes_for :pictures
  serialize :similar

  # def similars
  #   Listing.find(similar) if similar.present?
  # end

  def id_title_price
    id.to_s + " - " + title.to_s + " - " + price.to_s
  end

  def self.scrape_ml
    @listings = []
    max_pages = 20
    dolar_to_pesos = 28.5
    max_price = 18000
    urls = ['http://inmuebles.mercadolibre.com.uy/apartamentos/alquiler/montevideo/pocitos/_PriceRange_0-18000_Ambientes_3',
            'http://inmuebles.mercadolibre.com.uy/apartamentos/alquiler/montevideo/cordon/_PriceRange_0-18000_Ambientes_3',
            'http://inmuebles.mercadolibre.com.uy/apartamentos/alquiler/montevideo/parque-batlle/_PriceRange_0-18000_Ambientes_3',                        
            'http://inmuebles.mercadolibre.com.uy/apartamentos/alquiler/montevideo/parque-rodo/_PriceRange_0-18000_Ambientes_3',                        
            'http://inmuebles.mercadolibre.com.uy/apartamentos/alquiler/montevideo/pocitos-nuevo/_PriceRange_0-18000_Ambientes_3',                        
            'http://inmuebles.mercadolibre.com.uy/apartamentos/alquiler/montevideo/tres-cruces/_PriceRange_0-18000_Ambientes_3',                        

            'http://inmuebles.mercadolibre.com.uy/apartamentos/alquiler/montevideo/pocitos/_PriceRange_0-18000_Ambientes_4',
            'http://inmuebles.mercadolibre.com.uy/apartamentos/alquiler/montevideo/cordon/_PriceRange_0-18000_Ambientes_4',
            'http://inmuebles.mercadolibre.com.uy/apartamentos/alquiler/montevideo/parque-batlle/_PriceRange_0-18000_Ambientes_4',                        
            'http://inmuebles.mercadolibre.com.uy/apartamentos/alquiler/montevideo/parque-rodo/_PriceRange_0-18000_Ambientes_4',                        
            'http://inmuebles.mercadolibre.com.uy/apartamentos/alquiler/montevideo/pocitos-nuevo/_PriceRange_0-18000_Ambientes_4',                        
            'http://inmuebles.mercadolibre.com.uy/apartamentos/alquiler/montevideo/tres-cruces/_PriceRange_0-18000_Ambientes_4', 
            ]

    old_count = Listing.count
    urls.each do |url|
      agent = Mechanize.new
      pages = 0

      begin
        page = agent.get(url)
        raw_listings = page.search(".item-realestate-inner .item-content")
      rescue Exception => e
        raw_listings = []
      end

      raw_listings.each do |raw_listing|
        listing = Listing.new
        listing.from = "ml"
        listing.similar = []

        listing.link = raw_listing.at('a').attributes['href']
        listing.external_id = listing.link.split('-')[1]
        old_listing = Listing.find_by_external_id(listing.external_id)

        listing.title = raw_listing.at('.item-title').text
        listing.img = raw_listing.at('img').attributes['title'] || raw_listing.at('img').attributes['src'] #in the title is the real url, because with js it load it
        listing.price = raw_listing.at('.ch-price').text[0..-1].gsub(/\D/, '')
        next if old_listing.present? && old_listing.price == listing.price && old_listing.img == listing.img
        next if listing.price > max_price

        if listing.price <= max_price
          # price change, add comment with the old price
          if old_listing.nil?
            listing.save #new listing
          else
            if old_listing.price.present? && old_listing.price != listing.price
              old_listing.comment = "" if old_listing.comment.nil?
              old_listing.comment += " CAMBIO PRECIO antiguo:"+old_listing.price.to_s
              old_listing.price = listing.price
              old_listing.save
            end
            if old_listing.img.present? && old_listing.img != listing.img
              old_listing.comment = "" if old_listing.comment.nil?
              old_listing.comment += " CAMBIO IMAGEN antigua:"+old_listing.img.to_s
              old_listing.img = listing.img
              old_listing.save
            end
          end
        end
      end
    end
  end

  def self.scrape_gallito
    agent = Mechanize.new
    @listings = []
    page = agent.get('http://www.gallito.com.uy/inmuebles/apartamentos/alquiler/montevideo/cordon!parque-batlle!parque-rodo!pocitos!pocitos-nuevo!tres-cruces/2-dormitorios/pre-0-18000-pesos')
    pages = 0
    max_pages = 20
    dolar_to_pesos = 28.5
    max_price = 18000

    # add /ord_rec to sort by recent
    # raw_listings = agent.page.search("#grillaavisos a")
    # return if Listing.find_by_link(raw_listings.first.attributes['href'].to_s).present?

    while  pages < max_pages && page.link_with(text: /Siguiente/)  do
      raw_listings = agent.page.search("#grillaavisos article")
      raw_listings.each do |raw_listing|

        listing = Listing.new
        listing.from = "gallito"
        listing.similar = []

        listing.link = raw_listing.at('.img-seva').attributes['alt'].text
        listing.external_id = listing.link.split('-')[-1]
        old_listing = Listing.find_by_external_id(listing.external_id)
        listing.img = raw_listing.at('.img-seva').attributes['src'].text
        price_selector = raw_listing.at('.contenedor-info strong')
        listing.price = price_selector.text.gsub(/\D/, '') if price_selector

        next if old_listing.present? && old_listing.price == listing.price && old_listing.img == listing.img
        next if listing.price > max_price

        listing.currency = price_selector.text.gsub(/[\d^.]/, '') if price_selector
        if listing.currency.strip == "U$S"
          listing.price = listing.price * dolar_to_pesos
          listing.currency = "(c)"
        else
          listing.currency = ""
        end

        listing.title = raw_listing.at('.mas-info h2').text
        # listing.phone = raw_listing.at('.movil a').text.gsub(/\s+/, "")

        if listing.price <= max_price
          # price change, add comment with the old price
          if old_listing.nil?
            listing.save #new listing
          else
            if old_listing.price.present? && old_listing.price != listing.price
              old_listing.comment = "" if old_listing.comment.nil?
              old_listing.comment += " CAMBIO PRECIO antiguo:"+old_listing.price.to_s
              old_listing.price = listing.price
              old_listing.save
            end
            if old_listing.img.present? && old_listing.img != listing.img
              old_listing.comment = "" if old_listing.comment.nil?
              old_listing.comment += " CAMBIO IMAGEN antigua:"+old_listing.img.to_s
              old_listing.img = listing.img
              old_listing.save
            end
          end
        end
      end
      next_page = page.link_with(text: /Siguiente/)
      page = next_page.click
      pages += 1
    end
  end
end
