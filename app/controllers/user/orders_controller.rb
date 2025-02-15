class User::OrdersController < ApplicationController
  before_action :exclude_admin

  def index
    @orders = current_user.orders
  end

  def show
    @order = current_user.orders.find(params[:id])
  end

  def create
    order = current_user.orders.new(order_params)
    order.save
    cart.items.each do |item|
      order.order_items.create({
        item: item,
        quantity: cart.count_of(item.id),
        price: item.price,
        })
    end
    session.delete(:cart)
    flash[:notice] = "Order created successfully!"
    redirect_to '/profile/orders'
  end

  def edit
    @order = current_user.orders.find(params[:id])
  end

  def update
    order = current_user.orders.find(params[:id])
    order.update_attributes(order_params)
  end

  def cancel
    order = current_user.orders.find(params[:id])
    order.cancel
    redirect_to "/profile/orders/#{order.id}"
  end

  private

  def order_params
    params.require(:order).permit(:address_id)
  end
end
