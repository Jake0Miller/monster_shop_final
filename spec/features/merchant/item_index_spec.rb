require 'rails_helper'
include ActionView::Helpers::NumberHelper

RSpec.describe 'Merchant Item Index' do
  describe 'As a Merchant employee' do
    before :each do
      @merchant_1 = Merchant.create!(name: 'Megans Marmalades', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @merchant_2 = Merchant.create!(name: 'Brians Bagels', address: '125 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @m_user = @merchant_1.users.create!(name: 'Megan', email: 'megan@example.com', password: 'securepassword')
      @m_user_2 = @merchant_2.users.create!(name: 'Megan', email: 'meg2@example.com', password: 'securepassword')
      @address = @m_user.addresses.create!(nickname: 'Home', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @ogre = @merchant_1.items.create!(name: 'Ogre', description: "I'm an Ogre!", price: 20.25, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 5 )
      @nessie = @merchant_1.items.create!(name: 'Nessie', description: "I'm a Loch Monster!", price: 20.25, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 5 )
      @giant = @merchant_1.items.create!(name: 'Giant', description: "I'm a Giant!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: false, inventory: 3 )
      @hippo = @merchant_2.items.create!(name: 'Hippo', description: "I'm a Hippo!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 1 )
      @order_1 = @m_user.orders.create!(status: "pending", address: @address)
      @order_2 = @m_user.orders.create!(status: "pending", address: @address)
      @order_3 = @m_user.orders.create!(status: "pending", address: @address)
      @order_item_1 = @order_1.order_items.create!(item: @hippo, price: @hippo.price, quantity: 1, fulfilled: false)
      @order_item_2 = @order_2.order_items.create!(item: @hippo, price: @hippo.price, quantity: 1, fulfilled: true)
      @order_item_3 = @order_2.order_items.create!(item: @ogre, price: @ogre.price, quantity: 2, fulfilled: false)
      @order_item_4 = @order_3.order_items.create!(item: @giant, price: @giant.price, quantity: 4, fulfilled: false)
      visit login_path
      fill_in 'Email', with: @m_user.email
      fill_in 'Password', with: @m_user.password
      click_button 'Log In'
    end

    it 'I can link to my merchant items from the merchant dashboard' do
      visit '/merchant'

      click_link 'My Items'

      expect(current_path).to eq('/merchant/items')
    end

    it 'I see my items, with statistics, including inactive items' do
      visit '/merchant/items'

      within '.statistics' do
        expect(page).to have_content("Most Popular Items:\n#{@giant.name}: 4 sold #{@ogre.name}: 2 sold #{@nessie.name}: 0 sold")
        expect(page).to have_content("Least Popular Items:\n#{@nessie.name}: 0 sold #{@ogre.name}: 2 sold #{@giant.name}: 4 sold")
      end

      within "#item-#{@giant.id}" do
        expect(page).to have_link(@giant.name)
        expect(page).to have_content(@giant.description)
        expect(page).to have_content("Price: #{number_to_currency(@giant.price)}")
        expect(page).to have_content("Inactive")
        expect(page).to have_content("Inventory: #{@giant.inventory}")
        expect(page).to have_css("img[src*='#{@giant.image}']")
        expect(page).to have_link("image")
        expect(page).to have_button('Activate')
      end

      within "#item-#{@ogre.id}" do
        expect(page).to have_link(@ogre.name)
        expect(page).to have_content(@ogre.description)
        expect(page).to have_content("Price: #{number_to_currency(@ogre.price)}")
        expect(page).to have_content("Active")
        expect(page).to have_content("Inventory: #{@ogre.inventory}")
        expect(page).to have_css("img[src*='#{@ogre.image}']")
        expect(page).to have_link("image")
        expect(page).to have_button('Inactivate')
      end
    end

    it 'I can deactivate an item' do
      visit '/merchant/items'

      within "#item-#{@ogre.id}" do
        click_button 'Inactivate'
      end

      expect(current_path).to eq('/merchant/items')
      expect(page).to have_content("#{@ogre.name} is no longer for sale")

      @m_user.reload

      visit '/merchant/items'

      within "#item-#{@ogre.id}" do
        expect(page).to have_content('Inactive')
      end
    end

    it 'I can activate an item' do
      visit '/merchant/items'

      within "#item-#{@giant.id}" do
        click_button 'Activate'
      end

      expect(current_path).to eq('/merchant/items')
      expect(page).to have_content("#{@giant.name} is now available for sale")

      @m_user.reload

      visit '/merchant/items'

      within "#item-#{@giant.id}" do
        expect(page).to have_content('Active')
      end
    end

    it 'I can delete items that have not been ordered' do
      visit '/merchant/items'

      within "#item-#{@nessie.id}" do
        click_button 'Delete'
      end

      expect(current_path).to eq('/merchant/items')

      @m_user.reload

      visit '/merchant/items'

      expect(page).to_not have_css("#item-#{@nessie.id}")
    end

    it 'I can not delete items that have been ordered' do
      visit '/merchant/items'

      within "#item-#{@ogre.id}" do
        expect(page).to_not have_button('Delete')
      end

      page.driver.submit :delete, "/merchant/items/#{@ogre.id}", {}

      expect(current_path).to eq('/merchant/items')
      expect(page).to have_content("#{@ogre.name} can not be deleted - it has been ordered!")
    end

    it 'I can see items that are ordered in excess of my inventory' do
      click_link 'Log Out'
      visit login_path
      fill_in 'Email', with: @m_user_2.email
      fill_in 'Password', with: @m_user_2.password
      click_button 'Log In'
      click_link 'My Items'

      within "#item-#{@hippo.id}" do
        expect(page).to have_link(@hippo.name)
        expect(page).to have_content(@hippo.description)
        expect(page).to have_content("Price: #{number_to_currency(@hippo.price)}")
        expect(page).to have_content("Active")
        expect(page).to have_content("Inventory: #{@hippo.inventory}")
        expect(page).to have_css("img[src*='#{@hippo.image}']")
        expect(page).to have_link("image")
        expect(page).to have_button('Inactivate')
        expect(page).to have_content("WARNING: Items ordered exceeds inventory")
      end
    end
  end
end
