class Merchant::ToDoController < Merchant::BaseController
  def index
    @merchant = current_user.merchant
    @default_image_items = @merchant.default_image_items
  end
end
