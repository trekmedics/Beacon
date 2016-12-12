module Api
  module V2
    class DataCentersController < ApiController
      before_action :set_data_center, only: [:update, :destroy]

      def index
        @data_centers = DataCenter.all.order(id: :asc)
        render json: @data_centers
      end

      def create
        @data_center = DataCenter.new(data_center_params)
        if @data_center.save
          render json: @data_center
        else
          render json: ErrorsHelper.serialize(@data_center.errors), status: :unprocessable_entity
        end
      end

      def update
        if @data_center.update(data_center_params)
          render json: @data_center
        else
          render json: ErrorsHelper.serialize(@data_center.errors), status: :unprocessable_entity
        end
      end

      def destroy
        if @data_center.destroy
          render nothing: true
        else
          render json: ErrorsHelper.serialize(@data_center.errors), status: :unprocessable_entity
        end
      end

    private

      def set_data_center
        @data_center = DataCenter.find(params[:id])
      end

      def data_center_params
        return self.params.permit(:name, :is_simulator)
      end
    end
  end
end
