class UserRole < ActiveRecord::Base
  has_many :users

  def to_s
    return self.name
  end

end
