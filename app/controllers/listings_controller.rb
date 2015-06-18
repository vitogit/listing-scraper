class ListingsController < ApplicationController
  before_action :set_listing, only: [:show, :edit, :update, :destroy]

  # GET /listings
  # GET /listings.json
  def index
    agent = Mechanize.new
    @listings = []
    page = agent.get('http://www.gallito.com.uy/inmuebles/apartamentos/alquiler/montevideo/pocitos!punta-carretas/1-dormitorio')
    raw_listings = agent.page.search("#grillaavisos a")
    raw_listings.each do |raw_listing|
      listing = Listing.new
      listing.id = 0
      listing.title = raw_listing.at('.thumb_titulo').text
      listing.img = raw_listing.at('#div_rodea_datos img').attributes['data-original']
      listing.price = raw_listing.at('.thumb01_precio').text.gsub(/\D/, '') if raw_listing.at('.thumb01_precio')
      listing.currency = raw_listing.at('.thumb01_precio').text.gsub(/\d/, '') if raw_listing.at('.thumb01_precio')
      # listing.gc = raw_listing.search('.thumb01_precio')[0].text
      listing.address = raw_listing.at('.thumb_txt h2').text
      listing.phone = raw_listing.at('.thumb_telefono').text
      listing.link = raw_listing.attributes['href']
      @listings << listing
    end

    # page = link.click

    # @page_uri = page.uri
    # @listings = Listing.all
  end

  # GET /listings/1
  # GET /listings/1.json
  def show
  end

  # GET /listings/new
  def new
    @listing = Listing.new
  end

  # GET /listings/1/edit
  def edit
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
    respond_to do |format|
      if @listing.update(listing_params)
        format.html { redirect_to @listing, notice: 'Listing was successfully updated.' }
        format.json { render :show, status: :ok, location: @listing }
      else
        format.html { render :edit }
        format.json { render json: @listing.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /listings/1
  # DELETE /listings/1.json
  def destroy
    @listing.destroy
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
      params.require(:listing).permit(:title, :price, :gc, :address, :phone, :link)
    end
end
