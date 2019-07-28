require 'rails_helper'

RSpec.describe "User Profile Path" do
  describe "As a registered user" do
    before :each do
      @user = User.create!(name: 'Megan', email: 'megan@example.com', password: 'securepassword')
      visit login_path
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log In'
      @nickname = 'Work'
      @address = '123 Main St'
      @city = "Denver"
      @state = "CO"
      @zip = 80218
    end

    it "I can click a link to add a new address" do
      click_link("New Address")

      fill_in 'Nickname', with: @nickname
      fill_in 'Address', with: @address
      fill_in 'City', with: @city
      fill_in 'State', with: @state
      fill_in 'Zip', with: @zip
      click_button 'Create Address'

      expect(page).to have_content(@nickname)
      expect(page).to have_content(@address)
      expect(page).to have_content(@city)
      expect(page).to have_content(@state)
      expect(page).to have_content(@zip)
    end

    it "I cannot create an address with incomplete info" do
      click_link("New Address")
      fill_in 'Nickname', with: ''
      fill_in 'Address', with: ''
      fill_in 'City', with: ''
      fill_in 'State', with: ''
      fill_in 'Zip', with: ''
      click_button 'Create Address'

      expect(page).to_not have_content(@nickname)
      expect(page).to_not have_content(@address)
      expect(page).to_not have_content(@city)
      expect(page).to_not have_content(@state)
      expect(page).to_not have_content(@zip)
    end

    it "I cannot create an address with a reused nickname" do
      click_link("New Address")
      fill_in 'Nickname', with: @nickname
      fill_in 'Address', with: @address
      fill_in 'City', with: @city
      fill_in 'State', with: @state
      fill_in 'Zip', with: @zip
      click_button 'Create Address'

      expect(Address.all.length).to eq(1)

      click_link("New Address")
      fill_in 'Nickname', with: @nickname
      fill_in 'Address', with: @address
      fill_in 'City', with: @city
      fill_in 'State', with: @state
      fill_in 'Zip', with: @zip
      click_button 'Create Address'

      expect(Address.all.length).to eq(1)
      expect(page).to have_content("nickname: [\"has already been taken\"]")

      user = User.create!(name: 'Megan', email: 'meg@example.com', password: 'securepassword')
      click_link 'Log Out'
      visit login_path
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Log In'

      click_link("New Address")
      fill_in 'Nickname', with: @nickname
      fill_in 'Address', with: @address
      fill_in 'City', with: @city
      fill_in 'State', with: @state
      fill_in 'Zip', with: @zip
      click_button 'Create Address'

      expect(page).to_not have_content("nickname: [\"has already been taken\"]")
      expect(page).to have_content(@nickname)
      expect(page).to have_content(@address)
      expect(page).to have_content(@city)
      expect(page).to have_content(@state)
      expect(page).to have_content(@zip)
    end
  end
end
