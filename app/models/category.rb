class Category < ActiveRecord::Base
  has_many :subcategories, dependent: :destroy

  validates :name, presence: { message: I18n.t('activerecord.errors.models.category.attributes.name.presence') }
  validates :name, uniqueness: { message: I18n.t('activerecord.errors.models.category.attributes.name.uniqueness') }

  def to_s
    return self.name
  end
end
