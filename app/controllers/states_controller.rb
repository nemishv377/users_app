class StatesController < ApplicationController
  def cities
    @cities = City.where(state_id: params[:id])
    puts @cities
    render json: @cities
  end
end
