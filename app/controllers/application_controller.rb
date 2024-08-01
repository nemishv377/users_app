class ApplicationController < ActionController::Base
  #
  # If you remove below code then it will alert for eager loading
  # If Not used eger loading. 
  # around_action :skip_bullet, if: -> { defined?(Bullet) }

  # def skip_bullet
  #   previous_value = Bullet.enable?
  #   Bullet.enable = false
  #   yield
  # ensure
  #   Bullet.enable = previous_value
  # end
end
