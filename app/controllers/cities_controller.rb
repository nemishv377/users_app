class CitiesController < ApplicationController
  
  def city
    @city = City.where(city_id: params[:id])
    render json: @city
  end
end
