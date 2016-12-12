class UserPolicy < ApplicationPolicy

  def index?
    Rails.logger.tagged("#{File.basename(__FILE__)}:#{__LINE__}") { Rails.logger.info "@record.user_role_id: #{@record.user_role_id}" }
    role_name = UserRole.find(@record.user_role_id).name
    Rails.logger.tagged("#{File.basename(__FILE__)}:#{__LINE__}") { Rails.logger.info "role_name: #{role_name}" }
    role_name == 'Admin' or role_name == 'Manager'
  end

  def create?
    Rails.logger.tagged("#{File.basename(__FILE__)}:#{__LINE__}") { Rails.logger.info "@record.user_role_id: #{@record.user_role_id}" }
    role_name = UserRole.find(@record.user_role_id).name
    Rails.logger.tagged("#{File.basename(__FILE__)}:#{__LINE__}") { Rails.logger.info "role_name: #{role_name}" }
    role_name == 'Admin'
  end

  def update?
    Rails.logger.tagged("#{File.basename(__FILE__)}:#{__LINE__}") { Rails.logger.info "@record.user_role_id: #{@record.user_role_id}" }
    role_name = UserRole.find(@record.user_role_id).name
    Rails.logger.tagged("#{File.basename(__FILE__)}:#{__LINE__}") { Rails.logger.info "role_name: #{role_name}" }
    role_name == 'Admin'
  end

  def destroy?
    Rails.logger.tagged("#{File.basename(__FILE__)}:#{__LINE__}") { Rails.logger.info "@record.user_role_id: #{@record.user_role_id}" }
    role_name = UserRole.find(@record.user_role_id).name
    Rails.logger.tagged("#{File.basename(__FILE__)}:#{__LINE__}") { Rails.logger.info "role_name: #{role_name}" }
    role_name == 'Admin'
  end

end
#     Rails.logger.tagged("#{File.basename(__FILE__)}:#{__LINE__}") { Rails.logger.info "user_params: #{user_params.to_s}" }
