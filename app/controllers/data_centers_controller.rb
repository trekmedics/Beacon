class DataCentersController < AdministrativeInterfaceController
  before_action :set_data_center, only: [:edit, :update]
  before_action :authorize_admin_user

  # GET /data_centers
  def index
    @data_centers = DataCenter.all
  end

  # GET /data_centers/new
  def new
    @data_center = DataCenter.new
  end

  # GET /data_centers/1/edit
  def edit
  end

  # POST /data_centers
  def create
    @data_center = DataCenter.new(data_center_params)
    if @data_center.save
      redirect_to data_centers_path, notice: I18n.t('activerecord.notices.models.data_center.success.create')
    else
      render :new
    end
  end

  # PATCH/PUT /data_centers/1
  def update
    if @data_center.update(data_center_params)
      redirect_to data_centers_path, notice: I18n.t('activerecord.notices.models.data_center.success.update')
    else
      render :edit
    end
  end

private

  def set_data_center
    @data_center = DataCenter.find(params[:id])
  end

  def data_center_params
    return self.params.require(:data_center).permit(:name, :is_simulator)
  end
end
