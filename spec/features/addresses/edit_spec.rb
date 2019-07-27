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

    it 'I can edit an address' do
      within "#address-#{@address.id}" do
        click_link "Edit Address"
      end

      expect(current_path).to eq(edit_address_path(@address))

      fill_in 'address[address]', with: ''
      fill_in 'address[city]', with: ''
      fill_in 'address[state]', with: ''
      fill_in 'address[zip]', with: ''
      click_button 'Update Address'

      expect(page).to have_content("address: [\"can't be blank\"]")
      expect(page).to have_content("city: [\"can't be blank\"]")
      expect(page).to have_content("state: [\"can't be blank\"]")
      expect(page).to have_content("zip: [\"can't be blank\"]")

      nickname = 'Parents'
      address = '456 High St'
      city = 'Boise'
      state = 'ID'
      zip = '45789'
      fill_in 'address[nickname]', with: nickname
      fill_in 'address[address]', with: address
      fill_in 'address[city]', with: city
      fill_in 'address[state]', with: state
      fill_in 'address[zip]', with: zip
      click_button 'Update Address'

      @address.reload
      @user.reload
      expect(current_path).to eq(profile_path)
      expect(@address.nickname).to eq(nickname)
      expect(@address.address).to eq(address)
      expect(@address.city).to eq(city)
      expect(@address.state).to eq(state)
      expect(@address.zip).to eq(zip.to_i)
      expect(@user.addresses.first).to eq(@address)

      within "#address-#{@address.id}" do
        expect(page).to have_content(nickname)
        expect(page).to have_content(address)
        expect(page).to have_content("#{city} #{state} #{zip}")
        click_link "Delete Address"
      end

      expect(page).to_not have_content(nickname)
      expect(page).to_not have_content(address)
      expect(page).to_not have_content("#{city} #{state} #{zip}")
    end

    it 'I cannot see edit button if an order is shipped' do
      order = Order.create!(user: @user, address: @address, status: 'shipped')
      visit profile_path

      expect(@address.orders.first).to eq(order)
      expect(@address.shipped_orders.empty?).to eq(false)
      within "#address-#{@address.id}" do
        expect(page).to_not have_link("Edit Address")
      end
    end

    it 'I cannot edit an address if it has a shipped order' do
      order = Order.create!(user: @user, address: @address, status: 'shipped')
      page.driver.submit :patch, address_path(@address), {address: {nickname: 'Parents', address: '456 High St', city: 'Boise', state: 'ID' ,zip: '45789'}}
      visit profile_path

      expect(@address.orders.first).to eq(order)
      expect(@address.shipped_orders.empty?).to eq(false)
      within "#address-#{@address.id}" do
        expect(page).to have_content("123 Main St")
        expect(page).to have_content("Denver CO 80218")
      end
    end
  end
end
