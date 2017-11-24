class InvitationPolicy < ApplicationPolicy
  # =================================
  # Actions
  # =================================

  def index?
    user&.is_admin || user&.competition_admin?
  end

  def show?
    user&.is_admin || user&.competition_admin?
  end

  def edit?
    user&.is_admin || user&.competition_admin?
  end

  def create?
    user&.is_admin || user&.competition_admin?
  end

  def update?
    user&.is_admin || user&.competition_admin?
  end

  def destroy?
    user&.is_admin || user&.competition_admin?
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
