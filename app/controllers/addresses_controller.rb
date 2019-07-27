class AddressesController < ApplicationController
  def edit
    @address = Address.find(params[:id])
  end

  def update
    @address = Address.find(params[:id])
    if @address.update_attributes(address_params)
      flash[:notice] = 'Address has been updated!'
      redirect_to profile_path
    else
      generate_flash(@address)
      render :edit
    end
  end

  private

  def address_params
    params.require(:address).permit(:nickname, :address, :city, :state, :zip)
  end
end
