class SettingsController < AdministrativeInterfaceController
  before_action :set_setting, only: [:show, :edit, :update]
  skip_before_action :verify_authenticity_token

  # GET /settings
  def index
    @settings = Setting.by_data_center(current_user.data_center).all
  end

  # GET /settings/1
  def show
  end

  # GET /settings/1/edit
  def edit
  end

  # PATCH/PUT /settings/1
  def update
    if @setting.set_cached_setting(setting_params[:value])
      redirect_to @setting, notice: I18n.t('activerecord.notices.models.setting.success.update')
    else
      render :edit
    end
  end

  def set_user_data_center
    data_center = DataCenter.find_by(id: params[:user][:data_center_id])
    authorize data_center
    current_user.update(data_center: data_center)
    redirect_to :back #, notice: I18n.t('activerecord.notices.models.user.data_center.success.update', data_center: data_center.name)
  end

private

  def set_setting
    @setting = Setting.by_data_center(current_user.data_center).find_by(id: params[:id])
    if @setting.key == 'admin_number'
      administrator = Administrator.find_or_create_by(name: 'Admin', data_center_id: current_user.data_center.id)
      administrator.phone_number = @setting.value
      administrator.save
    end
  end

  def setting_params
    return self.params.require(:setting).permit(:value)
  end
end
# Rails.logger.tagged("#{File.basename(__FILE__)}:#{__LINE__}") { Rails.logger.info "xxxx: #{xxxx}" }
