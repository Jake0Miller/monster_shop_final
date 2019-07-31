require 'rails_helper'
include ApplicationHelper

RSpec.describe 'flash' do
  describe 'test each message' do
    it 'should display a flash message' do
      expect(flash_class('notice')).to eq('alert alert-info')
      expect(flash_class('success')).to eq('alert alert-success')
      expect(flash_class('error')).to eq('alert alert-danger')
      expect(flash_class('alert')).to eq('alert alert-warning')
    end
  end
end
