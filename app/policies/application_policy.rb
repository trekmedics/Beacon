class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    return false
  end

  def show?
    return false
  end

  def create?
    return false
  end

  def new?
    return false
  end

  def update?
    return false
  end

  def edit?
    return false
  end

  def destroy?
    return false
  end

  def scope
    return Pundit.policy_scope!(user, record.class)
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      return scope
    end
  end
end

