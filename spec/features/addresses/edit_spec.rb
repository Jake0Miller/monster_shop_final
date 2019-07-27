require 'rails_helper'

RSpec.describe "User Profile Path" do
  describe "As a registered user" do
    before :each do
      @user = User.create!(name: 'Megan', email: 'megan@example.com', password: 'securepassword')
      @user_address = @user.addresses.create!(nickname: 'Home', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218)
      visit login_path
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log In'
    end

    it 'I can edit my addresses' do
      within "#address-#{@user_address.id}" do
        click_link "Edit Address"
      end

      expect(current_path).to eq(edit_address_path(@user_address))

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

      expect(current_path).to eq(profile_path)
      @user_address.reload
      @user.reload
      expect(@user_address.nickname).to eq(nickname)
      expect(@user_address.address).to eq(address)
      expect(@user_address.city).to eq(city)
      expect(@user_address.state).to eq(state)
      expect(@user_address.zip).to eq(zip.to_i)
      expect(@user.addresses.first).to eq(@user_address)

      within "#address-#{@user_address.id}" do
        expect(page).to have_content(nickname)
        expect(page).to have_content(address)
        expect(page).to have_content("#{city} #{state} #{zip}")
        click_link "Delete Address"
      end
    end
  end
end
