require 'rails_helper'

RSpec.describe 'Merchant Dashboard' do
  describe 'As an employee of a merchant' do
    before :each do
      @merchant_1 = Merchant.create!(name: 'Megans Marmalades', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @merchant_2 = Merchant.create!(name: 'Brians Bagels', address: '125 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @m_user = @merchant_1.users.create!(name: 'Megan', email: 'megan@example.com', password: 'securepassword')
      @m_user_2 = @merchant_2.users.create!(name: 'Megan', email: 'meg2@example.com', password: 'securepassword')
      @address = @m_user.addresses.create!(nickname: 'Home', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @ogre = @merchant_1.items.create!(name: 'Ogre', description: "I'm an Ogre!", price: 20.25, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 5 )
      @giant = @merchant_1.items.create!(name: 'Giant', description: "I'm a Giant!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 3 )
      @hippo = @merchant_2.items.create!(name: 'Hippo', description: "I'm a Hippo!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 1 )
      @order_1 = @m_user.orders.create!(status: "pending", address: @address)
      @order_2 = @m_user.orders.create!(status: "pending", address: @address)
      @order_3 = @m_user.orders.create!(status: "pending", address: @address)
      @order_item_1 = @order_1.order_items.create!(item: @hippo, price: @hippo.price, quantity: 2, fulfilled: false)
      @order_item_2 = @order_2.order_items.create!(item: @hippo, price: @hippo.price, quantity: 2, fulfilled: true)
      @order_item_3 = @order_2.order_items.create!(item: @ogre, price: @ogre.price, quantity: 2, fulfilled: false)
      @order_item_4 = @order_3.order_items.create!(item: @giant, price: @giant.price, quantity: 2, fulfilled: false)
      visit login_path
      fill_in 'Email', with: @m_user.email
      fill_in 'Password', with: @m_user.password
      click_button 'Log In'
    end

    it 'I can see my merchants information on the merchant dashboard' do
      expect(page).to have_link(@merchant_1.name)
      expect(page).to have_content(@merchant_1.address)
      expect(page).to have_content("#{@merchant_1.city} #{@merchant_1.state} #{@merchant_1.zip}")
    end

    it 'I do not have a link to edit the merchant information' do
      expect(page).to_not have_link('Edit')
    end

    it 'I see a list of pending orders containing my items' do
      within '.orders' do
        expect(page).to_not have_css("#order-#{@order_1.id}")

        within "#order-#{@order_2.id}" do
          expect(page).to have_link(@order_2.id.to_s)
          expect(page).to have_content("Potential Revenue: #{@order_2.merchant_subtotal(@merchant_1.id)}")
          expect(page).to have_content("Quantity of Items: #{@order_2.merchant_quantity(@merchant_1.id)}")
          expect(page).to have_content("Created: #{@order_2.created_at}")
        end

        within "#order-#{@order_3.id}" do
          expect(page).to have_link(@order_3.id.to_s)
          expect(page).to have_content("Potential Revenue: #{@order_3.merchant_subtotal(@merchant_1.id)}")
          expect(page).to have_content("Quantity of Items: #{@order_3.merchant_quantity(@merchant_1.id)}")
          expect(page).to have_content("Created: #{@order_3.created_at}")
        end
      end
    end

    it 'I can link to an order show page' do
      click_link @order_2.id.to_s

      expect(current_path).to eq(merchant_order_path(@order_2.id))
    end

    it 'I can see items ordered in excess of my inventory' do
      click_link 'Log Out'
      visit login_path
      fill_in 'Email', with: @m_user_2.email
      fill_in 'Password', with: @m_user_2.password
      click_button 'Log In'

      within "#order-#{@order_2.id}" do
        expect(page).to have_link(@order_2.id.to_s)
        expect(page).to have_content("Potential Revenue: #{@order_2.merchant_subtotal(@merchant_2.id)}")
        expect(page).to have_content("Quantity of Items: #{@order_2.merchant_quantity(@merchant_2.id)}")
        expect(page).to have_content("Created: #{@order_2.created_at}")
        expect(page).to have_content("WARNING: Item ordered exceeds current inventory!")
      end
    end
  end
end
