require 'rails_helper'

RSpec.describe ListingsController, type: :controller do
  before :each do
    @listing = FactoryGirl.create(:listing)
  end

  describe 'GET index' do
    it 'assigns @listings' do
      get :index
      expect(assigns(:listings)).to match_array(Listing.all)
    end

    it 'renders the index template' do
      get :index
      expect(response).to render_template('index')
    end
  end

  describe 'GET edit', :vcr do
    it 'should assign @listing' do
      listing = FactoryGirl.create(:listing)
       VCR.use_cassette 'edit_listing' do
          get :edit, id: listing.id
          expect(assigns(:listing)).to eq(listing)
       end
    end

    it 'renders the :edit view' do
      listing = FactoryGirl.create(:listing)
       VCR.use_cassette 'edit_listing' do
        get :edit, id: listing.id
        expect(response).to render_template('edit')
       end
    end
  end


  describe 'DELETE destroy' do
    it 'deletes the listing' do
      listing = FactoryGirl.create(:listing)
      delete :destroy, id: listing.id 
      expect(listing.deleted).to be_falsey
    end

    it 'redirects to the listings' do
      listing = FactoryGirl.create(:listing)
      delete :destroy, id: listing.id
      expect(response).to redirect_to(listings_url)
    end
  end
end
