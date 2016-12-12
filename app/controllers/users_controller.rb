class UsersController < AdministrativeInterfaceController
  before_action :set_user, only: [:edit, :update, :destroy]
  before_action :authorize_admin_user

  # GET /users
  def index
    @users = User.all
  end

  # GET /users/new
  def new
    @user = User.new(data_center: current_user.data_center)
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  def create
    @user = User.new(user_params.merge(data_center: current_user.data_center))
    if @user.save
      redirect_to users_path, notice: I18n.t('activerecord.notices.models.user.success.create')
    else
      render :new
    end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      redirect_to users_path, notice: I18n.t('activerecord.notices.models.user.success.update')
    else
      render :edit
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy
    redirect_to users_path, notice: I18n.t('activerecord.notices.models.user.success.destroy')
  end

  def set_data_center_permissions
    data_center_ids = []
    self.params.each do |key, value|
      captures = /data_center_(\d+)/.match(key).try(:captures)
      if captures.present? && value == 'true'
        data_center_ids << captures[0].to_i
      end
    end
    DataCenterPermission.set_permissions(params[:user_id], data_center_ids)
    redirect_to users_path, notice: I18n.t('activerecord.notices.models.user.success.permissions')
  end

private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    return self.params.require(:user).permit(:username, :password, :password_confirmation, :locale, :user_role_id)
  end
end

#     Rails.logger.tagged("#{File.basename(__FILE__)}:#{__LINE__}") { Rails.logger.info "user_params: #{user_params.to_s}" }
