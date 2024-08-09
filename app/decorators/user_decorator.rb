class UserDecorator < Draper::Decorator
  delegate_all
  include Draper::LazyHelpers

  decorates_association :address

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  
  def full_name
    "#{object.first_name} #{object.last_name}"
  end

  def formatted_join_date
    content_tag(:span, object.created_at.strftime("%B %d, %Y"), class: 'join-date')
  end

  def created_at
    helpers.content_tag :span, class: 'time' do
      object.created_at.strftime("%a %m/%d/%y")
    end
  end
  

end
