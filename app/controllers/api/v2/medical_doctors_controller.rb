module Api
  module V2
    class MedicalDoctorsController < ApiController
      before_action :set_medical_doctor, only: [:update, :destroy]

      def index
        @medical_doctors = MedicalDoctor.joins(:hospital).where(hospitals: { data_center_id: @api_user.data_center }).order(id: :asc)
        render json: @medical_doctors
      end

      def create
        @medical_doctor = MedicalDoctor.new(medical_doctor_params)
        if @medical_doctor.save
          render json: @medical_doctor
        else
          render json: ErrorsHelper.serialize(@medical_doctor.errors), status: :unprocessable_entity
        end
      end

      def update
        if @medical_doctor.update(medical_doctor_params)
          render json: @medical_doctor
        else
          render json: ErrorsHelper.serialize(@medical_doctor.errors), status: :unprocessable_entity
        end
      end

      def destroy
        if @medical_doctor.destroy
          render nothing: true
        else
          render json: ErrorsHelper.serialize(@medical_doctor.errors), status: :unprocessable_entity
        end
      end

    private

      def set_medical_doctor
        @medical_doctor = MedicalDoctor.find(params[:id])
      end

      def medical_doctor_params
        #TODO: Assert that hospital is in same data center as the current API user.
        return self.params.permit(:hospital_id, :name, :phone_number)
      end
    end
  end
end
