class MedicalDoctorsController < AdministrativeInterfaceController
  before_action :set_hospital
  before_action :set_medical_doctor, only: [:edit, :update, :destroy]

  # GET /medical_doctors/new
  def new
    @medical_doctor = MedicalDoctor.new(hospital: @hospital)
  end

  # GET /medical_doctors/1/edit
  def edit
  end

  # POST /medical_doctors
  def create
    @medical_doctor = MedicalDoctor.new(medical_doctor_params.merge(hospital: @hospital))
    if @medical_doctor.save
      redirect_to hospitals_path, notice: I18n.t('activerecord.notices.models.medical_doctor.success.create')
    else
      render :new
    end
  end

  # PATCH/PUT /medical_doctors/1
  def update
    if @medical_doctor.update(medical_doctor_params)
      redirect_to hospitals_path, notice: I18n.t('activerecord.notices.models.medical_doctor.success.update')
    else
      render :edit
    end
  end

  # DELETE /medical_doctors/1
  def destroy
    @medical_doctor.destroy
    redirect_to hospitals_path, notice: I18n.t('activerecord.notices.models.medical_doctor.success.destroy')
  end

private

  def set_hospital
    @hospital = Hospital.find_by(id: params[:hospital_id])
  end

  def set_medical_doctor
    @medical_doctor = MedicalDoctor.find_by(id: params[:id])
  end

  def medical_doctor_params
    return self.params.require(:medical_doctor).permit(:name, :phone_number)
  end
end
