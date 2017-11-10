class CompetitionPolicy < ApplicationPolicy

  # =================================
  # Scope
  # =================================

  class Scope < Scope
    def resolve
      scope
    end
  end

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

  def disable?
    user&.is_admin
  end

  def enable?
    user&.is_admin
  end

end
