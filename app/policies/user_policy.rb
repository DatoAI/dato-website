class UserPolicy < ApplicationPolicy

  # =================================
  # Actions
  # =================================

  def edit?
    record == user || user&.admin?
  end

  def update?
    record == user || user&.admin?
  end

  def home?
    user&.admin?
  end

  def list_users?
    user&.admin?
  end 

  # =================================
  # Scope
  # =================================

  class Scope < Scope
    def resolve
      scope
    end
  end
end
