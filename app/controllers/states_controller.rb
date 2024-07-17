class StatesController < ApplicationController
  def cities
    @cities = City.where(state_id: params[:id])
    render json: @cities
  end

  # private
  # def state_params
  #   params.require(:user).permit(:name, users_sttributes: [:id, :first_name, :last_name, :email, :gender, :state_id, :city_id, hobbies: []])
  # end
end
