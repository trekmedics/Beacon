class HospitalsController < AdministrativeInterfaceController
  before_action :set_hospital, only: [:show, :edit, :update, :destroy]

  # GET /hospitals
  def index
    @hospitals = Hospital.by_data_center(current_user.data_center).all
  end

  # GET /hospitals/new
  def new
    @hospital = Hospital.new(data_center: current_user.data_center)
  end

  # GET /hospitals/1/edit
  def edit
  end

  # POST /hospitals
  def create
    @hospital = Hospital.new(hospital_params.merge(data_center: current_user.data_center))
    if @hospital.save
      redirect_to hospitals_path, notice: I18n.t('activerecord.notices.models.hospital.success.create')
    else
      render :new
    end
  end

  # PATCH/PUT /hospitals/1
  def update
    if @hospital.update(hospital_params)
      redirect_to hospitals_path, notice: I18n.t('activerecord.notices.models.hospital.success.update')
    else
      render :edit
    end
  end

  # DELETE /hospitals/1
  def destroy
    @hospital.destroy
    redirect_to hospitals_url, notice: I18n.t('activerecord.notices.models.hospital.success.destroy')
  end

private

  def set_hospital
    @hospital = Hospital.find_by(id: params[:id])
  end

  def hospital_params
    return self.params.require(:hospital).permit(:name, :address)
  end
end
