require 'rails_helper'

RSpec.describe "User Profile Path" do
  describe "As a registered user" do
    before :each do
      @user = User.create!(name: 'Megan', email: 'megan@example.com', password: 'securepassword')
      @address = @user.addresses.create!(nickname: 'Home', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218)
      visit login_path
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log In'
    end

    it 'I can delete an address' do
      within "#address-#{@address.id}" do
        click_link "Delete Address"
      end

      expect(page).to_not have_css("address-#{@address.id}")
      expect(page).to_not have_content(@address.address)
      expect(page).to_not have_content("#{@address.city} #{@address.state} #{@address.zip}")
    end

    it 'I cannot see delete button if an order is shipped' do
      order = Order.create!(user: @user, address: @address, status: 'shipped')
      visit profile_path

      expect(@address.orders.first).to eq(order)
      expect(@address.shipped_orders.empty?).to eq(false)
      within "#address-#{@address.id}" do
        expect(page).to_not have_link("Delete Address")
      end
    end

    it 'I cannot delete an address if it has a shipped order' do
      order = Order.create!(user: @user, address: @address, status: 'shipped')
      page.driver.submit :delete, address_path(@address), {}

      expect(@address.orders.first).to eq(order)
      expect(@address.shipped_orders.empty?).to eq(false)
      expect(page).to have_css("address-#{@address.id}")
      expect(page).to have_content(@address.address)
      expect(page).to have_content("#{@address.city} #{@address.state} #{@address.zip}")
    end
  end
end
