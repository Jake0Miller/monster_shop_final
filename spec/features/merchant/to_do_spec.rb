require 'rails_helper'

RSpec.describe 'Merchant Dashboard' do
  describe 'As an employee of a merchant' do
    before :each do
      @megan = Merchant.create!(name: 'Megans Marmalades', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @brian = Merchant.create!(name: 'Brians Bagels', address: '125 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @merchant_admin = @megan.users.create!(name: 'Megan', email: 'megan@example.com', password: 'securepassword')
      @address = @merchant_admin.addresses.create!(nickname: 'Home', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @ogre = @megan.items.create!(name: 'Ogre', description: "I'm an Ogre!", price: 20.25, inventory: 5 )
      @giant = @megan.items.create!(name: 'Giant', description: "I'm a Giant!", price: 50, image: 'https://i.pinimg.com/originals/bd/05/d3/bd05d3a70317c9465f6e1564a8a8bd8b.jpg', inventory: 3 )
      @hippo = @brian.items.create!(name: 'Hippo', description: "I'm a Hippo!", price: 50, image: 'https://i.ytimg.com/vi/6JxQtHK_9OI/maxresdefault.jpg', inventory: 1 )
      @order_1 = @merchant_admin.orders.create!(status: "pending", address: @address)
      @order_2 = @merchant_admin.orders.create!(status: "pending", address: @address)
      @order_item_1 = @order_1.order_items.create!(item: @giant, price: @giant.price, quantity: 2, fulfilled: false)
      @order_item_2 = @order_2.order_items.create!(item: @hippo, price: @hippo.price, quantity: 2, fulfilled: false)
      @order_item_3 = @order_2.order_items.create!(item: @ogre, price: @ogre.price, quantity: 2, fulfilled: false)
      @order_item_4 = @order_2.order_items.create!(item: @giant, price: @giant.price, quantity: 2, fulfilled: false)
      visit login_path
      fill_in 'Email', with: @merchant_admin.email
      fill_in 'Password', with: @merchant_admin.password
      click_button 'Log In'
    end

    it 'I can see a link to my To Do List' do
      expect(page).to have_link('To Do List')

      click_link('To Do List')

      expect(current_path).to eq(merchant_to_do_list_path)
      expect(page).to have_content('To Do List')
    end

    it 'I can link to item edit pages that need new images' do
      visit merchant_to_do_list_path
      within '.items-needing-images' do
        expect(page).to have_link(@ogre.name)
        click_link @ogre.name
        expect(current_path).to eq(edit_merchant_item_path(@ogre))
      end
    end

    it 'I can see my unfulfilled items' do
      visit merchant_to_do_list_path
      within '.unfulfilled-items' do
        expect(page).to have_content('You have 6 unfulfilled items in 2 orders worth $240.50')
        expect(page).to have_link(@order_1.id)
        expect(page).to have_link(@order_2.id)
        click_link @order_1.id
        expect(current_path).to eq(merchant_order_path(@order_1))
      end
    end
  end
end
