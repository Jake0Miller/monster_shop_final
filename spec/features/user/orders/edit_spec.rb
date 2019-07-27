require 'rails_helper'
include ActionView::Helpers::NumberHelper

RSpec.describe 'Order Edit Page' do
  describe 'As a Registered User' do
    before :each do
      @megan = Merchant.create!(name: 'Megans Marmalades', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @ogre = @megan.items.create!(name: 'Ogre', description: "I'm an Ogre!", price: 20.25, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 5 )
      @giant = @megan.items.create!(name: 'Giant', description: "I'm a Giant!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 3 )
      @user = User.create!(name: 'Megan', email: 'megan_1@example.com', password: 'securepassword')
      @address_1 = @user.addresses.create!(nickname: 'Home', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @address_2 = @user.addresses.create!(nickname: 'Work', address: '456 Main St', city: 'Denver', state: 'IA', zip: 50218)
      @order = @user.orders.create!(status: "packaged", address: @address_1)
      @order_item_1 = @order.order_items.create!(item: @ogre, price: @ogre.price, quantity: 2, fulfilled: true)
      @order_item_2 = @order.order_items.create!(item: @giant, price: @giant.price, quantity: 2, fulfilled: true)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)
    end

    it 'I can link from my orders to an order edit page' do
      visit '/profile/orders'
      click_link @order.id.to_s

      within '.address' do
        expect(page).to have_content(@address_1.nickname)
        expect(page).to have_content(@address_1.address)
        expect(page).to have_content("#{@address_1.city} #{@address_1.state} #{@address_1.zip}")
      end

      click_button 'Change Address'

      expect(current_path).to eq(edit_order_path(@order))
      expect(page).to have_content('Select Address')

      choose("order_address_id_#{@address_2.id}")
      click_button 'Select Address'
      visit '/profile/orders'
      click_link @order.id.to_s

      within '.address' do
        expect(page).to have_content(@address_2.nickname)
        expect(page).to have_content(@address_2.address)
        expect(page).to have_content("#{@address_2.city} #{@address_2.state} #{@address_2.zip}")
      end
    end
  end
end
