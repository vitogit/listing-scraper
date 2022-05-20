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
    dolar_to_pesos = 43
    max_price = 400000
    urls = ['https://listado.mercadolibre.com.uy/inmuebles/casas/venta/mas-de-3-dormitorios/montevideo/buceo/_PriceRange_220000USD-410000USD_HAS*GARDEN_242085_NoIndex_True_PARKING*LOTS_1-*#applied_filter_id%3Dcity%26applied_filter_name%3DCiudades%26applied_filter_order%3D3%26applied_value_id%3DTUxVQ0JVQzNlMDdl%26applied_value_name%3DBuceo%26applied_value_order%3D9%26applied_value_results%3D34%26is_custom%3Dfalse%26view_more_flag%3Dtrue',
            'https://listado.mercadolibre.com.uy/inmuebles/casas/venta/mas-de-3-dormitorios/montevideo/malvin/_PriceRange_220000USD-410000USD_HAS*GARDEN_242085_NoIndex_True_PARKING*LOTS_1-*#applied_filter_id%3Dcity%26applied_filter_name%3DCiudades%26applied_filter_order%3D3%26applied_value_id%3DTUxVQ0JVQzNlMDdl%26applied_value_name%3DBuceo%26applied_value_order%3D9%26applied_value_results%3D34%26is_custom%3Dfalse%26view_more_flag%3Dtrue',
            'https://listado.mercadolibre.com.uy/inmuebles/casas/venta/mas-de-3-dormitorios/montevideo/puerto-buceo/_PriceRange_220000USD-410000USD_HAS*GARDEN_242085_NoIndex_True_PARKING*LOTS_1-*#applied_filter_id%3Dcity%26applied_filter_name%3DCiudades%26applied_filter_order%3D3%26applied_value_id%3DTUxVQ0JVQzNlMDdl%26applied_value_name%3DBuceo%26applied_value_order%3D9%26applied_value_results%3D34%26is_custom%3Dfalse%26view_more_flag%3Dtrue',
            'https://listado.mercadolibre.com.uy/inmuebles/casas/venta/mas-de-3-dormitorios/montevideo/carrasco/_PriceRange_220000USD-410000USD_HAS*GARDEN_242085_NoIndex_True_PARKING*LOTS_1-*#applied_filter_id%3Dcity%26applied_filter_name%3DCiudades%26applied_filter_order%3D3%26applied_value_id%3DTUxVQ0JVQzNlMDdl%26applied_value_name%3DBuceo%26applied_value_order%3D9%26applied_value_results%3D34%26is_custom%3Dfalse%26view_more_flag%3Dtrue',
            'https://listado.mercadolibre.com.uy/inmuebles/casas/venta/mas-de-3-dormitorios/montevideo/punta-gorda/_PriceRange_220000USD-410000USD_HAS*GARDEN_242085_NoIndex_True_PARKING*LOTS_1-*#applied_filter_id%3Dcity%26applied_filter_name%3DCiudades%26applied_filter_order%3D3%26applied_value_id%3DTUxVQ0JVQzNlMDdl%26applied_value_name%3DBuceo%26applied_value_order%3D9%26applied_value_results%3D34%26is_custom%3Dfalse%26view_more_flag%3Dtrue',
            'https://listado.mercadolibre.com.uy/inmuebles/casas/venta/mas-de-3-dormitorios/montevideo/pocitos-nuevo/_PriceRange_220000USD-410000USD_HAS*GARDEN_242085_NoIndex_True_PARKING*LOTS_1-*#applied_filter_id%3Dcity%26applied_filter_name%3DCiudades%26applied_filter_order%3D3%26applied_value_id%3DTUxVQ0JVQzNlMDdl%26applied_value_name%3DBuceo%26applied_value_order%3D9%26applied_value_results%3D34%26is_custom%3Dfalse%26view_more_flag%3Dtrue',
            'https://listado.mercadolibre.com.uy/inmuebles/casas/venta/mas-de-3-dormitorios/montevideo/pocitos/_PriceRange_220000USD-410000USD_HAS*GARDEN_242085_NoIndex_True_PARKING*LOTS_1-*#applied_filter_id%3Dcity%26applied_filter_name%3DCiudades%26applied_filter_order%3D3%26applied_value_id%3DTUxVQ0JVQzNlMDdl%26applied_value_name%3DBuceo%26applied_value_order%3D9%26applied_value_results%3D34%26is_custom%3Dfalse%26view_more_flag%3Dtrue',
            'https://listado.mercadolibre.com.uy/inmuebles/casas/venta/mas-de-3-dormitorios/montevideo/villa-biarritz/_PriceRange_220000USD-410000USD_HAS*GARDEN_242085_NoIndex_True_PARKING*LOTS_1-*#applied_filter_id%3Dcity%26applied_filter_name%3DCiudades%26applied_filter_order%3D3%26applied_value_id%3DTUxVQ0JVQzNlMDdl%26applied_value_name%3DBuceo%26applied_value_order%3D9%26applied_value_results%3D34%26is_custom%3Dfalse%26view_more_flag%3Dtrue',
            'https://listado.mercadolibre.com.uy/inmuebles/casas/venta/mas-de-3-dormitorios/montevideo/punta-carretas/_PriceRange_220000USD-410000USD_HAS*GARDEN_242085_NoIndex_True_PARKING*LOTS_1-*#applied_filter_id%3Dcity%26applied_filter_name%3DCiudades%26applied_filter_order%3D3%26applied_value_id%3DTUxVQ0JVQzNlMDdl%26applied_value_name%3DBuceo%26applied_value_order%3D9%26applied_value_results%3D34%26is_custom%3Dfalse%26view_more_flag%3Dtrue',
            ]

    old_count = Listing.count
    urls.each do |url|
      agent = Mechanize.new
      pages = 0

      begin
        page = agent.get(url)
        raw_listings = page.search(".ui-search-results .ui-search-result")
      rescue Exception => e
        raw_listings = []
      end
      # nei = page.search(".ui-search-applied-filters a")[1]&.text

      raw_listings.each do |raw_listing|
        listing = Listing.new
        listing.from = "ml"
        listing.similar = []

        listing.link = raw_listing.at('a').attributes['href']
        listing.external_id = listing.link.split('-')[1]
        old_listing = Listing.find_by_external_id(listing.external_id)

        listing.title = raw_listing.at('.ui-search-item__title').text
        # listing.address = nei
        # listing.img = raw_listing.at('img').attributes['title'] || raw_listing.at('img').attributes['src'] #in the title is the real url, because with js it load it
        listing.img = raw_listing.at('.ui-search-result-image__element')['data-src']
        listing.price = raw_listing.at('.price-tag-fraction').text.gsub('.','')
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
    page = agent.get('https://www.gallito.com.uy/inmuebles/casas/venta/montevideo/buceo!carrasco!malvin!pocitos!pocitos-nuevo!punta-carretas!punta-gorda!villa-dolores/pre-220000-410000-dolares/con-garages/3-dormitorios/4-dormitorios/5-dormitorios-o-mas')
    pages = 0
    max_pages = 20
    dolar_to_pesos = 43
    max_price = 410000

    # add /ord_rec to sort by recent
    # raw_listings = agent.page.search("#grillaavisos a")
    # return if Listing.find_by_link(raw_listings.first.attributes['href'].to_s).present?
    while  pages < max_pages && page.link_with(text: '>')  do
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
          listing.currency = "(U$S)"
        else
          listing.price = listing.price / dolar_to_pesos
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
      next_page = page.link_with(text: '>')
      page = next_page.click
      pages += 1
    end
  end
end
