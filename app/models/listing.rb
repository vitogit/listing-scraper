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
    dolar_to_pesos = 26.5
    max_price = 17000
    #barrios punta carretas, pocitos, pocitos-nuevo
    urls = ['http://inmuebles.mercadolibre.com.uy/apartamentos/alquiler/punta-carretas-montevideo/_PriceRange_0-17000_Ambientes_2',
            'http://inmuebles.mercadolibre.com.uy/apartamentos/alquiler/pocitos-montevideo/_PriceRange_0-17000_Ambientes_2',
            'http://inmuebles.mercadolibre.com.uy/apartamentos/alquiler/pocitos-nuevo-montevideo/_PriceRange_0-17000_Ambientes_2',
            'http://inmuebles.mercadolibre.com.uy/apartamentos/alquiler/villa-biarritz-montevideo/_PriceRange_0-17000_Ambientes_2',
            'http://inmuebles.mercadolibre.com.uy/apartamentos/alquiler/punta-carretas-montevideo/_PriceRange_0-17000_Ambientes_3',
            'http://inmuebles.mercadolibre.com.uy/apartamentos/alquiler/pocitos-montevideo/_PriceRange_0-17000_Ambientes_3',
            'http://inmuebles.mercadolibre.com.uy/apartamentos/alquiler/pocitos-nuevo-montevideo/_PriceRange_0-17000_Ambientes_3',
            'http://inmuebles.mercadolibre.com.uy/apartamentos/alquiler/villa-biarritz-montevideo/_PriceRange_0-17000_Ambientes_3',
            'http://inmuebles.mercadolibre.com.uy/apartamentos/alquiler/punta-carretas-montevideo/_PriceRange_0-17000_Ambientes_4',
            'http://inmuebles.mercadolibre.com.uy/apartamentos/alquiler/pocitos-montevideo/_PriceRange_0-17000_Ambientes_4',
            'http://inmuebles.mercadolibre.com.uy/apartamentos/alquiler/pocitos-nuevo-montevideo/_PriceRange_0-17000_Ambientes_4',
            'http://inmuebles.mercadolibre.com.uy/apartamentos/alquiler/villa-biarritz-montevideo/_PriceRange_0-17000_Ambientes_4'
            ]

    old_count = Listing.count
    urls.each do |url|
      agent = Mechanize.new
      pages = 0

      begin
        page = agent.get(url)
        raw_listings = page.search(".article")
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

        listing.title = raw_listing.at('a').text
        listing.img = raw_listing.at('img').attributes['title'] || raw_listing.at('img').attributes['src'] #in the title is the real url, because with js it load it
        listing.price = raw_listing.at('.ch-price').text[0..-3].gsub(/\D/, '')
        next if old_listing.present? && old_listing.price == listing.price && old_listing.img == listing.img
        next if listing.price > max_price 

        if listing.price < max_price
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
    page = agent.get('http://www.gallito.com.uy/inmuebles/apartamentos/alquiler/montevideo/pocitos!pocitos-nuevo!punta-carretas!villa-biarritz/1-dormitorio')
    pages = 0
    max_pages = 20
    dolar_to_pesos = 26.5
    max_price = 17000

    # add /ord_rec to sort by recent
    # raw_listings = agent.page.search("#grillaavisos a")
    # return if Listing.find_by_link(raw_listings.first.attributes['href'].to_s).present?

    while  pages < max_pages && page.link_with(text: /Siguiente/)  do
      raw_listings = agent.page.search("#grillaavisos a")
      raw_listings.each do |raw_listing|

        listing = Listing.new
        listing.from = "gallito"
        listing.similar = []

        listing.link = raw_listing.attributes['href']
        listing.external_id = listing.link.split('-')[-1]
        old_listing = Listing.find_by_external_id(listing.external_id)
        listing.img = raw_listing.at('#div_rodea_datos img').attributes['data-original']
        price_selector = raw_listing.at('.thumb01_precio, .thumb02_precio')
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

        listing.title = raw_listing.at('.thumb_titulo').text
        listing.address = raw_listing.at('.thumb_txt h2').text
        listing.phone = raw_listing.at('.thumb_telefono').text.gsub(/\s+/, "")

        if listing.price < max_price
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
