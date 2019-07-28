require 'rails_helper'

RSpec.describe Address do
  describe 'Relationships' do
    it {should belong_to :user}
    it {should have_many :orders}
  end

  describe 'Validations' do
    it {should validate_presence_of :address}
    it {should validate_presence_of :city}
    it {should validate_presence_of :state}
    it {should validate_presence_of :zip}
    it {should validate_presence_of :nickname}
    it {should validate_uniqueness_of(:nickname).scoped_to(:user_id)}
  end

  describe 'Instance methods' do
    it '.shipped_orders' do
      user = User.create!(name: 'Megan', email: 'megan@example.com', password: 'securepassword')
      address = user.addresses.create!(nickname: 'Home', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218)
      order_1 = Order.create!(user: user, address: address, status: 'shipped')
      order_2 = Order.create!(user: user, address: address)
      expect(address.shipped_orders).to eq([order_1])
    end
  end
end
