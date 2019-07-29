class Merchant::ToDoController < Merchant::BaseController
  def index
    @merchant = current_user.merchant
  end
end
