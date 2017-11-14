class InvitationPolicy < ApplicationPolicy
  # =================================
  # Actions
  # =================================

  def create?
    user&.is_admin
  end

  def update?
    user&.is_admin
  end

  def destroy?
    user&.is_admin
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
