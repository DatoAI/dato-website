class UserPolicy < ApplicationPolicy

  # =================================
  # Actions
  # =================================

  def edit?
    record == user || can_change_permission?
  end

  def update?
    record == user || user&.is_admin
  end

  def home?
    user&.is_admin
  end

  def list_users?
    user&.is_admin
  end 

  def can_change_permission?
    user&.admin? || (user.general_admin? && (record&.user? || record&.competition_admin?))
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
