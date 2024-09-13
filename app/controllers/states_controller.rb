class StatesController < ApplicationController
  def cities
    @state = State.find(params[:id])
    authorize @state, :cities?
    @cities = City.where(state_id: params[:id])
    render json: @cities
  end
end
