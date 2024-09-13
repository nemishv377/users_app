class UserPolicy < ApplicationPolicy
  # our authorization rules will go here

  def new?
    create?
  end

  def create?
    admin?
  end

  def update?
    owner_or_admin?
  end

  def edit?
    update?
  end

  def update_avatar?
    update?
  end

  def show?
    record == user || admin?
  end

  def clone?
    create?
  end

  def create_clone?
    create?
  end

  def destroy?
    owner_or_admin?
  end

  def deactivate?
    admin?
  end

  def activate?
    admin?
  end

  def export_csv?
    admin?
  end

  def export_csv_for_user?
    admin?
  end

  def owner_or_admin?
    record.user == user || admin?
  end

  def admin?
    user.has_role?(:admin)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      user.has_role?(:admin) ? scope.all : scope.where(id: user.id)
    end
  end
end
