class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :omniauthable, :registerable, :recoverable, :validatable
  devise :database_authenticatable, :rememberable, :trackable

  belongs_to :data_center
  belongs_to :user_role

  after_initialize :generate_sid_if_necessary
  after_create :set_data_center_permission

  validates :username, uniqueness: { message: I18n.t('activerecord.errors.models.user.attributes.username.uniqueness') }
  validates :data_center, presence: { message: I18n.t('activerecord.errors.models.user.attributes.data_center.presence') }
  validates :password, confirmation: { message: I18n.t('activerecord.errors.models.user.attributes.password.confirmation') }
  validates :sid, presence: true
  validates :sid, uniqueness: true
  validates :sid, format: { with: /\AB[a-z0-9]{32}\z/ }

  def api_sign_in
    $redis.set(self.redis_key, {
      auth_token: User.generate_random_hex_string,
      expires_at: User.generate_token_expires_at
    }.to_json)
  end

  def api_sign_out
    $redis.del(self.redis_key)
  end

  def self.authenticate_from_token!(sid, auth_token)
    api_key = User.fetch_api_key_from_redis(sid)
    if api_key.present? && api_key.key?(:auth_token) && api_key.key?(:expires_at) && api_key[:auth_token] == auth_token && api_key[:expires_at] > Time.zone.now
      return User.find_by(sid: sid)
    end
    return nil
  end

  def as_json(options = {})
    Jbuilder.new do |user|
      user.(self, :id, :data_center_id, :username, :locale, :sid, :user_role_id)
      user.auth_token User.fetch_api_key_from_redis(sid).try(:[], :auth_token)
    end.attributes!
  end


protected

  def redis_key
    return "user_#{self.sid}"
  end

private

  def set_data_center_permission
    DataCenterPermission.find_or_create_by(user: self, data_center: self.data_center)
  end

  def generate_sid_if_necessary
    self.sid ||= "B#{User.generate_random_hex_string}"
    return true
  end

  def self.fetch_api_key_from_redis(sid)
    api_key = $redis.get("user_#{sid}")
    return api_key.present? ? JSON.parse(api_key).try(:symbolize_keys) : nil
  end

  def self.generate_random_hex_string
    return SecureRandom.hex(16)
  end

  def self.generate_token_expires_at
    return 1.month.from_now
  end

end
