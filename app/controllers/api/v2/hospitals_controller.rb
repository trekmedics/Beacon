module Api
  module V2
    class HospitalsController < ApiController
      before_action :set_hospital, only: [:update, :destroy]

      def index
        @hospitals = Hospital.by_data_center(@api_user.data_center).all.order(id: :desc)
        render json: @hospitals
      end

      def create
        @hospital = Hospital.new(hospital_params.merge(data_center: @api_user.data_center))
        if @hospital.save
          render json: @hospital
        else
          render json: ErrorsHelper.serialize(@hospital.errors), status: :unprocessable_entity
        end
      end

      def update
        if @hospital.update(hospital_params)
          render json: @hospital
        else
          render json: ErrorsHelper.serialize(@hospital.errors), status: :unprocessable_entity
        end
      end

      def destroy
        if @hospital.destroy
          render nothing: true
        else
          render json: ErrorsHelper.serialize(@hospital.errors), status: :unprocessable_entity
        end
      end

    private

      def set_hospital
        @hospital = Hospital.find(params[:id])
      end

      def hospital_params
        return self.params.permit(:name, :address)
      end
    end
  end
end

# Rails.logger.tagged("#{File.basename(__FILE__)}:#{__LINE__}") { Rails.logger.info "xxxx: #{xxxx}" }
