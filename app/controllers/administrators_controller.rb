class AdministratorsController < AdministrativeInterfaceController
  before_action :set_administrator, only: [:show, :edit, :update, :destroy]

  # GET /administrators
  def index
    @administrators = Administrator.find_by_data_center(current_user.data_center).all
  end

  # GET /administrators/new
  def new
    @administrator = Administrator.new(data_center: current_user.data_center)
  end

  # GET /administrators/1/edit
  def edit
  end

  # POST /administrators
  def create
    @administrator = Administrator.new(administrator_params.merge(data_center: current_user.data_center))

    if @administrator.save
      redirect_to administrators_path, notice: I18n.t('activerecord.notices.models.administrator.success.create')
    else
      render :new
    end
  end

  # PATCH/PUT /administrators/1
  def update
    if @administrator.update(administrator_params)
      redirect_to administrators_path, notice: I18n.t('activerecord.notices.models.administrator.success.update')
    else
      render :edit
    end
  end

  # DELETE /administrators/1
  def destroy
    @administrator.destroy
    redirect_to administrators_url, notice: I18n.t('activerecord.notices.models.administrator.success.destroy')
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_administrator
      @administrator = Administrator.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def administrator_params
    return self.params.require(:administrator).permit(:name, :phone_number, :email)
    end
end
