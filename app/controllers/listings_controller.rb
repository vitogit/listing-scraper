class ListingsController < ApplicationController
  before_action :set_listing, only: [:show, :edit, :update, :destroy, :scrapeit]

  # GET /listings
  # GET /listings.json
  def index
    @show_deleted = params[:show_deleted]
    if @show_deleted
      @listings = Listing.order(:price)
    else
      @listings = Listing.where(deleted:false).order(:price)
    end
  end


  def scrape_gallito
    agent = Mechanize.new
    @listings = []
    page = agent.get('http://www.gallito.com.uy/inmuebles/apartamentos/alquiler/montevideo/pocitos!punta-carretas/1-dormitorio')
    pages = 0
    max_pages = 20
    dolar_to_pesos = 26.5
    max_price = 18000

    while  pages < max_pages && page.link_with(text: /Siguiente/)  do
      raw_listings = agent.page.search("#grillaavisos a")
      raw_listings.each do |raw_listing|

        listing = Listing.new

        listing.link = raw_listing.attributes['href']
        listing.external_id = listing.link.split('-')[-1]
        next if Listing.find_by_external_id(listing.external_id).present?

        # listing.id = 0
        listing.title = raw_listing.at('.thumb_titulo').text
        listing.img = raw_listing.at('#div_rodea_datos img').attributes['data-original']

        price_selector = raw_listing.at('.thumb01_precio, .thumb02_precio')
        listing.currency = price_selector.text.gsub(/[\d^.]/, '') if price_selector
        listing.price = price_selector.text.gsub(/\D/, '') if price_selector
        if listing.currency.strip == "U$S"
          listing.price = listing.price * dolar_to_pesos
          listing.currency += "(Converted to $U)"
        end

        # listing.gc = raw_listing.search('.thumb01_precio')[0].text
        listing.address = raw_listing.at('.thumb_txt h2').text
        listing.phone = raw_listing.at('.thumb_telefono').text.gsub(/\s+/, "")

        if listing.price < max_price
          listing.save
        end
      end
      next_page = page.link_with(text: /Siguiente/)
      # break if next_page.nil? 
      page = next_page.click
      pages += 1
    end
    redirect_to :root, notice: 'Listings scraped.'

  end

  def scrapeit
    agent = Mechanize.new
    page = agent.get(@listing.link)
    dolar_to_pesos = 26.5
    max_price = 18000

    raw_listing = agent.page.search(".contendor")

    @listing.title = raw_listing.at('.titulo').text
    @listing.description = raw_listing.at('#descripcionLarga').text.squish
    @listing.full_scraped = true

    sup_total = raw_listing.at("#primerosLi li:contains('Sup. Total:')").text

    @listing.description = @listing.description+". "+sup_total

    # save pictures only if there are empty
    if !@listing.pictures.present?
      raw_pictures = raw_listing.search(".sliderImg")

      @pictures = []
      raw_pictures.each do |raw_picture|
        picture = Picture.new
        picture.url = raw_picture.attributes['href']
        @listing.pictures << picture
      end
    end
  end
  # GET /listings/1
  # GET /listings/1.json
  def show
  end

  # GET /listings/new
  def new
    @listing = Listing.new
  end

  def edit
    puts "json________"+@listing.pictures.to_json
  end

  # POST /listings
  # POST /listings.json
  def create
    @listing = Listing.new(listing_params)

    respond_to do |format|
      if @listing.save
        format.html { redirect_to @listing, notice: 'Listing was successfully created.' }
        format.json { render :show, status: :created, location: @listing }
      else
        format.html { render :new }
        format.json { render json: @listing.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /listings/1
  # PATCH/PUT /listings/1.json
  def update
    puts "listin params_________"+listing_params.to_json
    puts "@pictures_________"+@pictures.to_json
    respond_to do |format|
      if @listing.update(listing_params)
        format.html { redirect_to edit_listing_path(@listing.id), notice: 'Listing was successfully updated.' }
        format.json { render :show, status: :ok, location: @listing }
      else
        format.html { render :edit }
        format.json { render json: @listing.errors, status: :unprocessable_entity }
      end
    end

    # if @client.update(client_params)
    #   redirect_to admin_clients_path
    # else
    #   render :edit
    # end
  end

  # DELETE /listings/1
  # DELETE /listings/1.json
  def destroy
    @listing.deleted = true
    @listing.save
    respond_to do |format|
      format.html { redirect_to listings_url, notice: 'Listing was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_listing
      @listing = Listing.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def listing_params
      params.require(:listing).permit(:full_scraped, :title, :price, :gc, :address, :phone, :link, :description,:guarantee, :ranking,
                                      pictures_attributes: [:url])
    end
end
