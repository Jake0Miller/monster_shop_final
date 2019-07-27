class AddressesController < ApplicationController
  before_action :set_address, only: [:edit, :update, :destroy]

  def new
    @address = Address.new
  end

  def create
    @address = current_user.addresses.new(address_params)
    if @address.save
      redirect_to profile_path
    else
      generate_flash(@address)
      render :new
    end
  end

  def edit
  end

  def update
    if @address.shipped_orders.empty? && @address.update_attributes(address_params)
      flash[:notice] = 'Address has been updated!'
      redirect_to profile_path
    else
      generate_flash(@address)
      render :edit
    end
  end

  def destroy
    if @address.shipped_orders.empty?
      @address.destroy
    else
      flash[:error] = 'Address cannot be deleted!'
    end
    redirect_to profile_path
  end

  private

  def set_address
    @address = Address.find(params[:id])
  end

  def address_params
    params.require(:address).permit(:nickname, :address, :city, :state, :zip)
  end
end
