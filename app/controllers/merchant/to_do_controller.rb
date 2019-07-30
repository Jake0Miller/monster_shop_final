class Merchant::ToDoController < Merchant::BaseController
  def index
    @merchant = current_user.merchant
    @default_image_items = @merchant.default_image_items
    @unfulfilled_orders = @merchant.unfulfilled_orders
    @num_orders = @unfulfilled_orders.length
    @value = @unfulfilled_orders.sum {|order| order.value}
  end
end
