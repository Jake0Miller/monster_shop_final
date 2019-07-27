require 'rails_helper'

RSpec.describe "User Profile Path" do
  describe "As a registered user" do
    before :each do
      @user = User.create!(name: 'Megan', email: 'megan@example.com', password: 'securepassword')
      @user_address_1 = @user.addresses.create!(nickname: 'Home', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @user_address_2 = @user.addresses.create!(nickname: 'Work', address: '111 Pine St', city: 'Denver', state: 'CO', zip: 80218)
      @admin = User.create!(name: 'Megan', email: 'admin@example.com', password: 'securepassword')
    end

    it "I can view my profile page" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)
      visit profile_path

      expect(page).to have_content(@user.name)
      expect(page).to have_content(@user.email)
      expect(page).to_not have_content(@user.password)
      expect(page).to have_link('Edit Profile')
      expect(page).to have_link('Change Password')
      expect(page).to have_link('My Orders')

      within "#address-#{@user_address_1.id}" do
        expect(page).to have_content(@user_address_1.nickname)
        expect(page).to have_content(@user_address_1.address)
        expect(page).to have_content("#{@user_address_1.city} #{@user_address_1.state} #{@user_address_1.zip}")
        expect(page).to have_link("Edit Address")
        expect(page).to have_link("Delete Address")
      end

      within "#address-#{@user_address_2.id}" do
        expect(page).to have_content(@user_address_2.nickname)
        expect(page).to have_content(@user_address_2.address)
        expect(page).to have_content("#{@user_address_2.city} #{@user_address_2.state} #{@user_address_2.zip}")
        expect(page).to have_link("Edit Address")
        expect(page).to have_link("Delete Address")
      end

      expect(page).to have_link("New Address")
    end

    it "I can update my profile data" do
      visit login_path

      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log In'

      click_link 'Edit Profile'

      expect(current_path).to eq('/profile/edit')

      name = 'New Name'
      email = 'new@example.com'

      fill_in "Name", with: name
      fill_in "Email", with: email
      click_button 'Update Profile'

      expect(current_path).to eq(profile_path)

      expect(page).to have_content('Profile has been updated!')
      expect(page).to have_content(name)
      expect(page).to have_content(email)
      expect(page).to have_content(@user_address_1.address)
      expect(page).to have_content("#{@user_address_1.city} #{@user_address_1.state} #{@user_address_1.zip}")
    end

    it "I can update my password" do
      visit login_path

      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log In'

      click_link 'Change Password'

      expect(current_path).to eq('/profile/edit_password')

      password = "newpassword"

      fill_in "Password", with: password
      fill_in "Password confirmation", with: password
      click_button 'Change Password'

      expect(current_path).to eq(profile_path)

      expect(page).to have_content('Profile has been updated!')

      click_link 'Log Out'

      visit login_path

      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log In'

      expect(page).to have_content("Your email or password was incorrect!")

      visit login_path

      fill_in 'Email', with: @user.email
      fill_in 'Password', with: "newpassword"
      click_button 'Log In'

      expect(current_path).to eq(profile_path)
    end

    it "I must use a unique email address" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

      visit '/profile/edit'

      fill_in "Email", with: @admin.email
      click_button "Update Profile"

      expect(page).to have_content("email: [\"has already been taken\"]")
      expect(page).to have_button "Update Profile"
    end
  end
end
