module Api
  module V2
    class SubcategoriesController < ApiController
      before_action :set_subcategory, only: [:update, :destroy]

      def index
        @subcategories = Subcategory.all.order(id: :asc)
        render json: @subcategories
      end

      def create
        @subcategory = Subcategory.new(subcategory_params)
        if @subcategory.save
          render json: @subcategory
        else
          render json: ErrorsHelper.serialize(@subcategory.errors), status: :unprocessable_entity
        end
      end

      def update
        if @subcategory.update(subcategory_params)
          render json: @subcategory
        else
          render json: ErrorsHelper.serialize(@subcategory.errors), status: :unprocessable_entity
        end
      end

      def destroy
        if @subcategory.destroy
          render nothing: true
        else
          render json: ErrorsHelper.serialize(@subcategory.errors), status: :unprocessable_entity
        end
      end

    private

      def set_subcategory
        @subcategory = Subcategory.find(params[:id])
      end

      def subcategory_params
        return self.params.permit(:category_id, :name)
      end
    end
  end
end
