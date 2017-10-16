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
    user&.admin?
  end

  def update?
    user&.admin?
  end

  def destroy?
    user&.admin?
  end

  def disable?
    user&.admin?
  end

  def enable?
    user&.admin?
  end

end
