module Api
  module V1
    class StatesController < ApplicationController
      def cities
        @cities = City.where(state_id: params[:id])
        render json: @cities
      end
    end
  end
end
